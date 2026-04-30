import Phaser from "phaser";
import { CHAPITRES } from "../../core/histoire/config/chapitresConfig";
import { CONTRACTS_CONFIG } from "../../core/shared/config/contractsConfig";
import { DISASTERS_CONFIG } from "../../core/shared/config/disastersConfig";
import type { QuizAnswer } from "../../core/histoire/models/StoryState";
import { StoryEngine } from "../../core/histoire/services/StoryEngine";
import { setStoryHash } from "../../core/histoire/utils/storyDevNav";

interface ChapitreResultData {
  storyEngine: StoryEngine;
  result: QuizAnswer;
}

/**
 * ChapitreResultScene — Explication pédagogique après un chapitre.
 * Montre si le(s) choix étaient corrects et pourquoi.
 */
export class ChapitreResultScene extends Phaser.Scene {
  private storyEngine!: StoryEngine;
  private result!: QuizAnswer;

  constructor() {
    super("ChapitreResultScene");
  }

  init(data: ChapitreResultData): void {
    this.storyEngine = data.storyEngine;
    this.result = data.result;
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    const chapitre = CHAPITRES[this.result.chapitreId];
    const state = this.storyEngine.getState();
    setStoryHash("ChapitreResultScene", this.result.chapitreId);

    this.cameras.main.fadeIn(300, 0, 0, 0);

    // Fond
    this.add.rectangle(w / 2, h / 2, w, h, 0x000d22);

    // Header
    this.add.rectangle(w / 2, 38, w, 76, 0x001155, 0.95);
    this.add
      .text(w / 2, 16, `Bilan — ${chapitre.emoji} ${chapitre.titre}`, {
        fontSize: "18px",
        color: "#aaccff",
        fontStyle: "bold",
      })
      .setOrigin(0.5);

    // Score gagné ce chapitre
    const scoreColor = this.result.isCorrect ? "#44ff88" : "#ff4444";
    const scoreLabel = this.result.isCorrect
      ? `+${this.result.scoreEarned} pt${this.result.scoreEarned > 1 ? "s" : ""}`
      : "0 pt";
    this.add
      .text(w / 2, 46, `${this.result.isCorrect ? "✅" : "❌"} ${scoreLabel} — Score total : ${state.totalScore} pts`, {
        fontSize: "14px",
        color: scoreColor,
      })
      .setOrigin(0.5);

    // Calcul isPerfect : tous les bons contrats sélectionnés, aucun mauvais
    const totalNeeded = this.result.correctContracts.length;
    const isPerfect = this.result.correctCount === totalNeeded && this.result.wrongCount === 0;

    // Verdict
    const verdictY = 110;
    const verdictBg = isPerfect ? 0x003311 : this.result.isCorrect ? 0x221a00 : 0x220000;
    const verdictBorder = isPerfect ? 0x44cc66 : this.result.isCorrect ? 0xffcc44 : 0xff4444;
    this.add.rectangle(w / 2, verdictY, w * 0.88, 60, verdictBg, 0.9).setStrokeStyle(2, verdictBorder);

    // Labels des contrats choisis
    const chosenLabels = this.result.chosenContracts
      .map((ct) => {
        const def = CONTRACTS_CONFIG.find((c) => c.type === ct);
        return def ? `${def.icon} ${def.label}` : ct;
      })
      .join(", ");
    const correctDef = CONTRACTS_CONFIG.find((c) => c.type === this.result.correctContracts[0]);

    const hintNote =
      this.result.hintsUsed > 0 ? ` (${this.result.hintsUsed} indice${this.result.hintsUsed > 1 ? "s" : ""})` : "";

    if (isPerfect) {
      this.add
        .text(w / 2, verdictY - 10, `✅ Parfait ! ${chosenLabels}${hintNote}`, {
          fontSize: "13px",
          color: "#44ff88",
          fontStyle: "bold",
          wordWrap: { width: w * 0.82 },
        })
        .setOrigin(0.5);
      this.add
        .text(w / 2, verdictY + 10, "Tous les contrats adaptés à cette situation.", {
          fontSize: "11px",
          color: "#88ccaa",
          fontStyle: "italic",
        })
        .setOrigin(0.5);
    } else if (this.result.isCorrect) {
      this.add
        .text(w / 2, verdictY - 10, `🟡 Pas mal ! ${chosenLabels}${hintNote}`, {
          fontSize: "13px",
          color: "#ffcc44",
          fontStyle: "bold",
          wordWrap: { width: w * 0.82 },
        })
        .setOrigin(0.5);
      const correctLabels = this.result.correctContracts
        .map((ct) => CONTRACTS_CONFIG.find((c) => c.type === ct)?.label ?? ct)
        .join(", ");
      this.add
        .text(w / 2, verdictY + 10, `Couverture partielle — idéal : ${correctLabels}`, {
          fontSize: "11px",
          color: "#ccaa44",
          fontStyle: "italic",
          wordWrap: { width: w * 0.8 },
        })
        .setOrigin(0.5);
    } else {
      const chosenStr = this.result.chosenContracts.length > 0 ? `Vos choix : ${chosenLabels}` : "Aucun contrat choisi";
      this.add
        .text(w / 2, verdictY - 10, `❌ ${chosenStr}`, {
          fontSize: "13px",
          color: "#ff6666",
          fontStyle: "bold",
          wordWrap: { width: w * 0.82 },
        })
        .setOrigin(0.5);
      this.add
        .text(
          w / 2,
          verdictY + 10,
          `Le bon contrat : ${correctDef?.icon ?? ""} ${correctDef?.label ?? this.result.correctContracts[0]}`,
          { fontSize: "12px", color: "#ffaa44", wordWrap: { width: w * 0.82 } },
        )
        .setOrigin(0.5);
    }

    // Explication — ce que couvre le bon contrat
    const explanationY = 158;
    if (correctDef) {
      this.add.rectangle(w / 2, explanationY + 14, w * 0.9, 40, 0x001133, 0.8).setStrokeStyle(1, 0x334466);
      this.add.text(
        w * 0.06,
        explanationY,
        `${correctDef.icon} ${correctDef.label} couvre : ${correctDef.coversDisasters.map((d) => DISASTERS_CONFIG[d].label).join(", ")}`,
        { fontSize: "12px", color: "#88bbff" },
      );
      this.add.text(w * 0.06, explanationY + 18, correctDef.levels.basique.description, {
        fontSize: "11px",
        color: "#556688",
        fontStyle: "italic",
      });
    }

    // Tableau des sinistres
    const rowH = 34;
    const tableY = 216;
    const hits = this.result.disasterHits;
    const tableH = hits.length === 0 ? 38 : hits.length * rowH + 10;

    this.add.rectangle(w / 2, tableY + tableH / 2, w * 0.9, tableH + 4, 0x001133, 0.8).setStrokeStyle(1, 0x223355);

    if (hits.length === 0) {
      this.add
        .text(w / 2, tableY + 20, "🍀 Aucun sinistre ce chapitre !", {
          fontSize: "13px",
          color: "#44ff88",
        })
        .setOrigin(0.5);
    } else {
      hits.forEach((hit, i) => {
        const def = DISASTERS_CONFIG[hit.type];
        const y = tableY + 8 + i * rowH;
        const color = hit.wasCovered ? "#44ff88" : "#ff4444";
        const label = hit.wasCovered
          ? `${def.icon} ${def.label} — ✅ Couvert`
          : `${def.icon} ${def.label} — ❌ Non couvert`;
        this.add.text(w * 0.06, y, label, { fontSize: "12px", color });
        this.add.text(w * 0.06, y + 14, hit.narrative, {
          fontSize: "9px",
          color: "#667788",
          wordWrap: { width: w * 0.82 },
        });
      });
    }

    // Conseils de prévention
    const tipsY = tableY + tableH + 22;
    if (chapitre.preventionTips.length > 0) {
      this.add
        .text(w / 2, tipsY, "💡 Conseils de prévention", {
          fontSize: "12px",
          color: "#ffdd88",
          fontStyle: "bold",
        })
        .setOrigin(0.5);
      chapitre.preventionTips.slice(0, 2).forEach((tip, i) => {
        this.add
          .text(w / 2, tipsY + 18 + i * 18, `${tip.emoji} ${tip.tip}`, {
            fontSize: "10px",
            color: "#bbccaa",
            fontStyle: "italic",
            wordWrap: { width: w * 0.82 },
          })
          .setOrigin(0.5);
      });
    }

    // Bouton suivant
    const isLastChapitre = this.result.chapitreId >= CHAPITRES.length - 1;
    const btnLabel = isLastChapitre ? "🔍 Voir l'analyse finale" : "→ Chapitre suivant";
    const btnColor = isLastChapitre ? 0x442200 : 0x003355;
    const btnBorder = isLastChapitre ? 0xff8844 : 0x44aaff;

    const nextBtn = this.add
      .rectangle(w / 2, h - 34, 260, 40, btnColor)
      .setStrokeStyle(2, btnBorder)
      .setInteractive({ useHandCursor: true });
    this.add
      .text(w / 2, h - 34, btnLabel, {
        fontSize: "15px",
        color: isLastChapitre ? "#ffaa66" : "#66ccff",
        fontStyle: "bold",
      })
      .setOrigin(0.5);

    nextBtn.on("pointerover", () => nextBtn.setAlpha(0.8));
    nextBtn.on("pointerout", () => nextBtn.setAlpha(1));
    nextBtn.on("pointerdown", () => {
      this.sound.play("sfx_click", { volume: 0.5 });
      this.cameras.main.fadeOut(300, 0, 0, 0);
      this.cameras.main.once("camerafadeoutcomplete", () => {
        if (isLastChapitre) {
          this.storyEngine.saveToSession();
          this.scene.start("StoryAnalysisScene", { storyEngine: this.storyEngine });
        } else {
          this.storyEngine.nextChapitre();
          this.storyEngine.saveToSession();
          this.scene.start("ChapitreIntroScene", { storyEngine: this.storyEngine });
        }
      });
    });

    this.input.keyboard!.on("keydown-ENTER", () => nextBtn.emit("pointerdown"));
  }
}
