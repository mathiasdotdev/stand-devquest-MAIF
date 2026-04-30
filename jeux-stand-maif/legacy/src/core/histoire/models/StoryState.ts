import type { ContractType } from "../../shared/models/Contract";
import type { DisasterType } from "../../shared/models/Disaster";

export interface DisasterHit {
  type: DisasterType;
  wasCovered: boolean;
  narrative: string;
}

/** Réponse du joueur pour un chapitre du quiz (multi-sélection). */
export interface QuizAnswer {
  chapitreId: number;
  chosenContracts: ContractType[];   // contrats sélectionnés par le joueur
  correctContracts: ContractType[];  // recommendedContracts du chapitre
  correctCount: number;              // nb de contrats recommandés sélectionnés
  wrongCount: number;                // nb de contrats non recommandés sélectionnés
  isCorrect: boolean;                // scoreEarned > 0
  hintsUsed: number;                 // 0-2
  scoreEarned: number;               // 0-3
  disasterHits: DisasterHit[];
}

export type AnalysisLabel = "Expert MAIF" | "Bon élève" | "À améliorer" | "Débutant";

export interface StoryAnalysis {
  totalScore: number;
  maxScore: number;
  label: AnalysisLabel;
  answers: QuizAnswer[];
  bestChoice: string;
  worstChoice: string;
}

/** État du Mode Histoire (quiz multi-sélection). */
export interface StoryState {
  currentChapitre: number;
  totalScore: number;
  answers: QuizAnswer[];
  hintsUsedThisChapitre: number;
  selectedContracts: ContractType[];  // multi-sélection
  isComplete: boolean;
}
