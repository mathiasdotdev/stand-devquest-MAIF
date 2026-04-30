import type { GameMode } from "../../shared/models/GameMode";
import type { GameState } from "../models/GameState";
import type { GameEvent } from "../models/GameEvent";
import type { ContractType, ContractLevel } from "../../shared/models/Contract";
import type { DisasterType } from "../../shared/models/Disaster";
import { DISASTERS_CONFIG } from "../../shared/config/disastersConfig";
import { GAME_CONFIG } from "../config/gameConfig";
import { EconomyManager } from "./EconomyManager";
import { ContractManager } from "./ContractManager";
import { SegmentGenerator } from "./SegmentGenerator";
import { ForkGenerator } from "./ForkGenerator";
import { DisasterResolver } from "./DisasterResolver";
import { DifficultyScaler } from "./DifficultyScaler";
import { ComboTracker } from "./ComboTracker";
import { EventManager } from "./EventManager";

const SPEED_KM_S = GAME_CONFIG.SCROLL_SPEED_PX / GAME_CONFIG.PIXELS_PER_KM;

function makeInitialSegment() {
  return {
    index: 0,
    type: "road" as const,
    coins: [{ count: 3, isAirborne: false }],
    obstacles: [],
    isAgency: false,
    goldBonus: 0,
    label: "Départ",
  };
}

export class GameEngine {
  private state: GameState;
  private economy: EconomyManager;
  private contracts: ContractManager;
  private segmentGen: SegmentGenerator;
  private forkGen: ForkGenerator;
  private disasters: DisasterResolver;
  private difficulty: DifficultyScaler;
  private combo: ComboTracker;
  private events: EventManager;

  constructor(mode: GameMode) {
    this.economy = new EconomyManager();
    this.contracts = new ContractManager();
    this.segmentGen = new SegmentGenerator();
    this.forkGen = new ForkGenerator();
    this.disasters = new DisasterResolver();
    this.difficulty = new DifficultyScaler();
    this.combo = new ComboTracker();
    this.events = new EventManager();

    const initial = makeInitialSegment();
    this.state = {
      mode,
      phase: 1,
      currentSegmentIndex: 0,
      distanceKm: 0,
      segmentsSinceLastTick: 0,
      tickCounter: 0,
      segmentsSinceLastAgency: 0,
      gold: GAME_CONFIG.STARTING_GOLD,
      totalGoldCollected: 0,
      totalPremiumsPaid: 0,
      totalDisasterDamage: 0,
      activeContracts: [],
      pendingContracts: [],
      currentSegment: initial,
      nextSegments: [],
      currentFork: null,
      currentPathRisk: "safe",
      mapHistory: [],
      combo: 0,
      bestCombo: 0,
      yoloActive: true,
      disastersCovered: 0,
      disastersUncovered: 0,
      biggestDisaster: null,
      isGameOver: false,
      isPaused: false,
      isInAgency: false,
    };

    // Pré-générer quelques segments
    this.prebuildNextSegments();
  }

  /** Appelé chaque frame par GameScene. delta en millisecondes. */
  advance(delta: number): GameEvent[] {
    if (this.state.isGameOver || this.state.isPaused || this.state.isInAgency) return [];

    const gameEvents: GameEvent[] = [];

    // Avancer la distance
    const prevDistanceKm = this.state.distanceKm;
    this.state.distanceKm += SPEED_KM_S * (delta / 1000);

    // Vérifier le passage de segments
    const prevSegIndex = Math.floor(prevDistanceKm / GAME_CONFIG.SEGMENT_LENGTH_KM);
    const newSegIndex = Math.floor(this.state.distanceKm / GAME_CONFIG.SEGMENT_LENGTH_KM);

    if (newSegIndex > prevSegIndex) {
      for (let s = prevSegIndex + 1; s <= newSegIndex; s++) {
        const segEvents = this.advanceSegment(s);
        gameEvents.push(...segEvents);
        if (this.state.isGameOver) break;
      }
    }

    return gameEvents;
  }

