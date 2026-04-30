import Phaser from "phaser";
import { CHAPITRES } from "../../core/histoire/config/chapitresConfig";
import { CONTRACTS_CONFIG } from "../../core/shared/config/contractsConfig";
import { DISASTERS_CONFIG } from "../../core/shared/config/disastersConfig";
import type { QuizAnswer } from "../../core/histoire/models/StoryState";
import { StoryEngine } from "../../core/histoire/services/StoryEngine";
import { setStoryHash } from "../../core/histoire/utils/storyDevNav";
import { ConseilleurSprite } from "../../ui/ConseilleurSprite";

interface StoryAnalysisData {
  storyEngine: StoryEngine;
}

/**
 * StoryAnalysisScene — Analyse finale du Mode Histoire (quiz).
 * Navigation par flèches ← → entre les chapitres.
 */
export class StoryAnalysisScene extends Phaser.Scene {
  private storyEngine!: StoryEngine;
  private conseilleur!: ConseilleurSprite;
  private currentPage = 0;
  private uniqueAnswers: QuizAnswer[] = [];
  private cardObjects: Phaser.GameObjects.GameObject[] = [];
  private pageLabel!: Phaser.GameObjects.Text;
  private prevArrow!: Phaser.GameObjects.Text;
  private nextArrow!: Phaser.GameObjects.Text;
  private cardY = 0;
  private cardH = 0;
  private w = 0;

  constructor() {
    super("StoryAnalysisScene");
  }

  init(data: StoryAnalysisData): void {
    this.storyEngine = data.storyEngine;
  }

