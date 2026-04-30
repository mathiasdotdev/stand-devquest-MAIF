import type { Segment } from "./Segment";
import type { Fork } from "./Fork";
import type { DisasterResult } from "../../shared/models/Disaster";
import type { ActiveContract, PendingContract } from "../../shared/models/Contract";

export type GameEventType =
  | "NEW_SEGMENT"
  | "FORK_AHEAD"
  | "TICK"
  | "CONTRACT_ACTIVATED"
  | "DISASTER_HIT"
  | "GOLD_COLLECTED"
  | "AGENCY_REACHED"
  | "GAME_OVER"
  | "PHASE_CHANGE"
  | "MILESTONE_BONUS"
  | "COMBO_LEVEL_UP"
  | "ENVIRONMENT_CHANGE";

export interface GameEvent {
  type: GameEventType;
  data: GameEventData;
}

export type GameEventData =
  | { segment: Segment }                        // NEW_SEGMENT
  | { fork: Fork }                              // FORK_AHEAD
  | { amount: number; totalDeducted: number }   // TICK
  | { contracts: ActiveContract[] }             // CONTRACT_ACTIVATED
  | DisasterResult                              // DISASTER_HIT
  | { amount: number }                          // GOLD_COLLECTED
  | { segmentIndex: number }                    // AGENCY_REACHED
  | { distanceKm: number; gold: number; totalGoldCollected: number; totalPremiumsPaid: number; totalDisasterDamage: number } // GAME_OVER
  | { phase: 1 | 2 | 3 }                       // PHASE_CHANGE
  | { amount: number; segmentCount: number }    // MILESTONE_BONUS
  | { combo: number; tier: number }             // COMBO_LEVEL_UP
  | { phase: 1 | 2 | 3 | 4; environment: string } // ENVIRONMENT_CHANGE
  | { contract: PendingContract };              // fallback
