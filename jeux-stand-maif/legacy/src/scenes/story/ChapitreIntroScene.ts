import Phaser from "phaser";
import { CHAPITRES } from "../../core/histoire/config/chapitresConfig";
import { StoryEngine } from "../../core/histoire/services/StoryEngine";
import { ConseilleurSprite } from "../../ui/ConseilleurSprite";
import { DialogueBox } from "../../ui/DialogueBox";
import { setStoryHash } from "../../core/histoire/utils/storyDevNav";

interface ChapitreIntroData {
  storyEngine: StoryEngine;
}

/**
 * ChapitreIntroScene — Introduction d'un chapitre de vie.
 * Présente le contexte et prépare le joueur au quiz de sélection de contrat.
 */
export class ChapitreIntroScene extends Phaser.Scene {
  private storyEngine!: StoryEngine;
  private dialogueBox!: DialogueBox;
  private conseilleur!: ConseilleurSprite;

  constructor() {
    super("ChapitreIntroScene");
  }

  init(data: ChapitreIntroData): void {
    this.storyEngine = data.storyEngine;
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    const chapitre = this.storyEngine.getCurrentChapitre();
    const state = this.storyEngine.getState();
    const totalChapitres = CHAPITRES.length;
    setStoryHash("ChapitreIntroScene", state.currentChapitre);

    // Fond
    this.add.rectangle(w / 2, h / 2, w, h, 0x001133);

    // Header chapitre
    this.add.rectangle(w / 2, 42, w, 84, 0x002266, 0.9);
    this.add.text(w / 2, 18, `Chapitre ${state.currentChapitre + 1} / ${totalChapitres}`, {
      fontSize: "13px", color: "#88aadd",
    }).setOrigin(0.5);
    this.add.text(w / 2, 46, `${chapitre.emoji}  ${chapitre.titre}`, {
      fontSize: "26px", color: "#ffffff", fontStyle: "bold",
      stroke: "#0033aa", strokeThickness: 3,
    }).setOrigin(0.5);

    // Contexte
    this.add.rectangle(w / 2, h * 0.27, w * 0.76, 90, 0x001144, 0.8).setStrokeStyle(1, 0x336699);
    this.add.text(w / 2, h * 0.27, chapitre.contexte, {
      fontSize: "14px", color: "#aaccee",
      wordWrap: { width: w * 0.7 }, align: "center",
    }).setOrigin(0.5);

    // Score actuel
    const maxScore = totalChapitres * 3;
    this.add.text(w / 2, h * 0.45, `Score : ${state.totalScore} / ${maxScore} pts`, {
      fontSize: "14px", color: "#ffcc44", fontStyle: "bold",
    }).setOrigin(0.5);

    // Consigne quiz
    this.add.text(w / 2, h * 0.52,
      "Choisissez le contrat d'assurance le plus adapté à cette situation.",
      { fontSize: "12px", color: "#aabbcc", fontStyle: "italic" }
    ).setOrigin(0.5);

    // Conseilleur
    this.conseilleur = new ConseilleurSprite(this, -80, h * 0.82 - 100);
    this.conseilleur.setExpression(chapitre.intro[0]?.expression ?? "normal");
    this.conseilleur.slideIn(-80, 120);

    // Dialogue
    this.dialogueBox = new DialogueBox(this);
    this.dialogueBox.show(chapitre.intro, () => this.goToContracts());

    // Input
    this.input.keyboard!.on("keydown-SPACE", () => this.dialogueBox.advance());
    this.input.keyboard!.on("keydown-ENTER", () => this.dialogueBox.advance());
    this.input.on("pointerdown", () => this.dialogueBox.advance());

    // Bouton "Passer"
    const skipBtn = this.add.text(w - 16, h - 16, "Passer →", {
      fontSize: "12px", color: "#556677", fontStyle: "italic",
    }).setOrigin(1).setInteractive({ useHandCursor: true });
    skipBtn.on("pointerover", () => skipBtn.setColor("#aabbcc"));
    skipBtn.on("pointerout", () => skipBtn.setColor("#556677"));
    skipBtn.on("pointerdown", () => this.goToContracts());

    this.cameras.main.fadeIn(400, 0, 0, 0);
  }

  update(_time: number, delta: number): void {
    this.dialogueBox.update(delta);
  }

  private goToContracts(): void {
    this.cameras.main.fadeOut(300, 0, 0, 0);
    this.cameras.main.once("camerafadeoutcomplete", () => {
      this.scene.start("ContractSelectionScene", { storyEngine: this.storyEngine });
    });
  }
}
