import Phaser from "phaser";
import type { GameState } from "../core/infini/models/GameState";
import { formatDistance, formatGold } from "../core/shared/utils/math";
import { CONTRACTS_CONFIG } from "../core/shared/config/contractsConfig";

export class HUD {
  private scene: Phaser.Scene;
  private goldText!: Phaser.GameObjects.Text;
  private distanceText!: Phaser.GameObjects.Text;
  private phaseText!: Phaser.GameObjects.Text;
  private contractsText!: Phaser.GameObjects.Text;
  private tickBarBg!: Phaser.GameObjects.Rectangle;
  private tickBar!: Phaser.GameObjects.Rectangle;
  private comboText!: Phaser.GameObjects.Text;
  private pauseOverlay!: Phaser.GameObjects.Container;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.create();
  }

  private create(): void {
    const w = this.scene.scale.width;
    const h = this.scene.scale.height;

    // Fond HUD (semi-transparent)
    this.scene.add.rectangle(w / 2, 36, w, 72, 0x000000, 0.65).setDepth(20).setScrollFactor(0);

    // Or
    this.goldText = this.scene.add.text(12, 8, "💰 350", {
      fontSize: "18px",
      color: "#ffcc00",
      fontStyle: "bold",
    }).setDepth(21).setScrollFactor(0);

    // Distance
    this.distanceText = this.scene.add.text(w / 2, 8, "0 m", {
      fontSize: "18px",
      color: "#aaddff",
    }).setOrigin(0.5, 0).setDepth(21).setScrollFactor(0);

    // Phase
    this.phaseText = this.scene.add.text(w - 12, 8, "Phase 1", {
      fontSize: "14px",
      color: "#ffaa44",
    }).setOrigin(1, 0).setDepth(21).setScrollFactor(0);

    // Contrats
    this.contractsText = this.scene.add.text(12, 38, "Contrats : aucun", {
      fontSize: "11px",
      color: "#88bbcc",
    }).setDepth(21).setScrollFactor(0);

    // Barre de tick
    const barY = 64;
    this.scene.add.text(12, barY - 2, "Prochain tick :", {
      fontSize: "10px",
      color: "#667788",
    }).setDepth(21).setScrollFactor(0);
    this.tickBarBg = this.scene.add.rectangle(140 + 75, barY + 4, 150, 10, 0x334455)
      .setDepth(21).setScrollFactor(0);
    this.tickBar = this.scene.add.rectangle(140, barY + 4, 0, 10, 0x44aaff)
      .setOrigin(0, 0.5).setDepth(22).setScrollFactor(0);

    // Combo (mode infini, affiché en haut à droite)
    this.comboText = this.scene.add.text(w - 12, 30, "", {
      fontSize: "14px",
      color: "#ff9933",
      fontStyle: "bold",
    }).setOrigin(1, 0).setDepth(21).setScrollFactor(0);

    // Overlay Pause
    this.createPauseOverlay(w, h);
  }

  update(state: GameState): void {
    const w = this.scene.scale.width;

    // Or (rouge si < 100)
    const goldColor = state.gold < 100 ? "#ff4444" : "#ffcc00";
    this.goldText.setText(`💰 ${Math.floor(state.gold)}`).setColor(goldColor);

    // Distance
    this.distanceText.setText(formatDistance(state.distanceKm));

    // Phase
    const PHASE_LABELS: Record<number, string> = {
      1: "Banlieue",
      2: "Centre-ville",
      3: "Zone industrielle",
    };
    const phaseLabel = PHASE_LABELS[state.phase] ?? "Légendaire";
    this.phaseText.setText(`Ph.${state.phase} ${phaseLabel} | ${state.currentSegmentIndex}`);

    // Contrats actifs
    const contractLabels = CONTRACTS_CONFIG.map((def) => {
      const active = state.activeContracts.find((c) => c.type === def.type);
      const pending = state.pendingContracts.find((c) => c.type === def.type);
      if (active) return `${def.icon}✅`;
      if (pending) return `${def.icon}⏳`;
      return `${def.icon}❌`;
    }).join("  ");
    this.contractsText.setText(`Contrats : ${contractLabels || "aucun"}`);

    // Barre tick (remplie selon segmentsSinceLastTick / TICK_INTERVAL)
    const TICK_INTERVAL = 5;
    const tickPct = state.segmentsSinceLastTick / TICK_INTERVAL;
    this.tickBar.width = Math.floor(150 * Math.min(tickPct, 1));
    this.tickBar.setFillStyle(tickPct > 0.8 ? 0xff6633 : 0x44aaff);

    // Combo (mode infini)
    if (state.mode === "infinite" && state.combo > 0) {
      this.comboText.setText(`🔥 ×${state.combo}`);
    } else {
      this.comboText.setText("");
    }

    // Clignotement or bas
    if (state.gold < 80) {
      const flash = Math.floor(Date.now() / 300) % 2 === 0;
      this.goldText.setAlpha(flash ? 1 : 0.4);
    } else {
      this.goldText.setAlpha(1);
    }
  }

  showPauseOverlay(): void {
    this.pauseOverlay.setVisible(true);
  }

  hidePauseOverlay(): void {
    this.pauseOverlay.setVisible(false);
  }

  private createPauseOverlay(w: number, h: number): void {
    this.pauseOverlay = this.scene.add.container(0, 0).setDepth(50).setScrollFactor(0).setVisible(false);

    const bg = this.scene.add.rectangle(w / 2, h / 2, w, h, 0x000000, 0.7);
    const txt = this.scene.add.text(w / 2, h / 2 - 40, "⏸ PAUSE", {
      fontSize: "48px",
      color: "#ffffff",
      fontStyle: "bold",
    }).setOrigin(0.5);
    const hint = this.scene.add.text(w / 2, h / 2 + 20, "Appuyez sur ÉCHAP pour reprendre", {
      fontSize: "18px",
      color: "#aaaaaa",
    }).setOrigin(0.5);

    // Bouton Menu principal
    const btnBg = this.scene.add.rectangle(w / 2, h / 2 + 80, 220, 46, 0x333355)
      .setInteractive({ useHandCursor: true })
      .setStrokeStyle(2, 0x6677aa);
    const btnTxt = this.scene.add.text(w / 2, h / 2 + 80, "Menu principal", {
      fontSize: "18px",
      color: "#ccddff",
    }).setOrigin(0.5);

    btnBg.on("pointerover",  () => btnBg.setFillStyle(0x4455aa));
    btnBg.on("pointerout",   () => btnBg.setFillStyle(0x333355));
    btnBg.on("pointerdown",  () => {
      this.scene.sound.play("sfx_click", { volume: 0.5 });
      this.scene.scene.start("MenuScene");
    });

    this.pauseOverlay.add([bg, txt, hint, btnBg, btnTxt]);
  }
}