  /** Avance d'un segment. */
  private advanceSegment(segIndex: number): GameEvent[] {
    const events: GameEvent[] = [];
    const diff = this.difficulty.compute(this.state);

    // Mise à jour phase (tous modes)
    const newPhase = this.difficulty.getPhase(segIndex);
    if (newPhase !== this.state.phase) {
      // phase dans GameState reste 1|2|3 pour compatibilité HUD ; phase 4 = toujours affichée comme 3
      const clampedPhase: 1 | 2 | 3 = newPhase > 3 ? 3 : newPhase as 1 | 2 | 3;
      if (clampedPhase !== this.state.phase) {
        this.state.phase = clampedPhase;
        events.push({ type: "PHASE_CHANGE", data: { phase: clampedPhase } });
      }
      // Émettre le changement d'environnement
      const envLabels: Record<number, string> = {
        1: "banlieue",
        2: "centre-ville",
        3: "zone-industrielle",
        4: "chaos",
      };
      events.push({ type: "ENVIRONMENT_CHANGE", data: { phase: newPhase, environment: envLabels[newPhase] ?? "chaos" } });
    }

    // Avancer l'index
    this.state.currentSegmentIndex = segIndex;
    this.state.segmentsSinceLastTick++;
    this.state.segmentsSinceLastAgency++;

    // Activer les contrats en fin de carence
    const activated = this.contracts.checkCarence(this.state);
    if (activated.length > 0) {
      events.push({ type: "CONTRACT_ACTIVATED", data: { contracts: activated } });
    }

    // Mise à jour yolo
    this.economy.updateYolo(this.state);

    // Combo (mode infini)
    this.combo.onSegmentPassed(this.state);

    // Événements spéciaux
    this.events.tick();
    const specialEvents = this.events.roll(this.state);
    for (const evType of specialEvents) {
      if (evType === "coin_rain") {
        events.push({ type: "GOLD_COLLECTED", data: { amount: 0 } }); // signal visuel
      }
    }

    // Milestone bonus (mode infini)
    const milestoneBonus = this.combo.getMilestoneBonus(segIndex);
    if (milestoneBonus > 0 && this.state.mode === "infinite") {
      this.economy.addGold(this.state, milestoneBonus);
      events.push({ type: "MILESTONE_BONUS", data: { amount: milestoneBonus, segmentCount: segIndex } });
    }

    // Tick mensuel
    if (this.state.segmentsSinceLastTick >= GAME_CONFIG.TICK_INTERVAL) {
      this.state.segmentsSinceLastTick = 0;
      this.state.tickCounter++;

      const premiumMultiplier = this.events.getPremiumMultiplier();
      const deducted = this.economy.processTick(this.state, diff.costMultiplier * premiumMultiplier);
      events.push({
        type: "TICK",
        data: { amount: deducted, totalDeducted: this.state.totalPremiumsPaid },
      });
    }

    // Consommer et populer le segment
    const nextSeg = this.state.nextSegments.shift();
    if (nextSeg) {
      if (nextSeg.type === "agency") {
        this.state.segmentsSinceLastAgency = 0;
      }
      this.state.currentSegment = nextSeg;
    }
    this.prebuildNextSegments();

    // Générer le fork si c'est un segment fork
    if (this.state.currentSegment.type === "fork" && !this.state.currentFork) {
      this.state.currentFork = this.forkGen.generate(segIndex, diff, this.state.segmentsSinceLastAgency);
      events.push({ type: "FORK_AHEAD", data: { fork: this.state.currentFork } });
    }

    // Agence
    if (this.state.currentSegment.isAgency) {
      this.state.isInAgency = true;
      events.push({ type: "AGENCY_REACHED", data: { segmentIndex: segIndex } });
    }

    // Sinistre potentiel sur le segment
    if (this.state.currentSegment.disasterType) {
      const disasterResult = this.disasters.resolve(
        this.state.currentSegment.disasterType,
        this.state.activeContracts,
        diff.damageMultiplier
      );
      this.economy.applyDamage(this.state, disasterResult.actualCost);
      this.combo.onDisaster(this.state, disasterResult.wasCovered);

      if (disasterResult.wasCovered) {
        this.state.disastersCovered++;
        // Sinistre couvert → prime du contrat couvrant augmente (+25%)
        if (disasterResult.coveringContractType) {
          this.contracts.applyDisasterPenalty(this.state, disasterResult.coveringContractType as import("../../shared/models/Contract").ContractType);
        }
      } else {
        this.state.disastersUncovered++;
      }

      const cost = disasterResult.actualCost;
      if (!this.state.biggestDisaster || cost > this.state.biggestDisaster.cost) {
        this.state.biggestDisaster = { type: this.state.currentSegment.disasterType, cost };
      }

      events.push({ type: "DISASTER_HIT", data: disasterResult });
    }

    // Vérifier game over
    if (this.state.gold <= 0) {
      this.state.gold = 0;
      this.state.isGameOver = true;
      events.push({
        type: "GAME_OVER",
        data: {
          distanceKm: this.state.distanceKm,
          gold: 0,
          totalGoldCollected: this.state.totalGoldCollected,
          totalPremiumsPaid: this.state.totalPremiumsPaid,
          totalDisasterDamage: this.state.totalDisasterDamage,
        },
      });
    }

    return events;
  }

  /** Pré-génère 2 segments en avance pour les indices visuels. */
  private prebuildNextSegments(): void {
    while (this.state.nextSegments.length < 2) {
      const diff = this.difficulty.compute(this.state);
      const seg = this.segmentGen.generate(this.state, diff);
      this.state.nextSegments.push(seg);
    }
  }

  // ─── API Publique ─────────────────────────────────────────────────────────

