import Phaser from "phaser";
import type { GameMode } from "../core/shared/models/GameMode";
import { StoryEngine } from "../core/histoire/services/StoryEngine";

type Character = "male" | "female";

export class MenuScene extends Phaser.Scene {
  private scrollX = 0;
  private character: Character = "male";
  private charPreview!: Phaser.GameObjects.Image;
  private charLabel!: Phaser.GameObjects.Text;

  constructor() {
    super("MenuScene");
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    // ── Background ───────────────────────────────────────────────────────
    this.add.image(w / 2, h / 2, "bg_land").setDisplaySize(w, h);
    const road = this.add.tileSprite(w / 2, h * 0.88, w, h * 0.25, "ground_tile");

    // ── Titre ────────────────────────────────────────────────────────────
    this.add
      .text(w / 2, h * 0.12, "MAIF Runner", {
        fontSize: "52px",
        color: "#ffffff",
        fontStyle: "bold",
        stroke: "#0033aa",
        strokeThickness: 5,
      })
      .setOrigin(0.5);

    this.add
      .text(w / 2, h * 0.22, "Sortez couvert !", {
        fontSize: "22px",
        color: "#ffffff",
        fontStyle: "italic",
        stroke: "#0033aa",
        strokeThickness: 4,
      })
      .setOrigin(0.5);

    // ── Sélection personnage ─────────────────────────────────────────────
    const charX = w * 0.72;
    const charY = h * 0.46;

    this.add
      .text(charX, charY - 100, "Personnage", {
        fontSize: "16px",
        color: "#ffffff",
        fontStyle: "bold",
        stroke: "#002266",
        strokeThickness: 3,
      })
      .setOrigin(0.5);

    this.charPreview = this.add.image(charX, charY, "male_idle").setDisplaySize(96, 120);

    this.charLabel = this.add
      .text(charX, charY + 74, "Homme", {
        fontSize: "15px",
        color: "#ffdd88",
        fontStyle: "bold",
        stroke: "#002266",
        strokeThickness: 3,
      })
      .setOrigin(0.5);

    const btnPrev = this.add
      .text(charX - 66, charY, "◀", {
        fontSize: "26px",
        color: "#ffffff",
        stroke: "#002266",
        strokeThickness: 3,
      })
      .setOrigin(0.5)
      .setInteractive({ useHandCursor: true });

    const btnNext = this.add
      .text(charX + 66, charY, "▶", {
        fontSize: "26px",
        color: "#ffffff",
        stroke: "#002266",
        strokeThickness: 3,
      })
      .setOrigin(0.5)
      .setInteractive({ useHandCursor: true });

    btnPrev.on("pointerdown", () => this.toggleCharacter());
    btnNext.on("pointerdown", () => this.toggleCharacter());

    // ── Boutons mode ─────────────────────────────────────────────────────
    // Vérifier si une session histoire est en cours
    const savedEngine = StoryEngine.loadFromSession();
    const hasSavedGame = savedEngine !== null && !savedEngine.getState().isComplete;

    if (hasSavedGame) {
      const state = savedEngine!.getState();
      const chapNum = state.currentChapitre + 1;
      this.createButton(w * 0.38, h * 0.33, `▶ Continuer Ch.${chapNum}`, () => this.continueStory(savedEngine!), "btn_green");
      this.createButton(w * 0.38, h * 0.46, "📖 Mode Histoire", () => this.startStory(), "btn_blue");
      this.createButton(w * 0.38, h * 0.59, "🏃 Mode Infini",   () => this.startGame("infinite"), "btn_blue");
      this.createButton(w * 0.38, h * 0.72, "🏆 Classement",    () => this.scene.start("LeaderboardScene"), "btn_blue");
    } else {
      this.createButton(w * 0.38, h * 0.4,  "📖 Mode Histoire", () => this.startStory(), "btn_blue");
      this.createButton(w * 0.38, h * 0.53, "🏃 Mode Infini",   () => this.startGame("infinite"), "btn_blue");
      this.createButton(w * 0.38, h * 0.66, "🏆 Classement",    () => this.scene.start("LeaderboardScene"), "btn_blue");
    }

    // ── Sol animé ────────────────────────────────────────────────────────
    this.time.addEvent({
      loop: true,
      delay: 16,
      callback: () => {
        this.scrollX += 3;
        road.tilePositionX = this.scrollX;
      },
    });

    this.add.text(8, h - 20, "v0.3", {
      fontSize: "11px",
      color: "#002266",
    });

    // Accès panel admin (Shift+D)
    this.input.keyboard!.on("keydown", (e: KeyboardEvent) => {
      if (e.key === "D" && e.shiftKey) this.scene.start("AdminScene");
    });
  }

  private toggleCharacter(): void {
    this.sound.play("sfx_switch", { volume: 0.5 });
    this.character = this.character === "male" ? "female" : "male";
    this.charPreview.setTexture(`${this.character}_idle`);
    this.charLabel.setText(this.character === "male" ? "Homme" : "Femme");
  }

  private createButton(x: number, y: number, label: string, cb: () => void, texture: string) {
    const btn = this.add.image(x, y, texture).setDisplaySize(220, 52).setInteractive({ useHandCursor: true });
    const text = this.add
      .text(x, y, label, {
        fontSize: "20px",
        color: "#ffffff",
        fontStyle: "bold",
      })
      .setOrigin(0.5);
    void text;

    btn.on("pointerover", () => btn.setTint(0xaaddff));
    btn.on("pointerout", () => btn.clearTint());
    btn.on("pointerdown", () => {
      this.sound.play("sfx_click", { volume: 0.6 });
      cb();
    });
    return btn;
  }

  private startGame(mode: GameMode): void {
    this.registry.set("character", this.character);
    this.scene.start("PlatformerScene", { mode });
  }

  private startStory(): void {
    this.registry.set("character", this.character);
    this.scene.start("StoryIntroScene");
  }

  private continueStory(engine: StoryEngine): void {
    this.registry.set("character", this.character);
    const state = engine.getState();
    // Auto-avancer si un chapitre a été résolu mais pas encore sauté
    if (state.answers.length > state.currentChapitre) {
      engine.nextChapitre();
      engine.saveToSession();
    }
    this.scene.start("ChapitreIntroScene", { storyEngine: engine });
  }
}
