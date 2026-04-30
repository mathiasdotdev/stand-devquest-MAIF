import type { GameState } from "../models/GameState";
import type { ActiveContract } from "../../shared/models/Contract";
import { CONTRACTS_CONFIG } from "../../shared/config/contractsConfig";
import { GAME_CONFIG } from "../config/gameConfig";
import { clamp } from "../../shared/utils/math";

export class EconomyManager {
  /** Prélève les primes de tous les contrats actifs. Retourne le total déduit. */
  processTick(state: GameState, costMultiplier: number): number {
    let total = 0;
    for (const contract of state.activeContracts) {
      const def = CONTRACTS_CONFIG.find((c) => c.type === contract.type);
      if (!def) continue;
      const basePremium = def.levels[contract.level].premiumPerTick;
      const penalty = contract.penaltyMultiplier ?? 1.0;
      const premium = Math.floor(basePremium * costMultiplier * penalty);
      total += premium;
    }

    // Bonus infini : réduction de prime si event actif (géré dans GameEngine)
    state.gold -= total;
    state.totalPremiumsPaid += total;

    return total;
  }

  /** Applique des dommages à l'or du joueur. */
  applyDamage(state: GameState, amount: number): void {
    const dmg = Math.max(0, Math.floor(amount));
    state.gold -= dmg;
    state.totalDisasterDamage += dmg;
  }

  /** Ajoute de l'or (pièces collectées, bonus, etc.). */
  addGold(state: GameState, amount: number): void {
    const g = Math.max(0, Math.floor(amount));
    state.gold += g;
    state.totalGoldCollected += g;
  }

  /** Vérifie si le joueur peut se permettre une prime (sans tomber à 0). */
  canAfford(state: GameState, amount: number): boolean {
    return state.gold >= amount;
  }

  /** Calcule le total des primes mensuelles actuelles (pour affichage). */
  getTotalPremiumPerTick(activeContracts: ActiveContract[], costMultiplier: number): number {
    return activeContracts.reduce((sum, contract) => {
      const def = CONTRACTS_CONFIG.find((c) => c.type === contract.type);
      if (!def) return sum;
      return sum + Math.floor(def.levels[contract.level].premiumPerTick * costMultiplier);
    }, 0);
  }

  /** Multiplicateur de pièces pour le mode yolo (0 contrat). */
  getCoinMultiplier(state: GameState): number {
    const hasContracts = state.activeContracts.length > 0 || state.pendingContracts.length > 0;
    const yoloMultiplier = hasContracts ? 1.0 : 2.0;

    const comboBonus = this.getComboBonus(state.combo, state.mode);
    return yoloMultiplier * (1 + comboBonus);
  }

  private getComboBonus(combo: number, mode: string): number {
    if (mode !== "infinite") return 0;
    const tiers = GAME_CONFIG.COMBO_TIERS;
    let bonus = 0;
    for (const tier of tiers) {
      if (combo >= tier.threshold) bonus = tier.coinBonus;
    }
    return bonus;
  }

  /** Vérifie et met à jour le flag yolo. */
  updateYolo(state: GameState): void {
    state.yoloActive = state.activeContracts.length === 0 && state.pendingContracts.length === 0;
  }

  /** Retire le coût d'un contrat lors de la souscription (pas de frais d'entrée dans ce jeu). */
  processSubscription(_state: GameState, _amount: number): void {
    // Pas de frais de souscription dans cette version
  }

  /** Calcule le montant des dommages non couverts pour une franchise. */
  static franchiseCost(baseDamage: number, franchise: number): number {
    return clamp(Math.floor(baseDamage * franchise), 0, baseDamage);
  }
}
