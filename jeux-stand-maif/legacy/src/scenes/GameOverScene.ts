import Phaser from "phaser";
import type { GameMode } from "../core/shared/models/GameMode";
import { LeaderboardStore } from "../persistence/LeaderboardStore";
import { formatDistance } from "../core/shared/utils/math";
import { CONTRACTS_CONFIG } from "../core/shared/config/contractsConfig";

interface GameOverData {
  mode: GameMode;
  distanceKm: number;
  totalGoldCollected: number;
  totalPremiumsPaid: number;
  totalDisasterDamage: number;
  phase: number;
  bestCombo: number;
  disastersCovered: number;
  disastersUncovered: number;
}

const MAIF_TIPS: string[] = [
  "Un bon assuré anticipe les risques. La prochaine fois, souscrivez tôt !",
  "L'assurance Auto couvre les accidents dès la fin de carence. Pensez-y !",
  "Avec une assurance Habitation Premium, la franchise est nulle. Ça vaut le coup !",
  "Le mode Infini vous permet de tester vos stratégies d'assurance sans limite.",
  "Un sinistre couvert ne casse pas votre combo. Assurez-vous bien !",
  "Plus vous attendez pour souscrire, plus les sinistres font mal.",
  "Chez MAIF, vos adhérents sont au cœur de chaque décision.",
];

export class GameOverScene extends Phaser.Scene {
  private nameInput = "";
  private nameText!: Phaser.GameObjects.Text;
  private data2!: GameOverData;
  private scoreSaved = false;

  constructor() {
    super("GameOverScene");
  }

  init(data: GameOverData): void {
    this.data2 = data;
    this.nameInput = "";
    this.scoreSaved = false;
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;
    const d = this.data2;

    // Fond
    this.add.rectangle(w / 2, h / 2, w, h, 0x000011, 1);

    // Titre
    this.add.text(w / 2, 40, "💸 Ruiné !", {
      fontSize: "42px",
      color: "#ff4444",
      fontStyle: "bold",
    }).setOrigin(0.5);

    this.add.text(w / 2, 88, `Distance parcourue : ${formatDistance(d.distanceKm)}`, {
      fontSize: "20px",
      color: "#ffffff",
    }).setOrigin(0.5);

    // Stats — espacement réduit pour loger le conseil + saisie
    const stats = [
      ["💰 Or collecté",        `${d.totalGoldCollected} 🪙`],
      ["📋 Primes payées",      `-${d.totalPremiumsPaid} 🪙`],
      ["💥 Dommages subis",     `-${d.totalDisasterDamage} 🪙`],
      ["✅ Sinistres couverts", `${d.disastersCovered}`],
      ["❌ Non couverts",       `${d.disastersUncovered}`],
      d.mode === "infinite" ? ["🔥 Meilleur combo", `×${d.bestCombo}`] : ["🎯 Phase atteinte", `Phase ${d.phase}`],
    ];

    stats.forEach(([label, value], i) => {
      const y = 120 + i * 30;
      this.add.text(w / 2 - 160, y, label, { fontSize: "14px", color: "#aabbcc" });
      this.add.text(w / 2 + 160, y, value, { fontSize: "14px", color: "#ffffff" }).setOrigin(1, 0);
    });

    // Séparateur
    this.add.line(w / 2, 308, -200, 0, 200, 0, 0x334455).setLineWidth(1);

    // Conseil MAIF
    const tip = MAIF_TIPS[Math.floor(Math.random() * MAIF_TIPS.length)];
    this.add.text(w / 2, 320, `💡 ${tip}`, {
      fontSize: "12px",
      color: "#88aacc",
      fontStyle: "italic",
      wordWrap: { width: w * 0.72 },
      align: "center",
    }).setOrigin(0.5, 0);

    // Input prénom
    this.add.text(w / 2, 400, "Votre prénom pour le classement :", {
      fontSize: "13px", color: "#cccccc",
    }).setOrigin(0.5);

    this.nameText = this.add.text(w / 2, 424, "[ _ ]", {
      fontSize: "20px", color: "#ffcc00", fontStyle: "bold",
    }).setOrigin(0.5);

    this.add.text(w / 2, 452, "Tapez votre prénom + ENTRÉE pour valider", {
      fontSize: "11px", color: "#667788",
    }).setOrigin(0.5);

    // Capture clavier pour le prénom
    this.input.keyboard!.on("keydown", this.handleKey, this);

    // Boutons
    this.createBtn(w / 2 - 110, h - 42, "🔄 Rejouer", () => {
      this.saveScore(d.mode);
      this.scene.start("PlatformerScene", { mode: d.mode });
    });
    this.createBtn(w / 2 + 110, h - 42, "🏠 Menu", () => {
      this.saveScore(d.mode);
      this.scene.start("MenuScene");
    });
  }

  private handleKey(event: KeyboardEvent): void {
    if (event.key === "Enter") {
      this.saveScore(this.data2.mode);
      return;
    }
    if (event.key === "Backspace") {
      this.nameInput = this.nameInput.slice(0, -1);
    } else if (event.key.length === 1 && this.nameInput.length < 12) {
      this.nameInput += event.key;
    }
    this.nameText.setText(this.nameInput.length > 0 ? `[ ${this.nameInput} ]` : "[ _ ]");
  }

  private saveScore(mode: GameMode): void {
    if (this.scoreSaved) return;
    this.scoreSaved = true;
    const name = this.nameInput.trim() || "Anonyme";
    LeaderboardStore.addEntry({
      name,
      distanceKm: this.data2.distanceKm,
      mode,
      phase: this.data2.phase,
      gold: 0,
      timestamp: Date.now(),
    });
    this.input.keyboard!.off("keydown", this.handleKey, this);
  }

  private createBtn(x: number, y: number, label: string, cb: () => void): void {
    const btn = this.add.rectangle(x, y, 180, 46, 0x0055aa)
      .setInteractive({ useHandCursor: true })
      .setStrokeStyle(2, 0x4499ff);
    const txt = this.add.text(x, y, label, { fontSize: "16px", color: "#ffffff" }).setOrigin(0.5);
    btn.on("pointerover",  () => btn.setFillStyle(0x1166cc));
    btn.on("pointerout",   () => btn.setFillStyle(0x0055aa));
    btn.on("pointerdown",  cb);
    void txt;
  }
}
