import type { Path } from "./Path";

export interface Fork {
  segmentIndex: number;
  paths: [Path, Path] | [Path, Path, Path]; // 2 ou 3 chemins
  chosenPathIndex: number | null; // null = pas encore choisi
}
