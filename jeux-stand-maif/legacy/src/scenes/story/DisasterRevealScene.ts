import Phaser from "phaser";
import { CONTRACTS_CONFIG } from "../../core/shared/config/contractsConfig";
import { DISASTERS_CONFIG } from "../../core/shared/config/disastersConfig";
import type { QuizAnswer } from "../../core/histoire/models/StoryState";
import { StoryEngine } from "../../core/histoire/services/StoryEngine";
import { setStoryHash } from "../../core/histoire/utils/storyDevNav";

interface DisasterRevealData {
  storyEngine: StoryEngine;
}

/**
 * DisasterRevealScene — Révèle les sinistres du chapitre un par un.
 * Montre si les contrats choisis auraient couvert chaque sinistre.
 */
export class DisasterRevealScene extends Phaser.Scene {
  private storyEngine!: StoryEngine;
  private result!: QuizAnswer;

  constructor() {
    super("DisasterRevealScene");
  }

  init(data: DisasterRevealData): void {
    this.storyEngine = data.storyEngine;
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;
    const chapitre = this.storyEngine.getCurrentChapitre();
    const state = this.storyEngine.getState();
    setStoryHash("DisasterRevealScene", state.currentChapitre);

    // Résoudre le chapitre et sauvegarder la progression
    this.result = this.storyEngine.resolveCurrentChapitre();
    this.storyEngine.saveToSession();

    // Fond sombre dramatique
    this.add.rectangle(w / 2, h / 2, w, h, 0x000811);

    // Titre
    this.add.rectangle(w / 2, 36, w, 72, 0x1a0000, 0.9);
    this.add
      .text(w / 2, 16, `${chapitre.emoji}  ${chapitre.titre}`, {
        fontSize: "18px",
        color: "#ff9955",
        fontStyle: "bold",
      })
      .setOrigin(0.5);
    this.add
      .text(w / 2, 46, "Les événements du chapitre se déroulent...", {
        fontSize: "13px",
        color: "#888888",
        fontStyle: "italic",
      })
      .setOrigin(0.5);

    // Contrats choisis
    const chosenLabels =
      this.result.chosenContracts.length > 0
        ? this.result.chosenContracts
            .map((ct) => {
              const def = CONTRACTS_CONFIG.find((c) => c.type === ct);
              return def ? `${def.icon} ${def.label}` : ct;
            })
            .join(", ")
        : "Aucun contrat sélectionné";
    const choiceLabel = `Vos choix : ${chosenLabels}`;

    this.add.rectangle(w / 2, 100, w * 0.85, 40, 0x001133, 0.8).setStrokeStyle(1, 0x334466);
    this.add
      .text(w / 2, 100, choiceLabel, {
        fontSize: "12px",
        color: "#88bbff",
        wordWrap: { width: w * 0.8 },
      })
      .setOrigin(0.5);

    this.cameras.main.fadeIn(400, 0, 0, 0);

    if (this.result.disasterHits.length === 0) {
      this.time.delayedCall(600, () => this.showNoDisasterMessage());
    } else {
      this.revealDisastersSequentially();
    }
  }

  private revealDisastersSequentially(): void {
    const w = this.scale.width;
    const h = this.scale.height;
    const hits = this.result.disasterHits;
    const startY = 170;
    const spacing = Math.min(90, (h - startY - 80) / Math.max(hits.length, 1));

    hits.forEach((hit, i) => {
      const def = DISASTERS_CONFIG[hit.type];
      const y = startY + i * spacing;

      this.time.delayedCall(500 + i * 1600, () => {
        if (hit.wasCovered) {
          this.cameras.main.flash(200, 0, 150, 50, false);
        } else {
          this.cameras.main.flash(200, 200, 0, 0, false);
          this.cameras.main.shake(250, 0.005);
        }

        const color = hit.wasCovered ? 0x003311 : 0x220000;
        const borderColor = hit.wasCovered ? 0x44cc66 : 0xff3333;
        const cardLeft = Math.round(w / 2 - w * 0.41);

        const card = this.add
          .rectangle(w / 2, y, w * 0.82, spacing - 8, color, 0.95)
          .setStrokeStyle(2, borderColor)
          .setAlpha(0);
        const icon = this.add
          .text(cardLeft + 22, y, def.icon, { fontSize: "26px" })
          .setOrigin(0.5)
          .setAlpha(0);
        const titleTxt = this.add
          .text(cardLeft + 50, y - 22, def.label, {
            fontSize: "13px",
            color: "#ffffff",
            fontStyle: "bold",
          })
          .setAlpha(0);
        const narrativeTxt = this.add
          .text(cardLeft + 50, y - 4, hit.narrative, {
            fontSize: "10px",
            color: "#cccccc",
            wordWrap: { width: w * 0.58 },
          })
          .setAlpha(0);

        const coverageColor = hit.wasCovered ? "#44ff88" : "#ff4444";
        const coverageStr = hit.wasCovered ? "✅ Couvert par votre assurance" : "❌ Non couvert";
        const coverageTxt = this.add
          .text(cardLeft + 50, y + 22, coverageStr, {
            fontSize: "12px",
            color: coverageColor,
            fontStyle: "bold",
          })
          .setAlpha(0);

        this.tweens.add({
          targets: [card, icon, titleTxt, narrativeTxt, coverageTxt],
          alpha: 1,
          duration: 350,
          ease: "Power2",
        });

        if (i === hits.length - 1) {
          this.time.delayedCall(1800, () => this.showContinueButton());
        }
      });
    });
  }

  private showNoDisasterMessage(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    this.add.rectangle(w / 2, h / 2, w * 0.7, 80, 0x003311, 0.95).setStrokeStyle(2, 0x44cc66);
    this.add
      .text(w / 2, h / 2, "🍀 Aucun sinistre ce chapitre !\nVous avez eu de la chance.", {
        fontSize: "16px",
        color: "#44ff88",
        fontStyle: "bold",
        align: "center",
        wordWrap: { width: 400 },
      })
      .setOrigin(0.5);

    this.cameras.main.flash(300, 0, 150, 50, false);
    this.time.delayedCall(1200, () => this.showContinueButton());
  }

  private showContinueButton(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    const btn = this.add
      .rectangle(w / 2, h - 34, 260, 42, 0x003355)
      .setStrokeStyle(2, 0x44aaff)
      .setInteractive({ useHandCursor: true });
    this.add
      .text(w / 2, h - 34, "→ Voir l'explication", {
        fontSize: "16px",
        color: "#66ccff",
        fontStyle: "bold",
      })
      .setOrigin(0.5);

    btn.on("pointerover", () => btn.setFillStyle(0x004477));
    btn.on("pointerout", () => btn.setFillStyle(0x003355));
    btn.on("pointerdown", () => {
      this.sound.play("sfx_click", { volume: 0.5 });
      this.cameras.main.fadeOut(300, 0, 0, 0);
      this.cameras.main.once("camerafadeoutcomplete", () => {
        this.scene.start("ChapitreResultScene", {
          storyEngine: this.storyEngine,
          result: this.result,
        });
      });
    });

    this.input.keyboard!.on("keydown-ENTER", () => btn.emit("pointerdown"));
    this.input.keyboard!.on("keydown-SPACE", () => btn.emit("pointerdown"));
  }
}
