/**
 * Script de simulation — Étape 1.11 du plan
 * Usage : npm run simulate
 */

import { GameEngine } from "./services/GameEngine";
import type { GameMode } from "../shared/models/GameMode";
import type { ContractType } from "../shared/models/Contract";
import { GAME_CONFIG } from "./config/gameConfig";

type Strategy = "none" | "all" | "optimal";

interface SimResult {
  distanceKm: number;
  durationSeconds: number;
  totalGoldCollected: number;
  totalPremiumsPaid: number;
  totalDisasterDamage: number;
  disastersCovered: number;
  disastersUncovered: number;
}

const DELTA_MS = 100;
const MAX_DURATION_S = 600;
const CONTRACT_TYPES: ContractType[] = ["auto", "habitation", "sante", "vol", "catastrophe"];

function runGame(mode: GameMode, strategy: Strategy): SimResult {
  const engine = new GameEngine(mode);
  let elapsed = 0;
  let lastSegIndex = -1;

  while (elapsed < MAX_DURATION_S * 1000) {
    const state = engine.getState();
    if (state.isGameOver) break;

    const curSeg = state.currentSegmentIndex;
    const isNewSeg = curSeg !== lastSegIndex;

    if (isNewSeg) {
      // Collecte pièces une seule fois par segment (75% collectés)
      for (const zone of state.currentSegment.coins) {
        const count = Math.floor(zone.count * 0.75);
        if (count > 0) engine.collectCoins(count, zone.isAirborne);
      }

      // Stratégie de souscription
      if (curSeg === 1) applyOnce(engine, strategy);
      if (strategy === "optimal" && curSeg === 20) engine.upgradeContract("auto");

      lastSegIndex = curSeg;
    }

    // Fork : prend toujours le chemin 0
    if (state.currentFork && state.currentFork.chosenPathIndex === null) {
      engine.choosePath(0);
    }

    // Ferme l'agence immédiatement
    if (state.isInAgency) engine.closeAgency();

    engine.advance(DELTA_MS);
    elapsed += DELTA_MS;
  }

  const s = engine.getState();
  return {
    distanceKm: s.distanceKm,
    durationSeconds: elapsed / 1000,
    totalGoldCollected: s.totalGoldCollected,
    totalPremiumsPaid: s.totalPremiumsPaid,
    totalDisasterDamage: s.totalDisasterDamage,
    disastersCovered: s.disastersCovered,
    disastersUncovered: s.disastersUncovered,
  };
}

function applyOnce(engine: GameEngine, strategy: Strategy): void {
  if (strategy === "all") {
    for (const type of CONTRACT_TYPES) engine.subscribeContract(type, "basique");
  } else if (strategy === "optimal") {
    engine.subscribeContract("auto", "basique");
    engine.subscribeContract("habitation", "basique");
  }
}

function stats(values: number[]) {
  const sorted = [...values].sort((a, b) => a - b);
  const avg = values.reduce((s, v) => s + v, 0) / values.length;
  return { min: sorted[0], max: sorted[sorted.length - 1], avg, median: sorted[Math.floor(sorted.length / 2)] };
}

function simulate(n: number, mode: GameMode, strategy: Strategy): void {
  const results: SimResult[] = [];
  for (let i = 0; i < n; i++) results.push(runGame(mode, strategy));

  const dur  = stats(results.map((r) => r.durationSeconds));
  const col  = stats(results.map((r) => r.totalGoldCollected));
  const prem = stats(results.map((r) => r.totalPremiumsPaid));
  const dmg  = stats(results.map((r) => r.totalDisasterDamage));
  const timeout = results.filter((r) => r.durationSeconds >= MAX_DURATION_S).length;

  const f = (v: number, d = 0) => v.toFixed(d);
  console.log(`\n  mode:${mode.padEnd(8)} stratégie:${strategy.padEnd(7)} n=${n}`);
  console.log(`    Durée   : avg=${f(dur.avg,1)}s  med=${f(dur.median,1)}s  [${f(dur.min,0)}-${f(dur.max,0)}]  timeout=${timeout}`);
  console.log(`    Or/seg  : avg=${f(col.avg / Math.max(1, results[0].distanceKm / GAME_CONFIG.SEGMENT_LENGTH_KM),1)} 🪙`);
  console.log(`    Primes  : avg=${f(prem.avg)} 🪙   Dommages: avg=${f(dmg.avg)} 🪙`);
  console.log(`    Sinistres couverts avg=${stats(results.map(r => r.disastersCovered)).avg.toFixed(1)}  non couverts avg=${stats(results.map(r => r.disastersUncovered)).avg.toFixed(1)}`);

  if (timeout > n * 0.5)   console.log(`    ❌ TROP LONG → baisser STARTING_GOLD ou monter dommages`);
  else if (dur.avg < 60)   console.log(`    ❌ TROP COURT → monter STARTING_GOLD ou baisser dommages`);
  else if (dur.avg < 120)  console.log(`    ⚠️  UN PEU COURT (cible 120-300s)`);
  else                     console.log(`    ✅ OK (cible 120-300s)`);
}

// ─── Théorie ──────────────────────────────────────────────────────────────────
const segsPerSec = (GAME_CONFIG.SCROLL_SPEED_PX / GAME_CONFIG.PIXELS_PER_KM) / GAME_CONFIG.SEGMENT_LENGTH_KM;
const coinsPerSeg = ((GAME_CONFIG.COINS_PER_SEGMENT_MIN + GAME_CONFIG.COINS_PER_SEGMENT_MAX) / 2) * 0.75;
const goldPerSeg = coinsPerSeg * GAME_CONFIG.COIN_GROUND_VALUE;

console.log("🎮 MAIF Runner — Simulation d'équilibrage");
console.log("==========================================");
console.log(`\nThéorie (${GAME_CONFIG.STARTING_GOLD}🪙 de départ) :`);
console.log(`  Vitesse     : ${segsPerSec.toFixed(3)} seg/s → 1 seg ≈ ${(1/segsPerSec).toFixed(1)}s`);
console.log(`  Or/seg      : ~${goldPerSeg.toFixed(1)} 🪙  (${coinsPerSeg.toFixed(1)} pièces × ${GAME_CONFIG.COIN_GROUND_VALUE})`);
console.log(`  Or/tick (×5 segs) : ~${(goldPerSeg * 5).toFixed(0)} 🪙`);
console.log(`  Primes all basique/tick : ${14+11+9+7+6} 🪙`);
console.log(`  Dommage moyen non couvert (ph1, 12% × 5 segs × 75🪙) : ~${(0.12 * 5 * 75).toFixed(0)} 🪙/tick`);

// ─── Simulations ──────────────────────────────────────────────────────────────
const N = 300;
console.log(`\n${"─".repeat(56)}`);
simulate(N, "story",    "none");
simulate(N, "story",    "all");
simulate(N, "story",    "optimal");
simulate(N, "infinite", "none");
simulate(N, "infinite", "optimal");

console.log(`\n${"─".repeat(56)}`);
console.log("✅ Fait. Si les durées sont hors cible → ajuster gameConfig.ts");
