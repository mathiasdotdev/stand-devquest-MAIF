import Phaser from "phaser";
import { GAME_CONFIG } from "../core/infini/config/gameConfig";
import type { ContractType } from "../core/shared/models/Contract";
import { GameEngine } from "../core/infini/services/GameEngine";

// Valeurs par défaut — pour le bouton Reset
const DEFAULTS = {
  STARTING_GOLD: 350,
  SCROLL_SPEED_PX: 200,
  TICK_INTERVAL: 5,
  DISASTER_PROB_1: 0.12,
  DAMAGE_MULT: 1.0, // multiplicateur appliqué aux 3 phases
} as const;

// Multiplicateur de dégâts de base par phase (avant DAMAGE_MULT)
const BASE_DAMAGE_MULTS: Record<1 | 2 | 3, number> = { 1: 1.0, 2: 1.5, 3: 2.5 };
// Ratio des probs de sinistre entre phases (pour scaling cohérent)
const DISASTER_RATIOS: Record<1 | 2 | 3, number> = { 1: 1.0, 2: 1.83, 3: 3.17 };

const SIM_N_DEFAULT = 50; // nombre de parties par simulation (rapide en-browser)
const DELTA_MS = 200;
const MAX_S = 600;
const CONTRACT_TYPES: ContractType[] = ["auto", "habitation", "sante", "vol", "catastrophe"];

export class AdminScene extends Phaser.Scene {
  private damageMult: number = DEFAULTS.DAMAGE_MULT;
  private simN: number = SIM_N_DEFAULT;
  private simNText!: Phaser.GameObjects.Text;
  private paramRows: ParamRow[] = [];
  private resultText!: Phaser.GameObjects.Text;
  private simBtn!: Phaser.GameObjects.Rectangle;
  private simBtnText!: Phaser.GameObjects.Text;