  /** Résout manuellement un sinistre (appelé quand le joueur entre dans une zone). */
  resolveDisaster(type: DisasterType): GameEvent[] {
    const diff = this.difficulty.compute(this.state);
    const result = this.disasters.resolve(type, this.state.activeContracts, diff.damageMultiplier);
    this.economy.applyDamage(this.state, result.actualCost);
    this.combo.onDisaster(this.state, result.wasCovered);

    if (result.wasCovered) this.state.disastersCovered++;
    else this.state.disastersUncovered++;

    const events: GameEvent[] = [{ type: "DISASTER_HIT", data: result }];

    if (this.state.gold <= 0) {
      this.state.gold = 0;
      this.state.isGameOver = true;
      events.push({
        type: "GAME_OVER",
        data: {
          distanceKm: this.state.distanceKm,
          gold: 0,
          totalGoldCollected: this.state.totalGoldCollected,
          totalPremiumsPaid: this.state.totalPremiumsPaid,
          totalDisasterDamage: this.state.totalDisasterDamage,
        },
      });
    }
    return events;
  }

  /** Le joueur choisit un chemin au fork. */
  choosePath(pathIndex: number): GameEvent[] {
    if (!this.state.currentFork) return [];

    // Vérifier si le chemin est accessible (pas de gros sinistre sans contrat)
    const paths = this.state.currentFork.paths;
    const chosen = paths[pathIndex];
    const isLocked = chosen.isMajor && !!chosen.disasterType && !this.state.activeContracts.some(
      (c) => DISASTERS_CONFIG[chosen.disasterType!].coveringContracts.includes(c.type)
    );

    // Si bloqué, forcer le premier chemin non bloqué
    let finalIndex = pathIndex;
    if (isLocked) {
      const accessible = paths.findIndex((p) =>
        !p.isMajor || !p.disasterType || this.state.activeContracts.some(
          (c) => DISASTERS_CONFIG[p.disasterType!].coveringContracts.includes(c.type)
        )
      );
      finalIndex = accessible >= 0 ? accessible : 0;
    }

    // Sauvegarder le risque du chemin choisi
    this.state.currentPathRisk = this.state.currentFork.paths[finalIndex].risk;

    // Enregistrer dans l'historique carte
    this.state.mapHistory.push({
      segmentIndex: this.state.currentSegmentIndex,
      pathChosen: finalIndex,
      fork: { ...this.state.currentFork, paths: [...this.state.currentFork.paths] as typeof this.state.currentFork.paths },
    });

    this.state.currentFork.chosenPathIndex = finalIndex;
    this.state.currentFork = null;
    return [{ type: "NEW_SEGMENT", data: { segment: this.state.currentSegment } }];
  }

  /** Le joueur percute un obstacle (dommages immédiats, hors assurance). */
  obstacleHit(damage: number): GameEvent[] {
    this.economy.applyDamage(this.state, damage);
    const events: GameEvent[] = [];
    if (this.state.gold <= 0) {
      this.state.gold = 0;
      this.state.isGameOver = true;
      events.push({
        type: "GAME_OVER",
        data: {
          distanceKm: this.state.distanceKm,
          gold: 0,
          totalGoldCollected: this.state.totalGoldCollected,
          totalPremiumsPaid: this.state.totalPremiumsPaid,
          totalDisasterDamage: this.state.totalDisasterDamage,
        },
      });
    }
    return events;
  }

  /** Le joueur collecte des pièces. */
  collectCoins(count: number, isAirborne: boolean): void {
    const baseValue = isAirborne ? GAME_CONFIG.COIN_AIR_VALUE : GAME_CONFIG.COIN_GROUND_VALUE;
    const multiplier = this.economy.getCoinMultiplier(this.state) * this.events.getCoinRainMultiplier();
    const total = Math.floor(count * baseValue * multiplier);
    this.economy.addGold(this.state, total);
  }

  /** Souscrit un contrat depuis l'AgencyScene. */
  subscribeContract(type: ContractType, level: ContractLevel): boolean {
    return this.contracts.subscribe(this.state, type, level);
  }

  /** Résilie un contrat. */
  cancelContract(type: ContractType): boolean {
    return this.contracts.cancel(this.state, type);
  }

  /** Upgrade un contrat. */
  upgradeContract(type: ContractType): boolean {
    return this.contracts.upgrade(this.state, type);
  }

  /** Ferme l'agence et reprend le jeu. */
  closeAgency(): void {
    this.state.isInAgency = false;
  }

  /** Pause / reprise. */
  setPaused(paused: boolean): void {
    this.state.isPaused = paused;
  }

  getState(): Readonly<GameState> {
    return this.state;
  }

  getContractManager(): ContractManager {
    return this.contracts;
  }

  /**
   * Retourne un aperçu des N prochains embranchements (pour la mini-map).
   * Génère des forks temporaires sans modifier l'état.
   */
  getUpcomingForks(n: number): import("../models/Fork").Fork[] {
    const result: import("../models/Fork").Fork[] = [];
    const diff = this.difficulty.compute(this.state);
    let segIdx = this.state.currentSegmentIndex + 1;
    while (result.length < n) {
      result.push(this.forkGen.generate(segIdx, diff));
      segIdx++;
    }
    return result;
  }
}
