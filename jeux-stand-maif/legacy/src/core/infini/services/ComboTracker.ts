import type { GameState } from "../models/GameState";
import { GAME_CONFIG } from "../config/gameConfig";

export interface ComboTierInfo {
  tier: number;           // index dans COMBO_TIERS (0-3)
  label: string;
  coinBonus: number;
  tickFree: boolean;
  freeCover: boolean;
}

export class ComboTracker {
  /**
   * Appelé après résolution d'un sinistre.
   * Un sinistre majeur non couvert casse le combo.
   * Un sinistre couvert (bonne stratégie) ne le casse pas.
   */
  onDisaster(state: GameState, wasCovered: boolean): void {
    if (state.mode !== "infinite") return;

    if (!wasCovered) {
      state.combo = 0;
    }
    // Si couvert : le combo continue
  }

  /**
   * Incrémente le combo à chaque segment sans sinistre non couvert.
   */
  onSegmentPassed(state: GameState): void {
    if (state.mode !== "infinite") return;
    // Le combo monte avec chaque segment "clean"
    // (il est réinitialisé dans onDisaster si non couvert)
    state.combo++;
    if (state.combo > state.bestCombo) {
      state.bestCombo = state.combo;
    }
  }

  /**
   * Retourne l'info du palier de combo actuel (null si sous le seuil minimal).
   */
  getCurrentTier(combo: number): ComboTierInfo | null {
    const tiers = GAME_CONFIG.COMBO_TIERS;
    let currentTier: ComboTierInfo | null = null;

    for (let i = 0; i < tiers.length; i++) {
      const t = tiers[i];
      if (combo >= t.threshold) {
        currentTier = {
          tier: i,
          label: t.label,
          coinBonus: t.coinBonus,
          tickFree: t.tickFree,
          freeCover: t.freeCover,
        };
      }
    }
    return currentTier;
  }

  /**
   * Retourne le bonus or du milestone (si applicable ce segment).
   * Milestone tous les MILESTONE_INTERVAL segments.
   */
  getMilestoneBonus(segmentIndex: number): number {
    if (segmentIndex === 0) return 0;
    if (segmentIndex % GAME_CONFIG.MILESTONE_INTERVAL !== 0) return 0;

    const palier = Math.floor(segmentIndex / GAME_CONFIG.MILESTONE_INTERVAL);
    return GAME_CONFIG.MILESTONE_BASE_BONUS + (palier - 1) * 100;
  }
}
