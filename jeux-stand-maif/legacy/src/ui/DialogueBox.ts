import Phaser from "phaser";
import type { DialogueLine } from "../core/histoire/models/Chapitre";

/**
 * Bulle de dialogue style BD avec effet typewriter.
 * Utilisée dans toutes les scènes du Mode Histoire.
 */
export class DialogueBox {
  private scene: Phaser.Scene;
  private container!: Phaser.GameObjects.Container;
  private bg!: Phaser.GameObjects.Rectangle;
  private border!: Phaser.GameObjects.Rectangle;
  private text!: Phaser.GameObjects.Text;
  private continueHint!: Phaser.GameObjects.Text;

  private lines: DialogueLine[] = [];
  private currentLine = 0;
  private currentChar = 0;
  private typewriterTimer = 0;
  private readonly CHAR_DELAY_MS = 28;
  private isComplete = false;
  private onFinished?: () => void;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.create();
  }

  private create(): void {
    const w = this.scene.scale.width;
    const h = this.scene.scale.height;

    // Fond de la bulle (centre à 82% de la hauteur)
    const boxCY = h * 0.82;
    const boxH = 120;
    this.bg = this.scene.add.rectangle(w / 2, boxCY, w * 0.82, boxH, 0xffffff, 0.97);
    this.bg.setStrokeStyle(3, 0x111122);

    // Texte
    this.text = this.scene.add.text(w * 0.5 - w * 0.38, boxCY - boxH / 2 + 12, "", {
      fontSize: "16px",
      color: "#111122",
      wordWrap: { width: w * 0.76 },
      lineSpacing: 6,
    });

    // "Continuer" hint
    this.continueHint = this.scene.add.text(w * 0.5 + w * 0.38, boxCY + boxH / 2 - 14, "▶ Continuer", {
      fontSize: "12px",
      color: "#0044aa",
      fontStyle: "italic",
    }).setOrigin(1, 0.5).setAlpha(0);

    this.container = this.scene.add.container(0, 0, [this.bg, this.text, this.continueHint]);
    this.container.setDepth(50).setScrollFactor(0).setVisible(false);
  }

  /** Démarre l'affichage d'une liste de lignes de dialogue. */
  show(lines: DialogueLine[], onFinished?: () => void): void {
    this.lines = lines;
    this.currentLine = 0;
    this.currentChar = 0;
    this.typewriterTimer = 0;
    this.isComplete = false;
    this.onFinished = onFinished;
    this.container.setVisible(true);
    this.continueHint.setAlpha(0);
    this.displayCurrentLine();
  }

  hide(): void {
    this.container.setVisible(false);
  }

  private displayCurrentLine(): void {
    if (this.currentLine >= this.lines.length) {
      this.isComplete = true;
      this.onFinished?.();
      return;
    }
    this.text.setText("");
    this.currentChar = 0;
    this.continueHint.setAlpha(0);
  }

  update(delta: number): void {
    if (!this.container.visible || this.isComplete) return;
    const line = this.lines[this.currentLine];
    if (!line) return;

    const fullText = line.text;
    if (this.currentChar < fullText.length) {
      this.typewriterTimer += delta;
      while (this.typewriterTimer >= this.CHAR_DELAY_MS && this.currentChar < fullText.length) {
        this.typewriterTimer -= this.CHAR_DELAY_MS;
        this.currentChar++;
      }
      this.text.setText(fullText.slice(0, this.currentChar));
    } else {
      // Ligne complète : montrer "Continuer"
      this.continueHint.setAlpha(Math.floor(Date.now() / 400) % 2 === 0 ? 1 : 0.3);
    }
  }

  /** Avance à la ligne suivante (ou complète instantanément la ligne actuelle). */
  advance(): void {
    if (this.isComplete) return;
    const line = this.lines[this.currentLine];
    if (!line) return;

    if (this.currentChar < line.text.length) {
      // Compléter instantanément la ligne actuelle
      this.currentChar = line.text.length;
      this.text.setText(line.text);
      this.continueHint.setAlpha(1);
    } else {
      // Passer à la ligne suivante
      this.currentLine++;
      this.displayCurrentLine();
    }
  }

  isVisible(): boolean {
    return this.container.visible;
  }

  isDialogueComplete(): boolean {
    return this.isComplete;
  }
}
