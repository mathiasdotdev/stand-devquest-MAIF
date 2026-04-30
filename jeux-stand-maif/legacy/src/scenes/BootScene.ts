import Phaser from "phaser";
import { StoryEngine } from "../core/histoire/services/StoryEngine";
import { parseStoryHash, createEngineAtChapitre } from "../core/histoire/utils/storyDevNav";

const CHAR_POSES = ["idle", "walk1", "walk2", "jump", "fall", "slide", "hurt"] as const;

/** Charge tous les assets et passe au Menu. */
export class BootScene extends Phaser.Scene {
  constructor() {
    super("BootScene");
  }

  preload(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    // ── UI de chargement ────────────────────────────────────────────────
    const barBg = this.add.rectangle(w / 2, h / 2 + 30, 304, 28, 0x333344);
    const bar = this.add.rectangle(w / 2 - 150, h / 2 + 30, 0, 20, 0x4caf50).setOrigin(0, 0.5);
    void barBg;

    this.add.text(w / 2, h / 2 - 40, "MAIF Runner", {
      fontSize: "36px", color: "#ffffff", fontStyle: "bold",
    }).setOrigin(0.5);

    const sub = this.add.text(w / 2, h / 2, "Chargement...", {
      fontSize: "16px", color: "#aaaaaa",
    }).setOrigin(0.5);

    this.load.on("progress", (value: number) => { bar.width = 300 * value; });
    this.load.on("complete", () => { sub.setText("Prêt !"); });

    // ── Personnages ─────────────────────────────────────────────────────
    for (const pose of CHAR_POSES) {
      this.load.image(`male_${pose}`,   `/characters/poses_male/male_${pose}.png`);
      this.load.image(`female_${pose}`, `/characters/poses_female/female_${pose}.png`);
    }

    // ── Environnement ───────────────────────────────────────────────────
    this.load.image("bg_land",    "/environment/backgrounds/Backgrounds/colored_land.png");
    this.load.image("ground_tile", "/environment/tiles/ground-redux/Grass/grassMid.png");

    // ── Items ───────────────────────────────────────────────────────────
    this.load.image("coinGold", "/items/coinGold.png");

    // ── Sons ────────────────────────────────────────────────────────────
    this.load.audio("sfx_jump",    "/sounds/platformer/sfx_jump.ogg");
    this.load.audio("sfx_coin",    "/sounds/platformer/sfx_coin.ogg");
    this.load.audio("sfx_hurt",    "/sounds/platformer/sfx_hurt.ogg");
    this.load.audio("sfx_click",   "/sounds/ui/click-a.ogg");
    this.load.audio("sfx_switch",  "/sounds/ui/switch-a.ogg");

    // ── Obstacles ────────────────────────────────────────────────────────
    // Bas (slide pour éviter) : panneau routier
    this.load.image("obstacle",      "/environment/tiles/platformer-deluxe/fence.png");
    // Haut (saut pour éviter) : caisse warning
    this.load.image("obstacle_high", "/environment/tiles/platformer-deluxe/boxWarning.png");

    // ── Génération textures procédurales ────────────────────────────────
    // (tout ce qu'on n'a pas encore en sprites réels)
    this.generateTextures();
  }

  create(): void {
    this.time.delayedCall(300, () => {
      const nav = parseStoryHash();
      if (nav) {
        if (nav.scene === "StoryIntroScene") {
          this.scene.start("StoryIntroScene");
        } else {
          // En dev nav, essayer de restaurer la session d'abord
          const engine = StoryEngine.loadFromSession() ?? createEngineAtChapitre(nav.chapitreIndex);
          this.scene.start(nav.scene, { storyEngine: engine });
        }
      } else {
        this.scene.start("MenuScene");
      }
    });
  }