  constructor() {
    super("AdminScene");
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    // Fond + panneaux en premier (pour ne pas couvrir les textes)
    this.add.rectangle(w / 2, h / 2, w, h, 0x050510, 0.97);

    const col1X = 60;
    const col1W = 360;
    const panelTop = 62;
    const panelH = h - 130;
    this.add.rectangle(col1X + col1W / 2, panelTop + panelH / 2, col1W, panelH, 0x111122, 0.9)
      .setStrokeStyle(1, 0x334488);

    // col2 aussi en fond
    const col2X = 450;
    const col2W = w - col2X - 20;
    this.add.rectangle(col2X + col2W / 2, panelTop + panelH / 2, col2W, panelH, 0x111122, 0.9)
      .setStrokeStyle(1, 0x334488);

    // Titres par-dessus les panneaux
    this.add
      .text(w / 2, 12, "⚙️  Panel Admin", {
        fontSize: "20px",
        color: "#ffdd88",
        fontStyle: "bold",
      })
      .setOrigin(0.5, 0);

    this.add
      .text(w / 2, 38, "Les modifications s'appliquent à la prochaine partie", {
        fontSize: "11px",
        color: "#aabbcc",
      })
      .setOrigin(0.5, 0);

    this.add.text(col1X + 16, panelTop + 8, "Paramètres", {
      fontSize: "13px",
      color: "#aabbdd",
      fontStyle: "bold",
    });

    const params: ParamDef[] = [
      {
        label: "Or de départ",
        get: () => GAME_CONFIG.STARTING_GOLD,
        set: (v) => {
          GAME_CONFIG.STARTING_GOLD = v;
        },
        step: 50,
        min: 100,
        max: 1000,
        fmt: (v) => `${v} 🪙`,
      },
      {
        label: "Vitesse scroll (px/s)",
        get: () => GAME_CONFIG.SCROLL_SPEED_PX,
        set: (v) => {
          GAME_CONFIG.SCROLL_SPEED_PX = v;
        },
        step: 20,
        min: 60,
        max: 400,
        fmt: (v) => `${v}`,
      },
      {
        label: "Intervalle tick (seg)",
        get: () => GAME_CONFIG.TICK_INTERVAL,
        set: (v) => {
          GAME_CONFIG.TICK_INTERVAL = v;
        },
        step: 1,
        min: 2,
        max: 15,
        fmt: (v) => `${v}`,
      },
      {
        label: "Prob. sinistre ph.1",
        get: () => GAME_CONFIG.DISASTER_PROB[1],
        set: (v) => {
          GAME_CONFIG.DISASTER_PROB[1] = +v.toFixed(2);
          GAME_CONFIG.DISASTER_PROB[2] = +(v * DISASTER_RATIOS[2]).toFixed(2);
          GAME_CONFIG.DISASTER_PROB[3] = +(v * DISASTER_RATIOS[3]).toFixed(2);
        },
        step: 0.02,
        min: 0,
        max: 0.6,
        fmt: (v) => `${(v * 100).toFixed(0)}%`,
      },
      {
        label: "Mult. dommages",
        get: () => this.damageMult,
        set: (v) => {
          this.damageMult = v;
          ([1, 2, 3] as const).forEach((p) => {
            GAME_CONFIG.DAMAGE_MULTIPLIER[p] = +(BASE_DAMAGE_MULTS[p] * v).toFixed(2);
          });
        },
        step: 0.1,
        min: 0.2,
        max: 4.0,
        fmt: (v) => `×${v.toFixed(1)}`,
      },
      {
        label: "1ère agence (seg)",
        get: () => GAME_CONFIG.FIRST_AGENCY_SEGMENT,
        set: (v) => {
          GAME_CONFIG.FIRST_AGENCY_SEGMENT = v;
        },
        step: 1,
        min: 1,
        max: 20,
        fmt: (v) => `${v}`,
      },
    ];

    params.forEach((def, i) => {
      const row = new ParamRow(this, col1X + 16, panelTop + 32 + i * 56, col1W - 32, def);
      this.paramRows.push(row);
    });

    // ── Boutons actions ──────────────────────────────────────────────────
    const btnY = h - 42;

    this.createBtn(col1X + 80, btnY, "↩ Reset défauts", 0x444422, () => this.resetDefaults());
    this.createBtn(col1X + 280, btnY, "← Retour", 0x222244, () => this.scene.start("MenuScene"));

    // ── Zone simulation (colonne droite) ─────────────────────────────────
    this.add.text(col2X + 16, panelTop + 8, "Simulation", {
      fontSize: "13px",
      color: "#aabbdd",
      fontStyle: "bold",
    });

    // Contrôle nombre de parties
    this.add.text(col2X + 16, panelTop + 28, "Nb de parties", { fontSize: "11px", color: "#88aacc" });

    const simNBtnW = 28, simNBtnH = 24;
    const simNValX = col2X + col2W / 2;
    const simNBtnMX = col2X + col2W - simNBtnW * 2 - 8;
    const simNBtnPX = col2X + col2W - simNBtnW - 4;

    const btnSimNMinus = this.add
      .rectangle(simNBtnMX, panelTop + 46, simNBtnW, simNBtnH, 0x332222)
      .setStrokeStyle(1, 0x884444)
      .setInteractive({ useHandCursor: true });
    this.add.text(simNBtnMX, panelTop + 46, "−", { fontSize: "16px", color: "#ff8888" }).setOrigin(0.5);
    btnSimNMinus.on("pointerdown", () => {
      this.simN = Math.max(10, this.simN - 10);
      this.simNText.setText(`${this.simN}`);
      this.simBtnText.setText(`▶  Simuler ${this.simN} parties`);
    });
    btnSimNMinus.on("pointerover", () => btnSimNMinus.setFillStyle(0x553333));
    btnSimNMinus.on("pointerout", () => btnSimNMinus.setFillStyle(0x332222));

    this.simNText = this.add
      .text(simNValX, panelTop + 46, `${this.simN}`, { fontSize: "14px", color: "#ffdd44", fontStyle: "bold" })
      .setOrigin(0.5);

    const btnSimNPlus = this.add
      .rectangle(simNBtnPX, panelTop + 46, simNBtnW, simNBtnH, 0x223322)
      .setStrokeStyle(1, 0x448844)
      .setInteractive({ useHandCursor: true });
    this.add.text(simNBtnPX, panelTop + 46, "+", { fontSize: "16px", color: "#88ff88" }).setOrigin(0.5);
    btnSimNPlus.on("pointerdown", () => {
      this.simN = Math.min(500, this.simN + 10);
      this.simNText.setText(`${this.simN}`);
      this.simBtnText.setText(`▶  Simuler ${this.simN} parties`);
    });
    btnSimNPlus.on("pointerover", () => btnSimNPlus.setFillStyle(0x335533));
    btnSimNPlus.on("pointerout", () => btnSimNPlus.setFillStyle(0x223322));

    this.add.line(col2X + col2W / 2, panelTop + 62, 0, 0, col2W, 0, 0x223344, 0.4).setOrigin(0.5);

    this.simBtn = this.add
      .rectangle(col2X + col2W / 2, panelTop + 82, col2W - 40, 32, 0x004422)
      .setStrokeStyle(1, 0x44aa66)
      .setInteractive({ useHandCursor: true })
      .on("pointerover", () => this.simBtn.setFillStyle(0x006633))
      .on("pointerout", () => this.simBtn.setFillStyle(0x004422))
      .on("pointerdown", () => this.runSimulation());

    this.simBtnText = this.add
      .text(col2X + col2W / 2, panelTop + 82, `▶  Simuler ${this.simN} parties`, {
        fontSize: "13px",
        color: "#88ffaa",
      })
      .setOrigin(0.5);

    this.resultText = this.add.text(col2X + 16, panelTop + 106, "Cliquez sur Simuler pour lancer\nles calculs d'équilibrage.", {
      fontSize: "11px",
      color: "#556677",
      lineSpacing: 4,
    });

    this.cameras.main.fadeIn(200, 0, 0, 0);
  }