  create(): void {
    this.w = this.scale.width;
    const h = this.scale.height;
    const w = this.w;
    const analysis = this.storyEngine.getAnalysis();
    setStoryHash("StoryAnalysisScene");

    // ── Fond + header ─────────────────────────────────────────────────────────
    this.add.rectangle(w / 2, h / 2, w, h, 0x000a1e);
    this.add.rectangle(w / 2, 38, w, 60, 0x001155, 0.95);
    this.add
      .text(w / 2, 16, "🔍 Analyse de votre parcours assurantiel", {
        fontSize: "17px",
        color: "#88aaff",
        fontStyle: "bold",
      })
      .setOrigin(0.5);
    this.add
      .text(w / 2, 46, "par votre conseiller MAIF", {
        fontSize: "12px",
        color: "#556688",
        fontStyle: "italic",
      })
      .setOrigin(0.5);

    // ── Conseilleur + Score ───────────────────────────────────────────────────
    const pct = analysis.totalScore / analysis.maxScore;
    const expression = pct >= 0.7 ? "fier" : pct >= 0.45 ? "normal" : "inquiet";
    this.conseilleur = new ConseilleurSprite(this, w / 2 - 100, h / 4 - 10);
    this.conseilleur.setExpression(expression);

    const scoreColor = pct >= 0.7 ? 0x44ff88 : pct >= 0.45 ? 0xffcc44 : 0xff4444;
    const scoreHex = "#" + scoreColor.toString(16).padStart(6, "0");
    this.add.rectangle(w * 0.65, 128, 260, 100, 0x001133, 0.9).setStrokeStyle(3, scoreColor);
    this.add.text(w * 0.65, 94, "Score final", { fontSize: "13px", color: "#aabbcc" }).setOrigin(0.5);
    this.add
      .text(w * 0.65, 130, `${analysis.totalScore} / ${analysis.maxScore}`, {
        fontSize: "25px",
        color: scoreHex,
        fontStyle: "bold",
      })
      .setOrigin(0.5);
    this.add
      .text(w * 0.65, 155, analysis.label, { fontSize: "14px", color: scoreHex, fontStyle: "italic" })
      .setOrigin(0.5);

    // ── Navigation chapitres ──────────────────────────────────────────────────
    const navY = 214;
    this.cardY = 234;
    this.cardH = 200;

    if (analysis.answers.length === 0) {
      this.add.rectangle(w / 2, this.cardY + this.cardH / 2, w * 0.9, this.cardH, 0x001122, 0.85).setStrokeStyle(1, 0x223355);
      this.add
        .text(w / 2, this.cardY + this.cardH / 2, "Aucune réponse enregistrée.", {
          fontSize: "13px",
          color: "#556688",
          fontStyle: "italic",
        })
        .setOrigin(0.5);
    } else {
      // Barre de navigation
      this.add.rectangle(w / 2, navY, w * 0.9, 22, 0x001133, 0.8).setStrokeStyle(1, 0x334466);

      this.prevArrow = this.add
        .text(w * 0.07, navY, "◀", { fontSize: "14px", color: "#88aaff" })
        .setOrigin(0.5)
        .setInteractive({ useHandCursor: true });

      this.nextArrow = this.add
        .text(w * 0.93, navY, "▶", { fontSize: "14px", color: "#88aaff" })
        .setOrigin(0.5)
        .setInteractive({ useHandCursor: true });

      this.pageLabel = this.add.text(w / 2, navY, "", { fontSize: "12px", color: "#aaccee" }).setOrigin(0.5);

      // Keyboard navigation
      this.input.keyboard!.on("keydown-LEFT", () => this.navigate(-1));
      this.input.keyboard!.on("keydown-RIGHT", () => this.navigate(1));
      this.prevArrow.on("pointerdown", () => this.navigate(-1));
      this.nextArrow.on("pointerdown", () => this.navigate(1));
      this.prevArrow.on("pointerover", () => this.prevArrow.setColor("#ffffff"));
      this.prevArrow.on("pointerout", () => this.prevArrow.setColor("#88aaff"));
      this.nextArrow.on("pointerover", () => this.nextArrow.setColor("#ffffff"));
      this.nextArrow.on("pointerout", () => this.nextArrow.setColor("#88aaff"));

      // Dédupliquer par chapitreId
      const seen = new Set<number>();
      for (const ans of analysis.answers) {
        if (!seen.has(ans.chapitreId)) {
          seen.add(ans.chapitreId);
          this.uniqueAnswers.push(ans);
        }
      }

      // Afficher la première page
      this.buildCardContent(this.uniqueAnswers[0]);
      this.updateNav();
    }

    // ── Meilleur / pire décision ──────────────────────────────────────────────
    const summaryY = this.cardY + this.cardH + 14;
    this.add.rectangle(w / 2, summaryY + 20, w * 0.9, 44, 0x001122, 0.85).setStrokeStyle(1, 0x223355);
    this.add.text(w * 0.06, summaryY + 6, `👍 ${analysis.bestChoice}`, {
      fontSize: "10px",
      color: "#66ff88",
      wordWrap: { width: w * 0.88 },
    });
    this.add.text(w * 0.06, summaryY + 22, `👎 ${analysis.worstChoice}`, {
      fontSize: "10px",
      color: "#ff9966",
      wordWrap: { width: w * 0.88 },
    });

    // ── Boutons ───────────────────────────────────────────────────────────────
    const rejouerBtn = this.add
      .rectangle(w / 2 - 140, h - 30, 220, 40, 0x002244)
      .setStrokeStyle(2, 0x4488cc)
      .setInteractive({ useHandCursor: true });
    this.add.text(w / 2 - 140, h - 30, "🔄 Rejouer l'histoire", { fontSize: "13px", color: "#66aaff" }).setOrigin(0.5);

    const menuBtn = this.add
      .rectangle(w / 2 + 140, h - 30, 220, 40, 0x221100)
      .setStrokeStyle(2, 0xaa6633)
      .setInteractive({ useHandCursor: true });
    this.add.text(w / 2 + 140, h - 30, "🏠 Menu principal", { fontSize: "13px", color: "#cc8855" }).setOrigin(0.5);

    rejouerBtn.on("pointerover", () => rejouerBtn.setAlpha(0.75));
    rejouerBtn.on("pointerout", () => rejouerBtn.setAlpha(1));
    rejouerBtn.on("pointerdown", () => {
      this.sound.play("sfx_click", { volume: 0.5 });
      this.cameras.main.fadeOut(300, 0, 0, 0);
      this.cameras.main.once("camerafadeoutcomplete", () => this.scene.start("StoryIntroScene"));
    });

    menuBtn.on("pointerover", () => menuBtn.setAlpha(0.75));
    menuBtn.on("pointerout", () => menuBtn.setAlpha(1));
    menuBtn.on("pointerdown", () => {
      this.sound.play("sfx_click", { volume: 0.5 });
      this.cameras.main.fadeOut(300, 0, 0, 0);
      this.cameras.main.once("camerafadeoutcomplete", () => this.scene.start("MenuScene"));
    });

    this.cameras.main.fadeIn(500, 0, 0, 0);
  }

  // ── Construction du contenu de la carte courante ──────────────────────────

