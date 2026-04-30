import Phaser from "phaser";
import { CONTRACTS_CONFIG } from "../../core/shared/config/contractsConfig";
import type { ContractType } from "../../core/shared/models/Contract";
import { StoryEngine } from "../../core/histoire/services/StoryEngine";
import { setStoryHash } from "../../core/histoire/utils/storyDevNav";

interface ContractSelectionData {
  storyEngine: StoryEngine;
}

/**
 * ContractSelectionScene — Quiz de sélection de contrat(s).
 * Le joueur peut choisir PLUSIEURS contrats et utiliser jusqu'à 2 indices.
 */
export class ContractSelectionScene extends Phaser.Scene {
  private storyEngine!: StoryEngine;
  private hintText!: Phaser.GameObjects.Text;
  private hintBtn!: Phaser.GameObjects.Rectangle;
  private hintBtnTxt!: Phaser.GameObjects.Text;
  private confirmBtn!: Phaser.GameObjects.Rectangle;
  private confirmTxt!: Phaser.GameObjects.Text;
  private cardBorders: Map<ContractType, Phaser.GameObjects.Rectangle> = new Map();
  private checkMarks: Map<ContractType, Phaser.GameObjects.Text> = new Map();

  constructor() {
    super("ContractSelectionScene");
  }

  init(data: ContractSelectionData): void {
    this.storyEngine = data.storyEngine;
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    const chapitre = this.storyEngine.getCurrentChapitre();
    const state = this.storyEngine.getState();
    setStoryHash("ContractSelectionScene", state.currentChapitre);

    // Fond
    this.add.rectangle(w / 2, h / 2, w, h, 0x000d22);

    // Header
    this.add.rectangle(w / 2, 42, w, 84, 0x001155, 0.95);
    this.add
      .text(w / 2, 16, `Chapitre ${state.currentChapitre + 1} — Choisissez vos assurances`, {
        fontSize: "13px",
        color: "#88aadd",
      })
      .setOrigin(0.5);
    this.add
      .text(w / 2, 46, `${chapitre.emoji}  ${chapitre.titre}`, {
        fontSize: "20px",
        color: "#ffffff",
        fontStyle: "bold",
      })
      .setOrigin(0.5);

    // Question
    this.add
      .text(w / 2, 94, "Quels contrats vous protègent le mieux dans cette situation ?", {
        fontSize: "13px",
        color: "#aaccee",
        fontStyle: "italic",
      })
      .setOrigin(0.5);

    // Cartes de contrats
    const startY = 116;
    const cardH = 56;
    CONTRACTS_CONFIG.forEach((def, i) => {
      const y = startY + i * cardH;
      const bg = this.add
        .rectangle(w / 2, y + cardH / 2 - 2, w * 0.92, cardH - 6, 0x001133, 0.9)
        .setStrokeStyle(1, 0x223355)
        .setInteractive({ useHandCursor: true });
      this.cardBorders.set(def.type, bg);

      this.add.text(w - 80, y + cardH / 2 - 2, def.icon, { fontSize: "20px" }).setOrigin(0.5);
      this.add.text(58, y + 8, def.label, { fontSize: "13px", color: "#ffffff", fontStyle: "bold" });
      this.add.text(58, y + 26, def.levels.basique.description, {
        fontSize: "10px",
        color: "#7799bb",
      });

      // Checkmark (caché par défaut)
      const check = this.add
        .text(w - 46, y + cardH / 2 - 2, "✔", { fontSize: "16px", color: "#44ff88" })
        .setOrigin(0.5)
        .setAlpha(0);
      this.checkMarks.set(def.type, check);

      bg.on("pointerover", () => {
        if (!this.storyEngine.isSelected(def.type)) bg.setFillStyle(0x002244);
      });
      bg.on("pointerout", () => {
        if (!this.storyEngine.isSelected(def.type)) bg.setFillStyle(0x001133);
      });
      bg.on("pointerdown", () => {
        this.sound.play("sfx_click", { volume: 0.4 });
        this.storyEngine.toggleContract(def.type);
        this.refreshCards();
      });
    });

    // Zone indice
    const hintY = startY + CONTRACTS_CONFIG.length * cardH + 6;
    this.add.rectangle(w / 2, hintY + 20, w * 0.88, 40, 0x001122, 0.7).setStrokeStyle(1, 0x223344);
    this.hintText = this.add
      .text(w / 2, hintY + 20, "💡 Utilisez un indice si vous avez besoin d'aide.", {
        fontSize: "11px",
        color: "#778899",
        fontStyle: "italic",
        wordWrap: { width: w * 0.82 },
      })
      .setOrigin(0.5);

    // Boutons
    const btnY = h - 34;
    const hintsLeft = 2 - state.hintsUsedThisChapitre;

    this.hintBtn = this.add
      .rectangle(w / 2 - 130, btnY, 200, 40, 0x221a00)
      .setStrokeStyle(2, 0xaa8822)
      .setInteractive({ useHandCursor: true });
    this.hintBtnTxt = this.add
      .text(w / 2 - 130, btnY, `💡 Indice (${hintsLeft} restant${hintsLeft > 1 ? "s" : ""})`, {
        fontSize: "13px",
        color: "#ffcc44",
      })
      .setOrigin(0.5);

    const hasSelection = state.selectedContracts.length > 0;
    this.confirmBtn = this.add
      .rectangle(w / 2 + 110, btnY, 200, 40, hasSelection ? 0x004422 : 0x111a11)
      .setStrokeStyle(2, hasSelection ? 0x44dd66 : 0x334433)
      .setInteractive({ useHandCursor: hasSelection });

    this.confirmTxt = this.add
      .text(w / 2 + 110, btnY, hasSelection ? "✅ Confirmer mes choix" : "✅ Choisissez d'abord...", {
        fontSize: "13px",
        color: hasSelection ? "#44ff88" : "#445544",
      })
      .setOrigin(0.5);

    this.hintBtn.on("pointerover", () => this.hintBtn.setAlpha(0.75));
    this.hintBtn.on("pointerout", () => this.hintBtn.setAlpha(1));
    this.hintBtn.on("pointerdown", () => this.onHintClick());

    this.confirmBtn.on("pointerover", () => {
      if (this.storyEngine.getState().selectedContracts.length > 0) this.confirmBtn.setAlpha(0.8);
    });
    this.confirmBtn.on("pointerout", () => this.confirmBtn.setAlpha(1));
    this.confirmBtn.on("pointerdown", () => {
      if (this.storyEngine.getState().selectedContracts.length === 0) return;
      this.sound.play("sfx_click", { volume: 0.6 });
      this.goToReveal();
    });

    this.input.keyboard!.on("keydown-ENTER", () => {
      if (this.storyEngine.getState().selectedContracts.length > 0) this.goToReveal();
    });

    this.cameras.main.fadeIn(300, 0, 0, 0);
    this.refreshCards();
  }

