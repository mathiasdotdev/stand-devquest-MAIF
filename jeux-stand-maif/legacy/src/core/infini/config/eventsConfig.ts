export type SpecialEventType =
  | "prime_reduction"   // prime d'un contrat réduite pendant 2 ticks
  | "bonus_gold"        // gain d'or immédiat
  | "obstacle_wave"     // vague d'obstacles (pénalité évitable)
  | "coin_rain";        // pluie de pièces pendant X segments

export interface SpecialEventDefinition {
  type: SpecialEventType;
  label: string;
  description: string;
  probability: number; // par segment
  goldBonus?: number;
  durationSegments?: number;
}

export const EVENTS_CONFIG: SpecialEventDefinition[] = [
  {
    type: "bonus_gold",
    label: "Coffre Trouvé !",
    description: "Un coffre mystérieux sur la route.",
    probability: 0.05,
    goldBonus: 30,
  },
  {
    type: "coin_rain",
    label: "Pluie de Pièces",
    description: "Les pièces tombent du ciel !",
    probability: 0.04,
    durationSegments: 2,
  },
  {
    type: "prime_reduction",
    label: "Offre Spéciale MAIF",
    description: "Vos primes sont réduites de moitié pendant 2 ticks !",
    probability: 0.03,
    durationSegments: 2,
  },
];