  // ── Simulation inline ──────────────────────────────────────────────────

  private runSimulation(): void {
    this.simBtnText.setText("⏳ Calcul en cours...");
    this.simBtn.disableInteractive();

    // Décale d'une frame pour que le texte se mette à jour avant le calcul
    this.time.delayedCall(50, () => {
      const lines: string[] = [];

      const n = this.simN;
      const run = (mode: "story" | "infinite", strategy: "none" | "all" | "optimal") => {
        const durations: number[] = [];
        for (let i = 0; i < n; i++) {
          durations.push(this.simOneGame(mode, strategy));
        }
        const avg = durations.reduce((s, v) => s + v, 0) / n;
        const min = Math.min(...durations);
        const max = Math.max(...durations);
        const timeouts = durations.filter((d) => d >= MAX_S).length;
        const ok = avg >= 120 && avg < MAX_S * 0.8;
        const icon = ok ? "✅" : avg < 60 ? "❌ court" : timeouts > n * 0.3 ? "❌ long" : "⚠️";
        lines.push(`${icon} ${mode}/${strategy}`);
        lines.push(`   avg ${avg.toFixed(0)}s  [${min.toFixed(0)}-${max.toFixed(0)}]  t/o:${timeouts}`);
      };

      run("story", "none");
      run("story", "all");
      run("story", "optimal");
      run("infinite", "none");
      run("infinite", "optimal");

      this.resultText.setText(lines.join("\n"));
      this.simBtnText.setText(`▶  Re-simuler ${this.simN} parties`);
      this.simBtn.setInteractive({ useHandCursor: true });
    });
  }

