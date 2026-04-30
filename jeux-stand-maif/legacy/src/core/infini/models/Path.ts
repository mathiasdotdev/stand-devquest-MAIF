import type { DisasterType } from "../../shared/models/Disaster";

export type PathRisk = "safe" | "risky" | "dangerous";

export interface Path {
  index: number; // 0 = haut, 1 = bas (ou milieu), 2 = bas (fork 3 voies)
  risk: PathRisk;
  coinMultiplier: number; // multiplicateur de pièces (1.0 = normal, 1.5 = riche)
  disasterType?: DisasterType; // sinistre présent sur ce chemin
  disasterProbability: number; // 0-1 (petits sinistres probabilistes)
  isMajor: boolean; // gros sinistre : certain, bloque le chemin sans contrat
  isAgency: boolean; // ce chemin mène à une agence
  label: string; // ex : "Chemin rapide" ou "Chemin sûr"
}
