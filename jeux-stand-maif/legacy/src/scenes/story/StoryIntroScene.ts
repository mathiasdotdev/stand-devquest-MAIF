import Phaser from "phaser";
import { StoryEngine } from "../../core/histoire/services/StoryEngine";
import { ConseilleurSprite } from "../../ui/ConseilleurSprite";
import { DialogueBox } from "../../ui/DialogueBox";
import { setStoryHash } from "../../core/histoire/utils/storyDevNav";

/**
 * StoryIntroScene — Premier écran du Mode Histoire.
 * Présentation du conseiller MAIF, mise en contexte générale.
 */
export class StoryIntroScene extends Phaser.Scene {
  private storyEngine!: StoryEngine;
  private dialogueBox!: DialogueBox;
  private conseilleur!: ConseilleurSprite;

  constructor() {
    super("StoryIntroScene");
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    StoryEngine.clearSession();
    this.storyEngine = new StoryEngine();
    setStoryHash("StoryIntroScene");

    // Fond dégradé bleu MAIF
    this.add.rectangle(w / 2, h / 2, w, h, 0x001a4e);
    this.add.rectangle(w / 2, h * 0.7, w, h * 0.6, 0x002266, 0.6);

    // Logo / titre
    this.add
      .text(w / 2, h * 0.12, "🏢 MAIF Runner", {
        fontSize: "36px",
        color: "#ffffff",
        fontStyle: "bold",
        stroke: "#0033aa",
        strokeThickness: 4,
      })
      .setOrigin(0.5);

    this.add
      .text(w / 2, h * 0.22, "Mode Histoire", {
        fontSize: "22px",
        color: "#88bbff",
        fontStyle: "italic",
      })
      .setOrigin(0.5);

    // Conseilleur MAIF : positionné au-dessus à gauche de la bulle
    // bottom du sprite (y+58) aligné sur le haut de la boîte (h*0.82-60)
    this.conseilleur = new ConseilleurSprite(this, -80, h * 0.82 - 100);
    this.conseilleur.setExpression("souriant");
    this.conseilleur.slideIn(-80, 120);

    // Dialogue d'introduction général
    const introLines = [
      {
        text: "Bonjour ! Je suis votre conseiller MAIF. Je serai votre guide tout au long de cette aventure.",
        expression: "souriant" as const,
      },
      {
        text: "Ensemble, nous allons traverser 6 grandes étapes de la vie : voiture, logement, santé...",
        expression: "normal" as const,
      },
      {
        text: "À chaque chapitre, une situation de vie vous est présentée. Votre mission : choisir le bon contrat !",
        expression: "inquiet" as const,
      },
      {
        text: "Vous pouvez utiliser des indices si besoin, mais chaque indice utilisé réduit votre score.",
        expression: "normal" as const,
      },
      { text: "Prêt à tester vos connaissances en assurance ? C'est parti !", expression: "fier" as const },
    ];

    this.dialogueBox = new DialogueBox(this);
    this.dialogueBox.show(introLines, () => this.goToFirstChapitre());

    // Input : espace ou clic pour avancer
    this.input.keyboard!.on("keydown-SPACE", () => this.dialogueBox.advance());
    this.input.keyboard!.on("keydown-ENTER", () => this.dialogueBox.advance());
    this.input.on("pointerdown", () => this.dialogueBox.advance());

    // Fade in
    this.cameras.main.fadeIn(500, 0, 0, 0);
  }

  update(_time: number, delta: number): void {
    this.dialogueBox.update(delta);
    // Expression du conseilleur selon la ligne courante
  }

  private goToFirstChapitre(): void {
    this.cameras.main.fadeOut(400, 0, 0, 0);
    this.cameras.main.once("camerafadeoutcomplete", () => {
      this.scene.start("ChapitreIntroScene", { storyEngine: this.storyEngine });
    });
  }
}
