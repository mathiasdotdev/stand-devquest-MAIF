import type { DisasterType } from "../../shared/models/Disaster";

export type SegmentType = "road" | "fork" | "agency" | "event";

export interface CoinZone {
  count: number;
  isAirborne: boolean; // pièces en hauteur (valeur plus élevée)
}

export interface ObstacleData {
  isHighObstacle: boolean; // true = doit sauter, false = peut glisser
  xRatio: number;          // position relative dans le segment (0 = début, 1 = fin)
}

export interface Segment {
  index: number;
  type: SegmentType;
  coins: CoinZone[];
  obstacles: ObstacleData[];
  disasterType?: DisasterType; // sinistre potentiel sur ce segment
  disasterProbability?: number; // 0-1
  isAgency: boolean;
  goldBonus: number; // bonus or direct (ex : coffre)
  label?: string; // pour debug
}
