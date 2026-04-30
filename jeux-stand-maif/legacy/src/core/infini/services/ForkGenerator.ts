import type { Fork } from "../models/Fork";
import type { Path, PathRisk } from "../models/Path";
import type { DisasterType } from "../../shared/models/Disaster";
import { DISASTER_TYPES } from "../../shared/config/disastersConfig";
import { GAME_CONFIG } from "../config/gameConfig";
import { chance, pick, randomFloat } from "../../shared/utils/random";
import type { DifficultyParams } from "./DifficultyScaler";

export class ForkGenerator {
  /**
   * Génère un embranchement avec 2 ou 3 chemins.
   * Au moins un chemin a un sinistre potentiel (biais 40% non couvert).
   */
  generate(segmentIndex: number, difficulty: DifficultyParams, segmentsSinceLastAgency = 0): Fork {
    const hasThirdPath = chance(0.5);

    // Agence sur un chemin safe si le joueur n'en a pas vu depuis longtemps
    const showAgencyOnPath = segmentsSinceLastAgency >= GAME_CONFIG.AGENCY_INTERVAL_MIN;

    const paths: Path[] = hasThirdPath
      ? [this.generatePath(0, difficulty), this.generatePath(1, difficulty, true), this.generatePath(2, difficulty)]
      : [this.generatePath(0, difficulty), this.generatePath(1, difficulty)];

    // Garantit qu'au moins un chemin a un sinistre
    const anyDisaster = paths.some((p) => p.disasterType !== undefined);
    if (!anyDisaster && chance(difficulty.disasterProb)) {
      const randomPath = paths[Math.floor(Math.random() * paths.length)];
      randomPath.disasterType = pick(DISASTER_TYPES);
      randomPath.disasterProbability = randomFloat(0.6, 0.9);
      randomPath.risk = "risky";
    }

    // Garantit qu'au moins un chemin est safe
    const anySafe = paths.some((p) => p.risk === "safe");
    if (!anySafe) {
      const safePath = paths.reduce((best, p) =>
        p.disasterProbability < best.disasterProbability ? p : best
      );
      safePath.risk = "safe";
      safePath.disasterProbability = 0;
      safePath.disasterType = undefined;
      safePath.isMajor = false;
    }

    // Pas de gros sinistre bloquant avant la première agence + carence
    // (le joueur n'a pas encore pu souscrire de contrat)
    const tooEarlyForMajor = segmentIndex < GAME_CONFIG.FIRST_AGENCY_SEGMENT + GAME_CONFIG.CARENCE_DURATION + 2;
    if (tooEarlyForMajor) {
      paths.forEach((p) => { p.isMajor = false; });
    }

    // Garantit qu'aucun gros sinistre ne bloque TOUS les chemins
    const nonMajorCount = paths.filter((p) => !p.isMajor).length;
    if (nonMajorCount === 0) {
      paths[0].isMajor = false;
    }

    // Agence sur le chemin le plus safe si nécessaire
    if (showAgencyOnPath) {
      const safest = paths.reduce((best, p) =>
        !p.isMajor && p.disasterProbability < best.disasterProbability ? p : best
      );
      safest.isAgency = true;
    }

    return {
      segmentIndex,
      paths: paths as [Path, Path] | [Path, Path, Path],
      chosenPathIndex: null,
    };
  }

  private generatePath(index: number, difficulty: DifficultyParams, isMidPath = false): Path {
    // Probabilité de sinistre indépendante de la difficulté globale pour assurer la variété des choix.
    // Le chemin du milieu (isMidPath) est toujours risqué/dangereux.
    const pathDisasterChance = isMidPath ? 0.9 : 0.6;
    const hasDisaster = chance(pathDisasterChance);
    const disasterType: DisasterType | undefined = hasDisaster ? pick(DISASTER_TYPES) : undefined;
    const disasterProb = hasDisaster ? randomFloat(0.4, 0.95) : 0;

    let risk: PathRisk = "safe";
    let coinMultiplier = 1.0;

    if (disasterProb > 0.65) {
      risk = "dangerous";
      coinMultiplier = 1.8; // très risqué = très riche
    } else if (disasterProb > 0.3) {
      risk = "risky";
      coinMultiplier = 1.4;
    } else {
      coinMultiplier = isMidPath ? 1.2 : 1.0;
    }

    // Faux positif : affiche un risque qui n'existe pas vraiment
    const isFalsePositive = hasDisaster && chance(difficulty.falsePositiveProb);
    const displayRisk: PathRisk = isFalsePositive ? (risk === "safe" ? "risky" : risk) : risk;

    // Gros sinistre : certain et bloquant (30% des chemins dangereux avec sinistre)
    const isMajor = risk === "dangerous" && hasDisaster && !isFalsePositive && chance(0.3);

    const labels: Record<PathRisk, string[]> = {
      safe: ["Chemin sûr", "Route dégagée", "Passage calme"],
      risky: ["Attention !", "Zone à risque", "Prudence"],
      dangerous: ["Danger !", "Zone critique", "Très dangereux"],
    };

    return {
      index,
      risk: displayRisk,
      coinMultiplier,
      disasterType,
      disasterProbability: isFalsePositive ? 0 : disasterProb,
      isMajor,
      isAgency: false,
      label: pick(labels[displayRisk]),
    };
  }
}