  private refreshCards(): void {
    this.cardBorders.forEach((bg, type) => {
      if (this.storyEngine.isSelected(type)) {
        bg.setFillStyle(0x003355).setStrokeStyle(2, 0x44aaff);
      } else {
        bg.setFillStyle(0x001133).setStrokeStyle(1, 0x223355);
      }
    });

    this.checkMarks.forEach((check, type) => {
      check.setAlpha(this.storyEngine.isSelected(type) ? 1 : 0);
    });

    const hasSelection = this.storyEngine.getState().selectedContracts.length > 0;
    if (hasSelection) {
      this.confirmBtn.setFillStyle(0x004422).setStrokeStyle(2, 0x44dd66);
      this.confirmTxt.setText("✅ Confirmer mes choix").setColor("#44ff88");
      this.confirmBtn.setInteractive({ useHandCursor: true });
    } else {
      this.confirmBtn.setFillStyle(0x111a11).setStrokeStyle(2, 0x334433);
      this.confirmTxt.setText("✅ Choisissez d'abord...").setColor("#445544");
      this.confirmBtn.disableInteractive();
    }
  }

  private onHintClick(): void {
    const state = this.storyEngine.getState();
    if (state.hintsUsedThisChapitre >= 2) return;

    this.sound.play("sfx_click", { volume: 0.4 });
    const level = this.storyEngine.useHint();
    const text = this.storyEngine.getHintText();
    this.hintText.setText(`💡 ${text}`).setColor("#ffcc88");

    const hintsLeft = 2 - level;
    if (hintsLeft === 0) {
      this.hintBtnTxt.setText("💡 Plus d'indices").setColor("#554433");
      this.hintBtn.disableInteractive().setFillStyle(0x110e00);
    } else {
      this.hintBtnTxt.setText(`💡 Indice (${hintsLeft} restant)`);
    }
  }

  private goToReveal(): void {
    this.cameras.main.fadeOut(300, 0, 0, 0);
    this.cameras.main.once("camerafadeoutcomplete", () => {
      this.scene.start("DisasterRevealScene", { storyEngine: this.storyEngine });
    });
  }
}
