import type { DisasterType } from "../../shared/models/Disaster";
import type { ContractType } from "../../shared/models/Contract";

export interface DialogueLine {
  text: string;
  expression: "normal" | "souriant" | "inquiet" | "fier";
}

export interface ChapitreDisaster {
  type: DisasterType;
  /** 1.0 = certain, 0.5 = aléatoire */
  probability: number;
  /** Court texte narratif affiché lors du sinistre */
  narrative: string;
}

export interface PreventionTip {
  disasterType: DisasterType;
  tip: string;
  emoji: string;
}

export interface Chapitre {
  id: number;
  titre: string;
  emoji: string;
  /** Description courte du contexte de vie */
  contexte: string;
  /** Or disponible pour acheter des contrats avant ce chapitre */
  goldBudget: number;
  /** Dialogue d'introduction du conseiller */
  intro: DialogueLine[];
  /** Sinistres pouvant survenir dans ce chapitre */
  disasters: ChapitreDisaster[];
  /** Conseils de prévention liés à ce chapitre */
  preventionTips: PreventionTip[];
  /** Contrats recommandés pour ce chapitre (aide visuelle) */
  recommendedContracts: ContractType[];
}
