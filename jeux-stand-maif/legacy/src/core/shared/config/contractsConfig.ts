import type { ContractDefinition } from "../models/Contract";

export const CONTRACTS_CONFIG: ContractDefinition[] = [
  {
    type: "auto",
    label: "Assurance Auto",
    icon: "🚗",
    levels: {
      basique: {
        premiumPerTick: 14,
        franchise: 0.30,
        description: "Couvre accident + vol véhicule. Franchise 30%.",
      },
      premium: {
        premiumPerTick: 24,
        franchise: 0,
        description: "Couverture totale accident + vol véhicule. Sans franchise.",
      },
    },
    coversDisasters: ["accident_voiture", "vol_vehicule"],
    carenceDuration: 2,
  },
  {
    type: "habitation",
    label: "Assurance Habitation",
    icon: "🏠",
    levels: {
      basique: {
        premiumPerTick: 11,
        franchise: 0.25,
        description: "Couvre dégâts des eaux, incendie, cambriolage. Franchise 25%.",
      },
      premium: {
        premiumPerTick: 19,
        franchise: 0,
        description: "Couverture totale habitation. Sans franchise.",
      },
    },
    coversDisasters: ["degats_des_eaux", "incendie", "cambriolage"],
    carenceDuration: 2,
  },
  {
    type: "sante",
    label: "Assurance Santé",
    icon: "🏥",
    levels: {
      basique: {
        premiumPerTick: 9,
        franchise: 0.20,
        description: "Couvre les blessures. Franchise 20%.",
      },
      premium: {
        premiumPerTick: 16,
        franchise: 0,
        description: "Couverture santé totale. Sans franchise.",
      },
    },
    coversDisasters: ["blessure"],
    carenceDuration: 2,
  },
  {
    type: "vol",
    label: "Assurance Vol",
    icon: "🔒",
    levels: {
      basique: {
        premiumPerTick: 7,
        franchise: 0.20,
        description: "Couvre cambriolage et vol de véhicule. Franchise 20%.",
      },
      premium: {
        premiumPerTick: 13,
        franchise: 0,
        description: "Couverture vol totale. Sans franchise.",
      },
    },
    coversDisasters: ["cambriolage", "vol_vehicule"],
    carenceDuration: 2,
  },
  {
    type: "catastrophe",
    label: "Catastrophe Naturelle",
    icon: "🌊",
    levels: {
      basique: {
        premiumPerTick: 6,
        franchise: 0.10,
        description: "Couvre inondation et tempête. Franchise 10%.",
      },
      premium: {
        premiumPerTick: 11,
        franchise: 0,
        description: "Couverture catnat totale. Sans franchise.",
      },
    },
    coversDisasters: ["inondation", "tempete"],
    carenceDuration: 2,
  },
];

export function getContractDef(type: string): ContractDefinition | undefined {
  return CONTRACTS_CONFIG.find((c) => c.type === type);
}