  private buildCardContent(ans: QuizAnswer): void {
    const w = this.w;
    const cardY = this.cardY;
    const cardH = this.cardH;
    const chapitre = CHAPITRES[ans.chapitreId];
    const isPerfect = ans.correctCount === ans.correctContracts.length && ans.wrongCount === 0;

    const borderColor = isPerfect ? 0x44cc66 : ans.isCorrect ? 0xffcc44 : 0xff4444;
    const titleColor = isPerfect ? "#44ff88" : ans.isCorrect ? "#ffcc44" : "#ff6666";
    const verdict = isPerfect ? "✅" : ans.isCorrect ? "🟡" : "❌";

    const bg = this.add.rectangle(w / 2, cardY + cardH / 2, w * 0.9, cardH, 0x001122, 0.9).setStrokeStyle(2, borderColor);
    this.cardObjects.push(bg);

    // Titre chapitre + verdict
    const title = this.add.text(w * 0.06, cardY + 10, `${verdict} ${chapitre.emoji} Ch.${ans.chapitreId + 1} — ${chapitre.titre}`, {
      fontSize: "14px",
      color: titleColor,
      fontStyle: "bold",
    });
    this.cardObjects.push(title);

    // Score + indices (droite)
    const scoreStr = ans.isCorrect ? `+${ans.scoreEarned} pt${ans.scoreEarned > 1 ? "s" : ""}` : "0 pt";
    const hintStr = ans.hintsUsed > 0 ? `  💡×${ans.hintsUsed}` : "";
    const scoreText = this.add
      .text(w * 0.94, cardY + 10, scoreStr + hintStr, {
        fontSize: "13px",
        color: ans.isCorrect ? "#44ff88" : "#ff6666",
        fontStyle: "bold",
      })
      .setOrigin(1, 0);
    this.cardObjects.push(scoreText);

    // Contrats choisis
    const choisisLabel = this.add.text(w * 0.06, cardY + 36, "Choisis :", { fontSize: "11px", color: "#778899" });
    this.cardObjects.push(choisisLabel);

    if (ans.chosenContracts.length === 0) {
      const aucun = this.add.text(w * 0.06 + 66, cardY + 36, "aucun", { fontSize: "11px", color: "#556688" });
      this.cardObjects.push(aucun);
    } else {
      let xOff = w * 0.06 + 66;
      ans.chosenContracts.forEach((ct) => {
        const def = CONTRACTS_CONFIG.find((c) => c.type === ct);
        const isGood = ans.correctContracts.includes(ct);
        const icon = this.add.text(xOff, cardY + 33, def?.icon ?? ct, {
          fontSize: "17px",
          color: isGood ? "#44ff88" : "#ff4444",
        });
        this.cardObjects.push(icon);
        xOff += 26;
      });
    }

    // Contrats recommandés
    const recStr = ans.correctContracts
      .map((ct) => {
        const def = CONTRACTS_CONFIG.find((c) => c.type === ct);
        return def ? `${def.icon} ${def.label}` : ct;
      })
      .join(", ");
    const recText = this.add.text(w * 0.06, cardY + 62, `Recommandés : ${recStr}`, {
      fontSize: "11px",
      color: "#7799bb",
    });
    this.cardObjects.push(recText);

    // Contrats manqués
    const missing = ans.correctContracts.filter((ct) => !ans.chosenContracts.includes(ct));
    if (missing.length > 0) {
      const missStr = missing.map((ct) => CONTRACTS_CONFIG.find((c) => c.type === ct)?.label ?? ct).join(", ");
      const missText = this.add.text(w * 0.06, cardY + 80, `⚠ Manqués : ${missStr}`, {
        fontSize: "11px",
        color: "#ffaa44",
        wordWrap: { width: w * 0.85 },
      });
      this.cardObjects.push(missText);
    }

    // Séparateur
    const sep = this.add.rectangle(w / 2, cardY + 100, w * 0.84, 1, 0x334466, 0.6);
    this.cardObjects.push(sep);

    // Sinistres
    const hits = ans.disasterHits;
    if (hits.length === 0) {
      const noHit = this.add
        .text(w / 2, cardY + 120, "🍀 Aucun sinistre ce chapitre — vous avez eu de la chance !", {
          fontSize: "12px",
          color: "#44bb66",
        })
        .setOrigin(0.5);
      this.cardObjects.push(noHit);
    } else {
      hits.slice(0, 4).forEach((hit, j) => {
        const def = DISASTERS_CONFIG[hit.type];
        const color = hit.wasCovered ? "#44ff88" : "#ff5555";
        const str = hit.wasCovered
          ? `${def.icon} ${def.label} — ✅ couvert`
          : `${def.icon} ${def.label} — ❌ non couvert`;
        const hitText = this.add.text(w * 0.06, cardY + 110 + j * 26, str, {
          fontSize: "11px",
          color,
        });
        this.cardObjects.push(hitText);
        if (hit.narrative && j < 3) {
          const narr = this.add.text(w * 0.06 + 10, cardY + 124 + j * 26, hit.narrative, {
            fontSize: "9px",
            color: "#556677",
            wordWrap: { width: w * 0.82 },
          });
          this.cardObjects.push(narr);
        }
      });
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  private navigate(dir: -1 | 1): void {
    if (this.uniqueAnswers.length === 0) return;

    // Détruire les objets de la carte courante
    for (const obj of this.cardObjects) {
      obj.destroy();
    }
    this.cardObjects = [];

    this.currentPage = (this.currentPage + dir + this.uniqueAnswers.length) % this.uniqueAnswers.length;

    // Reconstruire la nouvelle carte
    this.buildCardContent(this.uniqueAnswers[this.currentPage]);
    this.updateNav();
    this.sound.play("sfx_click", { volume: 0.3 });
  }

  private updateNav(): void {
    const total = this.uniqueAnswers.length;
    if (total === 0) return;
    const chapitre = CHAPITRES[this.uniqueAnswers[this.currentPage].chapitreId];
    this.pageLabel.setText(`${chapitre.emoji} Ch.${this.uniqueAnswers[this.currentPage].chapitreId + 1} / ${total}`);
    this.prevArrow.setAlpha(this.currentPage > 0 ? 1 : 0.25);
    this.nextArrow.setAlpha(this.currentPage < total - 1 ? 1 : 0.25);
  }
}
