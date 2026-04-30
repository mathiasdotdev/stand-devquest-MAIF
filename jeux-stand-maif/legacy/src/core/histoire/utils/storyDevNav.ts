/**
 * storyDevNav — Navigation par URL hash pour le Mode Histoire.
 * Usage dev : #ContractSelectionScene/1 → ouvre directement le chapitre 1.
 *
 * Format : #<SceneKey>[/<chapitreIndex>]
 * Exemples :
 *   #StoryIntroScene
 *   #ChapitreIntroScene/0
 *   #ContractSelectionScene/2
 *   #DisasterRevealScene/1
 *   #StoryAnalysisScene
 */

import { StoryEngine } from "../services/StoryEngine";
import { CHAPITRES } from "../config/chapitresConfig";
import type { ContractType } from "../../shared/models/Contract";

const STORY_SCENE_KEYS = [
  "StoryIntroScene",
  "ChapitreIntroScene",
  "ContractSelectionScene",
  "DisasterRevealScene",
  "ChapitreResultScene",
  "StoryAnalysisScene",
] as const;

type StorySceneKey = (typeof STORY_SCENE_KEYS)[number];

export interface StoryNavTarget {
  scene: StorySceneKey;
  chapitreIndex: number;
}

/** Lit le hash courant et retourne la cible si elle correspond à une scène histoire. */
export function parseStoryHash(): StoryNavTarget | null {
  const raw = window.location.hash.slice(1);
  if (!raw) return null;
  const [scene, idx] = raw.split("/");
  if (!(STORY_SCENE_KEYS as readonly string[]).includes(scene)) return null;
  return {
    scene: scene as StorySceneKey,
    chapitreIndex: idx !== undefined ? Math.max(0, parseInt(idx, 10) || 0) : 0,
  };
}

/** Définit le hash sans recharger la page (replaceState). */
export function setStoryHash(scene: string, chapitreIndex?: number): void {
  const hash = chapitreIndex !== undefined ? `${scene}/${chapitreIndex}` : scene;
  window.history.replaceState(null, "", `#${hash}`);
}

/**
 * Crée un StoryEngine fast-forwardé au chapitre N.
 * Sélectionne automatiquement le premier contrat recommandé de chaque chapitre.
 */
export function createEngineAtChapitre(chapitreIndex: number): StoryEngine {
  const engine = new StoryEngine();
  for (let i = 0; i < chapitreIndex; i++) {
    const chapitre = CHAPITRES[i];
    if (chapitre.recommendedContracts.length > 0) {
      engine.toggleContract(chapitre.recommendedContracts[0] as ContractType);
    }
    engine.resolveCurrentChapitre();
    engine.nextChapitre();
  }
  return engine;
}
