import type { GameMode } from "../../shared/models/GameMode";
import type { ActiveContract, PendingContract } from "../../shared/models/Contract";
import type { Segment } from "./Segment";
import type { Fork } from "./Fork";
import type { DisasterType } from "../../shared/models/Disaster";
import type { PathRisk } from "./Path";

export interface GameState {
  // Identité
  mode: GameMode;
  phase: 1 | 2 | 3; // story uniquement (en mode infini reste 1)

  // Progression
  currentSegmentIndex: number;
  distanceKm: number;
  segmentsSinceLastTick: number;
  tickCounter: number;
  segmentsSinceLastAgency: number;

  // Économie
  gold: number;
  totalGoldCollected: number;
  totalPremiumsPaid: number;
  totalDisasterDamage: number;

  // Contrats
  activeContracts: ActiveContract[];
  pendingContracts: PendingContract[];

  // Génération
  currentSegment: Segment;
  nextSegments: Segment[]; // 2 pré-générés pour les indices visuels
  currentFork: Fork | null;
  currentPathRisk: PathRisk; // risque du chemin en cours (mis à jour à chaque choosePath)

  // Historique carte (MapScene)
  mapHistory: Array<{
    segmentIndex: number;
    pathChosen: number;
    fork: Fork;
  }>;

  // Combo (mode infini)
  combo: number;
  bestCombo: number;
  yoloActive: boolean; // aucun contrat = ×2 pièces

  // Stats
  disastersCovered: number;
  disastersUncovered: number;
  biggestDisaster: { type: DisasterType; cost: number } | null;

  // Status
  isGameOver: boolean;
  isPaused: boolean;
  isInAgency: boolean;
}
