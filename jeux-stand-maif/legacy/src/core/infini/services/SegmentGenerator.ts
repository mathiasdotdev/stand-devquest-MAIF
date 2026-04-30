import type { GameState } from "../models/GameState";
import type { Segment, CoinZone, ObstacleData } from "../models/Segment";
import type { DifficultyParams } from "./DifficultyScaler";
import type { PathRisk } from "../models/Path";
import { GAME_CONFIG } from "../config/gameConfig";
import { DISASTER_TYPES } from "../../shared/config/disastersConfig";
import { chance, randomInt, randomFloat, pick } from "../../shared/utils/random";

export class SegmentGenerator {
  /**
   * Génère le prochain segment de route.
   * Applique les règles dures :
   * - Pas d'agence consécutive
   * - Première agence au segment FIRST_AGENCY_SEGMENT
   * - Pas de fork consécutif
   */
  generate(state: GameState, difficulty: DifficultyParams): Segment {
    const index = state.currentSegmentIndex + 1;
    const prevType = state.currentSegment?.type ?? "road";

    // Agence ?
    const isAgency = this.shouldSpawnAgency(state, prevType);
    if (isAgency) {
      return this.buildAgencySegment(index);
    }

    // Fork ?
    const isFork = prevType !== "fork" && chance(difficulty.forkProb);
    if (isFork) {
      return this.buildForkSegment(index, difficulty);
    }

    // Segment normal avec sinistre potentiel
    return this.buildRoadSegment(index, difficulty, state.currentPathRisk);
  }

  private shouldSpawnAgency(state: GameState, prevType: string): boolean {
    if (prevType === "agency") return false;

    const seg = state.currentSegmentIndex;

    // Première agence
    if (seg + 1 === GAME_CONFIG.FIRST_AGENCY_SEGMENT) return true;

    // Agences suivantes
    if (seg < GAME_CONFIG.FIRST_AGENCY_SEGMENT) return false;

    const sinceLastAgency = state.segmentsSinceLastAgency;
    if (sinceLastAgency < GAME_CONFIG.AGENCY_INTERVAL_MIN) return false;
    if (sinceLastAgency >= GAME_CONFIG.AGENCY_INTERVAL_MAX) return true;

    // Probabilité croissante entre min et max
    const prob =
      (sinceLastAgency - GAME_CONFIG.AGENCY_INTERVAL_MIN) /
      (GAME_CONFIG.AGENCY_INTERVAL_MAX - GAME_CONFIG.AGENCY_INTERVAL_MIN);
    return chance(prob * 0.4);
  }

  private buildAgencySegment(index: number): Segment {
    return {
      index,
      type: "agency",
      coins: [{ count: 2, isAirborne: false }],
      obstacles: [],
      isAgency: true,
      goldBonus: 0,
      label: "Agence MAIF",
    };
  }

  private buildForkSegment(index: number, _difficulty: DifficultyParams): Segment {
    return {
      index,
      type: "fork",
      coins: [{ count: randomInt(2, 4), isAirborne: false }],
      obstacles: [],
      isAgency: false,
      goldBonus: 0,
      label: "Embranchement",
    };
  }

  private buildRoadSegment(index: number, difficulty: DifficultyParams, pathRisk: PathRisk = "safe"): Segment {
    // Pièces
    const coinCount = randomInt(GAME_CONFIG.COINS_PER_SEGMENT_MIN, GAME_CONFIG.COINS_PER_SEGMENT_MAX);
    const coins: CoinZone[] = [
      { count: Math.floor(coinCount * 0.7), isAirborne: false },
    ];
    if (chance(GAME_CONFIG.AIRBORNE_COIN_PROB)) {
      coins.push({ count: randomInt(1, 3), isAirborne: true });
    }

    // Obstacles — densité basée sur le risque du chemin
    const obstacleCfg: Record<PathRisk, { spawnChance: number; min: number; max: number }> = {
      safe:      { spawnChance: 0.50, min: 1, max: 2 },
      risky:     { spawnChance: 0.80, min: 2, max: 4 },
      dangerous: { spawnChance: 0.95, min: 3, max: 5 },
    };
    const cfg = obstacleCfg[pathRisk];
    const obstacleCount = chance(cfg.spawnChance) ? randomInt(cfg.min, cfg.max) : 0;
    const obstacles: ObstacleData[] = Array.from({ length: obstacleCount }, (_, i) => ({
      isHighObstacle: chance(0.5),
      // Positions réparties uniformément dans 15–85% du segment, avec petite variance
      xRatio: Math.max(0.1, Math.min(0.9, (i + 1) / (obstacleCount + 1) + randomFloat(-0.05, 0.05))),
    }));

    // Sinistre
    const hasDisaster = chance(difficulty.disasterProb);
    const disasterType = hasDisaster ? pick(DISASTER_TYPES) : undefined;

    return {
      index,
      type: "road",
      coins,
      obstacles,
      disasterType,
      disasterProbability: hasDisaster ? difficulty.disasterProb : 0,
      isAgency: false,
      goldBonus: chance(0.05) ? 30 : 0, // 5% chance de trouver un coffre
      label: "Route",
    };
  }
}
