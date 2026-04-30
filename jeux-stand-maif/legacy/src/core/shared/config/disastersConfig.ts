import type { DisasterType } from "../models/Disaster";
import type { ContractType } from "../models/Contract";

export interface DisasterDefinition {
  type: DisasterType;
  label: string;
  icon: string;
  description: string;
  baseDamage: number;
  coveringContracts: ContractType[]; // contrats qui couvrent ce sinistre
}

export const DISASTERS_CONFIG: Record<DisasterType, DisasterDefinition> = {
  accident_voiture: {
    type: "accident_voiture",
    label: "Accident de voiture",
    icon: "💥",
    description: "Accrochage ! Les réparations s'accumulent.",
    baseDamage: 80,
    coveringContracts: ["auto"],
  },
  degats_des_eaux: {
    type: "degats_des_eaux",
    label: "Dégâts des eaux",
    icon: "💧",
    description: "Fuite en appartement. Les dégâts se propagent.",
    baseDamage: 60,
    coveringContracts: ["habitation"],
  },
  incendie: {
    type: "incendie",
    label: "Incendie",
    icon: "🔥",
    description: "Le feu ravage tout sur son passage !",
    baseDamage: 100,
    coveringContracts: ["habitation"],
  },
  blessure: {
    type: "blessure",
    label: "Blessure",
    icon: "🤕",
    description: "Accident corporel. Frais médicaux élevés.",
    baseDamage: 55,
    coveringContracts: ["sante"],
  },
  cambriolage: {
    type: "cambriolage",
    label: "Cambriolage",
    icon: "🦹",
    description: "Des voleurs ont fracturé la porte.",
    baseDamage: 70,
    coveringContracts: ["habitation", "vol"],
  },
  vol_vehicule: {
    type: "vol_vehicule",
    label: "Vol de véhicule",
    icon: "🚨",
    description: "Le véhicule a disparu dans la nuit.",
    baseDamage: 90,
    coveringContracts: ["auto", "vol"],
  },
  inondation: {
    type: "inondation",
    label: "Inondation",
    icon: "🌊",
    description: "La montée des eaux envahit tout.",
    baseDamage: 75,
    coveringContracts: ["catastrophe"],
  },
  tempete: {
    type: "tempete",
    label: "Tempête",
    icon: "⛈️",
    description: "La toiture emportée par le vent.",
    baseDamage: 65,
    coveringContracts: ["catastrophe"],
  },
};

export const DISASTER_TYPES = Object.keys(DISASTERS_CONFIG) as DisasterType[];
