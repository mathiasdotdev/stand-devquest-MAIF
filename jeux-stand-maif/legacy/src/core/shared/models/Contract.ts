import type { DisasterType } from "./Disaster";

export type ContractType = "auto" | "habitation" | "sante" | "vol" | "catastrophe";
export type ContractLevel = "basique" | "premium";

export interface ContractLevelDef {
  premiumPerTick: number;
  franchise: number; // fraction du dommage encore à payer (0 = couverture totale)
  description: string;
}

export interface ContractDefinition {
  type: ContractType;
  label: string;
  icon: string; // emoji placeholder
  levels: {
    basique: ContractLevelDef;
    premium: ContractLevelDef;
  };
  coversDisasters: DisasterType[];
  carenceDuration: number; // segments avant activation
}

export interface ActiveContract {
  type: ContractType;
  level: ContractLevel;
  segmentActivation: number; // segment où la carence a pris fin
  penaltyMultiplier: number; // augmente après chaque sinistre couvert (1.0 = normal)
}

export interface PendingContract {
  type: ContractType;
  level: ContractLevel;
  segmentSubscribed: number;
  activatesAtSegment: number; // segmentSubscribed + carenceDuration
}
