/**
 * Utilitaires de génération aléatoire.
 * Utilise Math.random() pour l'instant (seedable si besoin de replay plus tard).
 */

/** Retourne un float dans [min, max[ */
export function randomFloat(min: number, max: number): number {
  return min + Math.random() * (max - min);
}

/** Retourne un entier dans [min, max] inclus */
export function randomInt(min: number, max: number): number {
  return Math.floor(min + Math.random() * (max - min + 1));
}

/** Retourne true avec une probabilité p (0-1) */
export function chance(p: number): boolean {
  return Math.random() < p;
}

/** Choisit un élément aléatoire dans un tableau */
export function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

/** Mélange un tableau (Fisher-Yates) */
export function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/** Choisit un élément selon des poids (weights doit avoir la même longueur que items) */
export function weightedPick<T>(items: T[], weights: number[]): T {
  const total = weights.reduce((a, b) => a + b, 0);
  let r = Math.random() * total;
  for (let i = 0; i < items.length; i++) {
    r -= weights[i];
    if (r <= 0) return items[i];
  }
  return items[items.length - 1];
}
