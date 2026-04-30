import { CHAPITRES } from "../config/chapitresConfig";
import { CONTRACTS_CONFIG } from "../../shared/config/contractsConfig";
import { DISASTERS_CONFIG } from "../../shared/config/disastersConfig";
import type { ContractType } from "../../shared/models/Contract";
import type { AnalysisLabel, DisasterHit, QuizAnswer, StoryAnalysis, StoryState } from "../models/StoryState";
import { randomFloat } from "../../shared/utils/random";

/**
 * StoryEngine — moteur du Mode Histoire (format quiz multi-sélection).
 * Pur TypeScript : JAMAIS d'import Phaser.
 *
 * Scoring :
 * - correctCount = contrats sélectionnés ∩ recommendedContracts
 * - wrongCount = contrats sélectionnés ∉ recommendedContracts
 * - baseScore = max(0, round(correctCount * 3 / totalNeeded) - wrongCount)
 * - scoreEarned = max(0, baseScore - hintsUsed)
 */

const SESSION_KEY = "maif-quiz-v1";

export class StoryEngine {
  private state: StoryState;

  constructor(savedState?: StoryState) {
    this.state = savedState ?? {
      currentChapitre: 0,
      totalScore: 0,
      answers: [],
      hintsUsedThisChapitre: 0,
      selectedContracts: [],
      isComplete: false,
    };
  }

  // ─── Persistence sessionStorage ───────────────────────────────────────────

  saveToSession(): void {
    try {
      sessionStorage.setItem(SESSION_KEY, JSON.stringify(this.state));
    } catch {
      // ignore
    }
  }

  static loadFromSession(): StoryEngine | null {
    try {
      const raw = sessionStorage.getItem(SESSION_KEY);
      if (!raw) return null;
      return new StoryEngine(JSON.parse(raw) as StoryState);
    } catch {
      return null;
    }
  }

  static clearSession(): void {
    try {
      sessionStorage.removeItem(SESSION_KEY);
    } catch {
      // ignore
    }
  }

  // ─── Quiz actions ──────────────────────────────────────────────────────────

  /** Toggle un contrat dans la sélection. Retourne true si ajouté, false si retiré. */
  toggleContract(type: ContractType): boolean {
    const idx = this.state.selectedContracts.indexOf(type);
    if (idx === -1) {
      this.state.selectedContracts.push(type);
      return true;
    } else {
      this.state.selectedContracts.splice(idx, 1);
      return false;
    }
  }

  isSelected(type: ContractType): boolean {
    return this.state.selectedContracts.includes(type);
  }

  /** Utilise un indice (max 2 par chapitre). Retourne l'index de l'indice (1 ou 2). */
  useHint(): number {
    if (this.state.hintsUsedThisChapitre < 2) {
      this.state.hintsUsedThisChapitre++;
    }
    return this.state.hintsUsedThisChapitre;
  }

  /** Retourne le texte de l'indice courant (appelé après useHint). */
  getHintText(): string {
    const chapitre = CHAPITRES[this.state.currentChapitre];
    const level = this.state.hintsUsedThisChapitre;

    if (level === 1) {
      const names = chapitre.disasters
        .map((d) => `${DISASTERS_CONFIG[d.type].icon} ${DISASTERS_CONFIG[d.type].label}`)
        .join(", ");
      return `Risques de ce chapitre : ${names}`;
    }
    if (level >= 2) {
      const contractTypes = new Set<ContractType>();
      for (const d of chapitre.disasters) {
        for (const ct of DISASTERS_CONFIG[d.type].coveringContracts) {
          contractTypes.add(ct);
        }
      }
      const labels = [...contractTypes]
        .map((ct) => {
          const def = CONTRACTS_CONFIG.find((c) => c.type === ct);
          return def ? `${def.icon} ${def.label}` : ct;
        })
        .join(", ");
      return `Contrats utiles : ${labels}`;
    }
    return "";
  }

  // ─── Résolution du chapitre ────────────────────────────────────────────────

  resolveCurrentChapitre(): QuizAnswer {
    const chapitre = CHAPITRES[this.state.currentChapitre];
    const chosen = [...this.state.selectedContracts];
    const correctContracts = chapitre.recommendedContracts as ContractType[];
    const totalNeeded = correctContracts.length;

    const correctCount = chosen.filter((c) => correctContracts.includes(c)).length;
    const wrongCount = chosen.filter((c) => !correctContracts.includes(c)).length;

    const baseScore = Math.max(0, Math.round((correctCount * 3) / totalNeeded) - wrongCount);
    const scoreEarned = Math.max(0, baseScore - this.state.hintsUsedThisChapitre);
    const isCorrect = scoreEarned > 0;

    // Résolution des sinistres
    const disasterHits: DisasterHit[] = [];
    for (const chapDisaster of chapitre.disasters) {
      const roll = randomFloat(0, 1);
      if (roll > chapDisaster.probability) continue;
      const def = DISASTERS_CONFIG[chapDisaster.type];
      const wasCovered = chosen.some((ct) => def.coveringContracts.includes(ct));
      disasterHits.push({
        type: chapDisaster.type,
        wasCovered,
        narrative: chapDisaster.narrative,
      });
    }

    const answer: QuizAnswer = {
      chapitreId: this.state.currentChapitre,
      chosenContracts: chosen,
      correctContracts,
      correctCount,
      wrongCount,
      isCorrect,
      hintsUsed: this.state.hintsUsedThisChapitre,
      scoreEarned,
      disasterHits,
    };

    this.state.answers.push(answer);
    this.state.totalScore += scoreEarned;
    return answer;
  }

  nextChapitre(): boolean {
    const nextId = this.state.currentChapitre + 1;
    if (nextId >= CHAPITRES.length) {
      this.state.isComplete = true;
      return false;
    }
    this.state.currentChapitre = nextId;
    this.state.hintsUsedThisChapitre = 0;
    this.state.selectedContracts = [];
    return true;
  }

  // ─── Analyse finale ────────────────────────────────────────────────────────

  getAnalysis(): StoryAnalysis {
    const maxScore = CHAPITRES.length * 3;
    const { totalScore, answers } = this.state;
    const pct = totalScore / maxScore;

    let label: AnalysisLabel;
    if (pct >= 0.85) label = "Expert MAIF";
    else if (pct >= 0.65) label = "Bon élève";
    else if (pct >= 0.4) label = "À améliorer";
    else label = "Débutant";

    const bestAnswer = answers.find((a) => a.isCorrect && a.hintsUsed === 0 && a.wrongCount === 0);
    const worstAnswer = answers.find((a) => !a.isCorrect);

    const bestChoice = bestAnswer
      ? `Ch. ${bestAnswer.chapitreId + 1} — ${bestAnswer.chosenContracts.map((ct) => CONTRACTS_CONFIG.find((c) => c.type === ct)?.label ?? ct).join(", ")}`
      : "Vous avez toujours eu besoin d'indices !";

    const worstChoice = worstAnswer
      ? `Ch. ${worstAnswer.chapitreId + 1} — le bon contrat était ${CONTRACTS_CONFIG.find((c) => c.type === worstAnswer.correctContracts[0])?.label ?? worstAnswer.correctContracts[0]}`
      : "Aucune erreur ! Gestion parfaite.";

    return { totalScore, maxScore, label, answers, bestChoice, worstChoice };
  }

  // ─── Accesseurs ───────────────────────────────────────────────────────────

  getCurrentChapitre() {
    return CHAPITRES[this.state.currentChapitre];
  }

  getState(): Readonly<StoryState> {
    return this.state;
  }
}
