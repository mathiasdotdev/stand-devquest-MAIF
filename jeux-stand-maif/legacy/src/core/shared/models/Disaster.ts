export type DisasterType =
  | "accident_voiture"
  | "degats_des_eaux"
  | "incendie"
  | "blessure"
  | "cambriolage"
  | "vol_vehicule"
  | "inondation"
  | "tempete";

export interface Disaster {
  type: DisasterType;
  baseDamage: number;
  label: string;
  description: string;
}

export interface DisasterResult {
  type: DisasterType;
  baseDamage: number;
  actualCost: number;
  wasCovered: boolean;
  coveringContractType: string | null;
  franchiseAmount: number;
}
