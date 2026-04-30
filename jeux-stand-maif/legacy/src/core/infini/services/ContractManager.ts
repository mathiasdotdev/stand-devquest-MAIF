import type { GameState } from "../models/GameState";
import type { ContractType, ContractLevel, ActiveContract, PendingContract } from "../../shared/models/Contract";
import { CONTRACTS_CONFIG } from "../../shared/config/contractsConfig";
import { GAME_CONFIG } from "../config/gameConfig";

export class ContractManager {
  /**
   * Souscrit un contrat. Crée un PendingContract (carence).
   * Retourne false si le contrat existe déjà (actif ou en carence).
   */
  subscribe(state: GameState, type: ContractType, level: ContractLevel): boolean {
    const alreadyActive = state.activeContracts.some((c) => c.type === type);
    const alreadyPending = state.pendingContracts.some((c) => c.type === type);
    if (alreadyActive || alreadyPending) return false;

    const def = CONTRACTS_CONFIG.find((c) => c.type === type);
    if (!def) return false;

    const pending: PendingContract = {
      type,
      level,
      segmentSubscribed: state.currentSegmentIndex,
      activatesAtSegment: state.currentSegmentIndex + GAME_CONFIG.CARENCE_DURATION,
    };
    state.pendingContracts.push(pending);
    return true;
  }

  /**
   * Résilie un contrat actif immédiatement.
   */
  cancel(state: GameState, type: ContractType): boolean {
    const idx = state.activeContracts.findIndex((c) => c.type === type);
    if (idx !== -1) {
      state.activeContracts.splice(idx, 1);
      return true;
    }
    const pidx = state.pendingContracts.findIndex((c) => c.type === type);
    if (pidx !== -1) {
      state.pendingContracts.splice(pidx, 1);
      return true;
    }
    return false;
  }

  /**
   * Upgrade d'un contrat basique vers premium.
   * Remet en carence.
   */
  upgrade(state: GameState, type: ContractType): boolean {
    const idx = state.activeContracts.findIndex((c) => c.type === type && c.level === "basique");
    if (idx === -1) return false;

    state.activeContracts.splice(idx, 1);

    const pending: PendingContract = {
      type,
      level: "premium",
      segmentSubscribed: state.currentSegmentIndex,
      activatesAtSegment: state.currentSegmentIndex + GAME_CONFIG.CARENCE_DURATION,
    };
    state.pendingContracts.push(pending);
    return true;
  }

  /**
   * Vérifie les contrats en carence et active ceux dont le délai est écoulé.
   * Retourne les contrats nouvellement activés.
   */
  checkCarence(state: GameState): ActiveContract[] {
    const activated: ActiveContract[] = [];
    const remaining: PendingContract[] = [];

    for (const pending of state.pendingContracts) {
      if (state.currentSegmentIndex >= pending.activatesAtSegment) {
        const active: ActiveContract = {
          type: pending.type,
          level: pending.level,
          segmentActivation: state.currentSegmentIndex,
          penaltyMultiplier: 1.0,
        };
        state.activeContracts.push(active);
        activated.push(active);
      } else {
        remaining.push(pending);
      }
    }

    state.pendingContracts = remaining;
    return activated;
  }

  /** Retourne true si un contrat de ce type est actif (pas en carence). */
  isActive(state: GameState, type: ContractType): boolean {
    return state.activeContracts.some((c) => c.type === type);
  }

  /** Retourne true si un contrat est en carence. */
  isPending(state: GameState, type: ContractType): boolean {
    return state.pendingContracts.some((c) => c.type === type);
  }

  /** Retourne les segments restants avant qu'un contrat en carence soit actif. */
  carenceRemaining(state: GameState, type: ContractType): number {
    const pending = state.pendingContracts.find((c) => c.type === type);
    if (!pending) return 0;
    return Math.max(0, pending.activatesAtSegment - state.currentSegmentIndex);
  }

  /**
   * Applique une pénalité de prime au contrat qui a couvert un sinistre.
   * Chaque sinistre couvert augmente la prime de +25% (plafond ×3).
   */
  applyDisasterPenalty(state: GameState, contractType: ContractType): void {
    const contract = state.activeContracts.find((c) => c.type === contractType);
    if (!contract) return;
    contract.penaltyMultiplier = Math.min(contract.penaltyMultiplier * 1.25, 3.0);
  }
}
