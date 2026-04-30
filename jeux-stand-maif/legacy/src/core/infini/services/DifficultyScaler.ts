import type { GameState } from "../models/GameState";
import { GAME_CONFIG } from "../config/gameConfig";

export interface DifficultyParams {
  damageMultiplier: number;     // multiplicateur des dommages des sinistres
  costMultiplier: number;       // multiplicateur des primes de contrats
  disasterProb: number;         // probabilité de sinistre par segment (0-1)
  forkProb: number;             // probabilité de fork par segment (0-1)
  falsePositiveProb: number;    // probabilité de faux positif au fork
  coinMultiplierBase: number;   // multiplicateur de pièces de base
}

export class DifficultyScaler {
  /**
   * Calcule les paramètres de difficulté en fonction de l'état actuel.
   * Mode infini unifié : phases 1-3 (seg 0-99) puis scaling continu (seg 100+).
   */
  compute(state: GameState): DifficultyParams {
    const seg = state.currentSegmentIndex;
    const phase = this.getPhase(seg);

    if (phase <= 3) {
      // Phases 1-3 : params fixes par phase
      const p = phase as 1 | 2 | 3;
      return {
        damageMultiplier: GAME_CONFIG.DAMAGE_MULTIPLIER[p],
        costMultiplier: GAME_CONFIG.DAMAGE_MULTIPLIER[p],
        disasterProb: GAME_CONFIG.DISASTER_PROB[p],
        forkProb: GAME_CONFIG.FORK_PROB[p],
        falsePositiveProb: GAME_CONFIG.FALSE_POSITIVE_PROB[p],
        coinMultiplierBase: 1.0,
      };
    }

    // Phase 4+ : scaling continu à partir du segment 100
    const scaleBase = seg - GAME_CONFIG.INFINITE_START_SEGMENT;
    const scaleFactor = 1 + scaleBase * GAME_CONFIG.INFINITE_COST_SCALE_PER_SEGMENT;
    const disasterScale = 1 + scaleBase * GAME_CONFIG.INFINITE_DISASTER_SCALE_PER_SEGMENT;

    return {
      damageMultiplier: Math.min(scaleFactor * GAME_CONFIG.DAMAGE_MULTIPLIER[3], 4.0),
      costMultiplier: Math.min(scaleFactor * GAME_CONFIG.DAMAGE_MULTIPLIER[3], 4.0),
      disasterProb: Math.min(GAME_CONFIG.DISASTER_PROB[3] * disasterScale, 0.6),
      forkProb: Math.min(GAME_CONFIG.FORK_PROB[3] + scaleBase * 0.003, 0.55),
      falsePositiveProb: Math.max(0.05, GAME_CONFIG.FALSE_POSITIVE_PROB[3] - scaleBase * 0.002),
      coinMultiplierBase: 1.0,
    };
  }

  /**
   * Détermine la phase en fonction du segment.
   * Phases 1-3 = paliers fixes ; phase 4 = infini.
   */
  getPhase(segmentIndex: number): 1 | 2 | 3 | 4 {
    if (segmentIndex < GAME_CONFIG.PHASE_2_START_SEGMENT) return 1;
    if (segmentIndex < GAME_CONFIG.PHASE_3_START_SEGMENT) return 2;
    if (segmentIndex < GAME_CONFIG.INFINITE_START_SEGMENT) return 3;
    return 4;
  }
}
