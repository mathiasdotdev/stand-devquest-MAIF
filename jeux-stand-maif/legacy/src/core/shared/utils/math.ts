/** Contraint une valeur entre min et max */
export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

/** Interpolation linéaire */
export function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * clamp(t, 0, 1);
}

/** Arrondi à N décimales */
export function round(value: number, decimals = 2): number {
  const factor = Math.pow(10, decimals);
  return Math.round(value * factor) / factor;
}

/** Formate un nombre en or : "125 🪙" */
export function formatGold(amount: number): string {
  return `${Math.floor(amount)} 🪙`;
}

/** Formate une distance en km : "3.2 km" */
export function formatDistance(km: number): string {
  if (km < 1) return `${Math.floor(km * 1000)} m`;
  return `${km.toFixed(1)} km`;
}
