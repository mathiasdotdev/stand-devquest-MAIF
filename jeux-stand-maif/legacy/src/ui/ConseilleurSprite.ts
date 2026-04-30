import Phaser from "phaser";

export type ConseilleurExpression = "normal" | "souriant" | "inquiet" | "fier";

/**
 * Personnage conseiller MAIF pixelart (généré procéduralement).
 * Affiché dans les scènes du Mode Histoire.
 */
export class ConseilleurSprite {
  private scene: Phaser.Scene;
  private container!: Phaser.GameObjects.Container;
  private body!: Phaser.GameObjects.Rectangle;
  private head!: Phaser.GameObjects.Rectangle;
  private mouth!: Phaser.GameObjects.Text;
  private eyeLeft!: Phaser.GameObjects.Rectangle;
  private eyeRight!: Phaser.GameObjects.Rectangle;
  private badge!: Phaser.GameObjects.Text;

  constructor(scene: Phaser.Scene, x: number, y: number) {
    this.scene = scene;
    this.create(x, y);
  }

  private create(x: number, y: number): void {
    // Corps (chemise bleue MAIF)
    this.body = this.scene.add.rectangle(0, 30, 44, 56, 0x0055bb);
    // Tête
    this.head = this.scene.add.rectangle(0, -22, 36, 36, 0xffe0c0);
    this.head.setStrokeStyle(2, 0xcc9966);
    // Yeux
    this.eyeLeft  = this.scene.add.rectangle(-8, -26, 6, 6, 0x222222);
    this.eyeRight = this.scene.add.rectangle(8, -26, 6, 6, 0x222222);
    // Bouche
    this.mouth = this.scene.add.text(0, -14, "—", {
      fontSize: "10px", color: "#884422",
    }).setOrigin(0.5);
    // Badge MAIF
    this.badge = this.scene.add.text(0, 20, "MAIF", {
      fontSize: "9px",
      color: "#ffffff",
      fontStyle: "bold",
      backgroundColor: "#ffffff22",
    }).setOrigin(0.5);

    // Cheveux
    const hair = this.scene.add.rectangle(0, -38, 36, 10, 0x553311);

    this.container = this.scene.add.container(x, y, [
      this.body, hair, this.head, this.eyeLeft, this.eyeRight, this.mouth, this.badge,
    ]);
    this.container.setDepth(42).setScrollFactor(0);

    // Animation de respiration
    this.scene.tweens.add({
      targets: this.container,
      y: y - 4,
      duration: 1800,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });
  }

  setExpression(expression: ConseilleurExpression): void {
    switch (expression) {
      case "souriant":
        this.mouth.setText("⌣");
        this.eyeLeft.setSize(6, 4);
        this.eyeRight.setSize(6, 4);
        this.body.setFillStyle(0x0055bb);
        break;
      case "inquiet":
        this.mouth.setText("~");
        this.eyeLeft.setSize(5, 7);
        this.eyeRight.setSize(5, 7);
        this.body.setFillStyle(0x224488);
        break;
      case "fier":
        this.mouth.setText("‿");
        this.eyeLeft.setSize(7, 5);
        this.eyeRight.setSize(7, 5);
        this.body.setFillStyle(0x0077cc);
        break;
      default: // normal
        this.mouth.setText("—");
        this.eyeLeft.setSize(6, 6);
        this.eyeRight.setSize(6, 6);
        this.body.setFillStyle(0x0055bb);
        break;
    }
  }

  setPosition(x: number, y: number): void {
    this.container.setPosition(x, y);
  }

  setVisible(visible: boolean): void {
    this.container.setVisible(visible);
  }

  /** Animation d'entrée slide-in depuis la gauche. */
  slideIn(fromX: number, toX: number): void {
    this.container.x = fromX;
    this.scene.tweens.add({
      targets: this.container,
      x: toX,
      duration: 500,
      ease: "Back.easeOut",
    });
  }
}
