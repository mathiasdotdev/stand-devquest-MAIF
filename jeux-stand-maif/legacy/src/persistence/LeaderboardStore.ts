import type { GameMode } from "../core/shared/models/GameMode";

export interface LeaderboardEntry {
  name: string;
  distanceKm: number;
  mode: GameMode;
  phase: number;
  gold: number;
  timestamp: number;
}

const STORAGE_KEY_STORY = "maif-runner-leaderboard-story";
const STORAGE_KEY_INFINITE = "maif-runner-leaderboard-infinite";
const MAX_ENTRIES = 10;

function storageKey(mode: GameMode): string {
  return mode === "story" ? STORAGE_KEY_STORY : STORAGE_KEY_INFINITE;
}

export class LeaderboardStore {
  static getEntries(mode: GameMode): LeaderboardEntry[] {
    try {
      const raw = localStorage.getItem(storageKey(mode));
      return raw ? (JSON.parse(raw) as LeaderboardEntry[]) : [];
    } catch {
      return [];
    }
  }

  /** Ajoute une entrée et retourne le rang + si elle est dans le top 10. */
  static addEntry(entry: LeaderboardEntry): { rank: number; isTopTen: boolean } {
    const entries = this.getEntries(entry.mode);
    entries.push(entry);
    entries.sort((a, b) => b.distanceKm - a.distanceKm);

    const rank = entries.findIndex((e) => e === entry) + 1;
    const topTen = entries.slice(0, MAX_ENTRIES);

    try {
      localStorage.setItem(storageKey(entry.mode), JSON.stringify(topTen));
    } catch {
      // localStorage indisponible
    }

    return { rank, isTopTen: rank <= MAX_ENTRIES };
  }

  static clear(mode: GameMode): void {
    try {
      localStorage.removeItem(storageKey(mode));
    } catch {
      // ignore
    }
  }
}