  private simOneGame(mode: "story" | "infinite", strategy: "none" | "all" | "optimal"): number {
    const engine = new GameEngine(mode);
    let elapsed = 0;
    let lastSeg = -1;

    while (elapsed < MAX_S * 1000) {
      const state = engine.getState();
      if (state.isGameOver) break;

      const seg = state.currentSegmentIndex;
      if (seg !== lastSeg) {
        for (const z of state.currentSegment.coins) {
          const n = Math.floor(z.count * 0.75);
          if (n > 0) engine.collectCoins(n, z.isAirborne);
        }
        if (seg === 1) {
          if (strategy === "all") {
            CONTRACT_TYPES.forEach((t) => engine.subscribeContract(t, "basique"));
          } else if (strategy === "optimal") {
            engine.subscribeContract("auto", "basique");
            engine.subscribeContract("habitation", "basique");
          }
        }
        lastSeg = seg;
      }

      if (state.currentFork?.chosenPathIndex === null) engine.choosePath(0);
      if (state.isInAgency) engine.closeAgency();

      engine.advance(DELTA_MS);
      elapsed += DELTA_MS;
    }

    return elapsed / 1000;
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  private resetDefaults(): void {
    GAME_CONFIG.STARTING_GOLD = DEFAULTS.STARTING_GOLD;
    GAME_CONFIG.SCROLL_SPEED_PX = DEFAULTS.SCROLL_SPEED_PX;
    GAME_CONFIG.TICK_INTERVAL = DEFAULTS.TICK_INTERVAL;
    GAME_CONFIG.DISASTER_PROB[1] = DEFAULTS.DISASTER_PROB_1;
    GAME_CONFIG.DISASTER_PROB[2] = +(DEFAULTS.DISASTER_PROB_1 * DISASTER_RATIOS[2]).toFixed(2);
    GAME_CONFIG.DISASTER_PROB[3] = +(DEFAULTS.DISASTER_PROB_1 * DISASTER_RATIOS[3]).toFixed(2);
    this.damageMult = DEFAULTS.DAMAGE_MULT;
    ([1, 2, 3] as const).forEach((p) => {
      GAME_CONFIG.DAMAGE_MULTIPLIER[p] = BASE_DAMAGE_MULTS[p];
    });
    GAME_CONFIG.FIRST_AGENCY_SEGMENT = 8;
    this.paramRows.forEach((r) => r.refresh());
  }

  private createBtn(x: number, y: number, label: string, color: number, cb: () => void): void {
    const btn = this.add
      .rectangle(x, y, 160, 30, color)
      .setStrokeStyle(1, 0x4466aa)
      .setInteractive({ useHandCursor: true })
      .on("pointerdown", cb);
    this.add.text(x, y, label, { fontSize: "12px", color: "#aabbdd" }).setOrigin(0.5);
    void btn;
  }
}

// ── Classe helper pour une ligne de paramètre ──────────────────────────────

interface ParamDef {
  label: string;
  get: () => number;
  set: (v: number) => void;
  step: number;
  min: number;
  max: number;
  fmt: (v: number) => string;
}

class ParamRow {
  private scene: Phaser.Scene;
  private def: ParamDef;
  private valueText: Phaser.GameObjects.Text;

  constructor(scene: Phaser.Scene, x: number, y: number, w: number, def: ParamDef) {
    this.scene = scene;
    this.def = def;

    scene.add.text(x, y, def.label, { fontSize: "11px", color: "#88aacc" });

    const btnW = 28,
      btnH = 24;
    const valX = x + w / 2;
    const btnPX = x + w - btnW * 2 - 8;
    const btnNX = x + w - btnW - 4;

    // Bouton −
    const btnMinus = scene.add
      .rectangle(btnPX, y + 22, btnW, btnH, 0x332222)
      .setStrokeStyle(1, 0x884444)
      .setInteractive({ useHandCursor: true });
    scene.add.text(btnPX, y + 22, "−", { fontSize: "16px", color: "#ff8888" }).setOrigin(0.5);
    btnMinus.on("pointerdown", () => {
      def.set(this.clamp(def.get() - def.step));
      this.refresh();
    });
    btnMinus.on("pointerover", () => btnMinus.setFillStyle(0x553333));
    btnMinus.on("pointerout", () => btnMinus.setFillStyle(0x332222));

    // Valeur
    this.valueText = scene.add
      .text(valX, y + 22, def.fmt(def.get()), {
        fontSize: "14px",
        color: "#ffdd44",
        fontStyle: "bold",
      })
      .setOrigin(0.5);

    // Bouton +
    const btnPlus = scene.add
      .rectangle(btnNX, y + 22, btnW, btnH, 0x223322)
      .setStrokeStyle(1, 0x448844)
      .setInteractive({ useHandCursor: true });
    scene.add.text(btnNX, y + 22, "+", { fontSize: "16px", color: "#88ff88" }).setOrigin(0.5);
    btnPlus.on("pointerdown", () => {
      def.set(this.clamp(def.get() + def.step));
      this.refresh();
    });
    btnPlus.on("pointerover", () => btnPlus.setFillStyle(0x335533));
    btnPlus.on("pointerout", () => btnPlus.setFillStyle(0x223322));

    // Séparateur
    scene.add.line(x + w / 2, y + 42, 0, 0, w, 0, 0x223344, 0.4).setOrigin(0.5);

    void scene;
  }

  refresh(): void {
    this.valueText.setText(this.def.fmt(this.def.get()));
  }

  private clamp(v: number): number {
    const rounded = Math.round(v / this.def.step) * this.def.step;
    return Math.max(this.def.min, Math.min(this.def.max, +rounded.toFixed(4)));
  }
}