  private generateTextures(): void {
    const g = this.make.graphics({ x: 0, y: 0 });

    // ── Obstacles sinistres ────────────────────────────────────────────────
    g.clear(); g.fillStyle(0xff4400); g.fillCircle(22, 22, 18); g.fillStyle(0xffcc00); g.fillCircle(22, 22, 10);
    g.generateTexture("obs_fireball", 44, 44);

    g.clear(); g.fillStyle(0xaaaaaa); g.fillRoundedRect(4, 8, 56, 20, 4); g.fillStyle(0x888888); g.fillCircle(16, 28, 7); g.fillCircle(48, 28, 7); g.fillStyle(0x99bbdd); g.fillRect(16, 10, 28, 12);
    g.generateTexture("obs_car", 64, 36);

    g.clear(); g.fillStyle(0x2255ff, 0.9); g.fillRoundedRect(0, 4, 80, 16, 6);
    g.generateTexture("obs_flood", 80, 24);

    g.clear(); g.fillStyle(0x667788); g.fillCircle(16, 20, 14); g.fillCircle(28, 14, 16); g.fillCircle(40, 20, 14);
    g.generateTexture("obs_wind", 56, 40);

    g.clear(); g.fillStyle(0xdd1111); g.fillTriangle(16, 0, 0, 40, 32, 40);
    g.generateTexture("obs_spike", 32, 40);

    g.clear(); g.fillStyle(0x223311); g.fillCircle(14, 10, 8); g.fillRect(6, 18, 16, 26);
    g.generateTexture("obs_burglar", 28, 52);

    g.clear(); g.fillStyle(0x443322); g.fillCircle(14, 9, 8); g.fillRect(6, 17, 16, 24);
    g.generateTexture("obs_thief", 28, 48);

    g.clear(); g.fillStyle(0x3399ff, 0.85); g.fillRoundedRect(0, 0, 60, 14, 5);
    g.generateTexture("obs_water", 60, 20);

    // ── Parallax backgrounds ───────────────────────────────────────────────
    // bg : ciel + bâtiments lointains
    g.clear(); g.fillStyle(0x5588cc); g.fillRect(0, 0, 256, 80); g.fillStyle(0xffdd88); g.fillCircle(220, 20, 16); g.fillStyle(0x994422); g.fillRect(20, 40, 40, 36); g.fillStyle(0xcc5533); g.fillTriangle(16, 40, 40, 10, 64, 40); g.fillStyle(0x886622); g.fillRect(80, 48, 30, 28); g.fillStyle(0x336622); g.fillCircle(170, 52, 18);
    g.generateTexture("parallax_bg", 256, 80);

    // mid : haies/arbres
    g.clear(); g.fillStyle(0x448833); g.fillRoundedRect(0, 8, 256, 20, 4); g.fillStyle(0x336622); g.fillCircle(40, 14, 12); g.fillCircle(100, 12, 10); g.fillCircle(160, 16, 13); g.fillCircle(220, 13, 11);
    g.generateTexture("parallax_mid", 256, 28);

    // fg : herbe
    g.clear(); g.fillStyle(0x338822); g.fillRect(0, 4, 256, 12);
    g.generateTexture("parallax_fg", 256, 16);

    // ── Ciel (fallback) ────────────────────────────────────────────────────
    g.clear();
    g.fillStyle(0x2266aa);
    g.fillRect(0, 0, 64, 64);
    g.generateTexture("sky", 64, 64);

    // Joueur placeholder (si texture perso non chargée)
    g.clear();
    g.fillStyle(0x33cc66);
    g.fillRoundedRect(0, 0, 36, 48, 6);
    g.generateTexture("player", 36, 48);

    // Zone sinistre (overlay rouge)
    g.clear();
    g.fillStyle(0xff2222, 0.35);
    g.fillRect(0, 0, 800, 300);
    g.lineStyle(3, 0xff0000, 0.8);
    g.strokeRect(0, 0, 800, 300);
    g.generateTexture("disaster_zone", 800, 300);

    // Agence MAIF
    g.clear();
    g.fillStyle(0x0055aa);
    g.fillRect(0, 0, 96, 80);
    g.fillStyle(0x003388);
    g.fillRect(0, 64, 96, 16);
    g.fillStyle(0xffffff);
    g.fillRect(8, 8, 80, 52);
    g.generateTexture("agency", 96, 80);

    // Panneaux fork
    const forkColors = [
      { key: "fork_sign",      fill: 0x225588, stroke: 0xffffff },
      { key: "fork_safe",      fill: 0x226633, stroke: 0x88ff88 },
      { key: "fork_risky",     fill: 0x996611, stroke: 0xffaa33 },
      { key: "fork_dangerous", fill: 0x882222, stroke: 0xff4444 },
    ];
    for (const { key, fill, stroke } of forkColors) {
      g.clear();
      g.fillStyle(fill);
      g.fillRoundedRect(0, 0, 80, 40, 6);
      g.lineStyle(2, stroke);
      g.strokeRoundedRect(0, 0, 80, 40, 6);
      g.generateTexture(key, 80, 40);
    }

    // HUD fond
    g.clear();
    g.fillStyle(0x000000, 0.7);
    g.fillRoundedRect(0, 0, 200, 60, 8);
    g.generateTexture("hud_panel", 200, 60);

    // Boutons
    const btns = [
      { key: "btn_blue",  fill: 0x0055aa, stroke: 0x4499ff },
      { key: "btn_green", fill: 0x226611, stroke: 0x44cc33 },
      { key: "btn_red",   fill: 0x882211, stroke: 0xff4433 },
    ];
    for (const { key, fill, stroke } of btns) {
      g.clear();
      g.fillStyle(fill);
      g.fillRoundedRect(0, 0, 200, 50, 8);
      g.lineStyle(2, stroke);
      g.strokeRoundedRect(0, 0, 200, 50, 8);
      g.generateTexture(key, 200, 50);
    }

    // Modal
    g.clear();
    g.fillStyle(0x111122, 0.95);
    g.fillRoundedRect(0, 0, 500, 400, 12);
    g.lineStyle(2, 0x4477cc);
    g.strokeRoundedRect(0, 0, 500, 400, 12);
    g.generateTexture("modal", 500, 400);

    g.destroy();
  }
}
