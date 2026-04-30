import type { GameState } from "../models/GameState";
import { EVENTS_CONFIG, type SpecialEventType } from "../config/eventsConfig";
import { chance } from "../../shared/utils/random";

export interface ActiveEvent {
  type: SpecialEventType;
  remainingSegments: number;
}

export class EventManager {
  private activeEvents: ActiveEvent[] = [];
  private premiumReductionActive = false;

  /** Tente de déclencher des événements spéciaux. Retourne les types déclenchés. */
  roll(state: GameState): SpecialEventType[] {
    const triggered: SpecialEventType[] = [];

    for (const def of EVENTS_CONFIG) {
      if (chance(def.probability)) {
        // Évite les doublons
        const alreadyActive = this.activeEvents.some((e) => e.type === def.type);
        if (alreadyActive) continue;

        triggered.push(def.type);

        if (def.durationSegments) {
          this.activeEvents.push({
            type: def.type,
            remainingSegments: def.durationSegments,
          });
        }

        if (def.type === "bonus_gold" && def.goldBonus) {
          state.gold += def.goldBonus;
          state.totalGoldCollected += def.goldBonus;
        }

        if (def.type === "prime_reduction") {
          this.premiumReductionActive = true;
        }
      }
    }

    return triggered;
  }

  /** Avance d'un segment, décrémente les durées des événements actifs. */
  tick(): void {
    this.activeEvents = this.activeEvents
      .map((e) => ({ ...e, remainingSegments: e.remainingSegments - 1 }))
      .filter((e) => e.remainingSegments > 0);

    this.premiumReductionActive = this.activeEvents.some((e) => e.type === "prime_reduction");
  }

  /** Multiplicateur de prime (réduit si event actif). */
  getPremiumMultiplier(): number {
    return this.premiumReductionActive ? 0.5 : 1.0;
  }

  /** Multiplicateur de pièces (augmenté si pluie de pièces active). */
  getCoinRainMultiplier(): number {
    return this.activeEvents.some((e) => e.type === "coin_rain") ? 2.0 : 1.0;
  }

  getActiveEvents(): ActiveEvent[] {
    return [...this.activeEvents];
  }
}
