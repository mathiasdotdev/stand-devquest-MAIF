import Phaser from "phaser";
import type { GameState } from "../core/infini/models/GameState";
import type { Player } from "./Player";
import { GAME_CONFIG } from "../core/infini/config/gameConfig";
import type { DisasterType } from "../core/shared/models/Disaster";
import { DISASTERS_CONFIG } from "../core/shared/config/disastersConfig";
import { DisasterObstacle, DISASTER_OBSTACLE_CONFIGS } from "./DisasterObstacle";

interface CoinEntity {
  image: Phaser.GameObjects.Image;
  worldX: number;
  worldY: number;
  collected: boolean;
  isAirborne: boolean;
}

interface ObstacleEntity {
  image: Phaser.GameObjects.Image;
  worldX: number;
  worldY: number;
  isHigh: boolean;
}

/** Gère le rendu visuel du sol et des entités de jeu (pièces, obstacles, agences). */
export class SegmentRenderer {
  private scene: Phaser.Scene;
  private screenH: number;
  private groundTile!: Phaser.GameObjects.TileSprite;
  private groundY: number;

  // Parallax
  private parallaxLayers: Phaser.GameObjects.TileSprite[] = [];
  private currentEnvironment = "banlieue";

  // Entités actives
  private coins: CoinEntity[] = [];
  private obstacles: ObstacleEntity[] = [];
  private disasterObstacles: DisasterObstacle[] = [];
  private disasterOverlay!: Phaser.GameObjects.Image;
  private disasterLabel!: Phaser.GameObjects.Text;
  private agencyImage!: Phaser.GameObjects.Image;
  private agencyText!: Phaser.GameObjects.Text;

  // Suivi
  private lastRenderedSegment = -1;
  private segmentPixelOffset = 0; // offset en px dans le segment courant

  constructor(scene: Phaser.Scene, screenH: number) {
    this.scene = scene;
    this.screenH = screenH;
    // Surface du sol = même ratio que la physique dans GameScene
    this.groundY = Math.floor(screenH * GAME_CONFIG.GROUND_Y_RATIO);

    const w = scene.scale.width;

    // Couches parallax (fond lointain, plan moyen, avant-plan)
    this.createParallaxLayers(scene, w);

    // Terre (remplissage de groundY jusqu'en bas de l'écran)
    const dirtH = screenH - this.groundY + 4;
    scene.add.rectangle(w / 2, this.groundY + dirtH / 2, w, dirtH, 0x8b5a2b).setDepth(2);

    // Rangée d'herbe (top = groundY, 1 tile = 70px pour couvrir le bord)
    this.groundTile = scene.add.tileSprite(w / 2, this.groundY + 35, w, 70, "ground_tile");
    this.groundTile.setDepth(3);

    // Overlay sinistre (caché par défaut)
    this.disasterOverlay = scene.add.image(w / 2, screenH * 0.65, "disaster_zone")
      .setDepth(8)
      .setAlpha(0);
    this.disasterLabel = scene.add.text(w / 2, screenH * 0.5, "", {
      fontSize: "28px",
      color: "#ff4444",
      fontStyle: "bold",
      stroke: "#000000",
      strokeThickness: 4,
    }).setOrigin(0.5).setDepth(9).setAlpha(0);

    // Agence (cachée par défaut)
    this.agencyImage = scene.add.image(w + 96, this.groundY - 60, "agency")
      .setDisplaySize(96, 80)
      .setDepth(5);
    this.agencyText = scene.add.text(w + 96, this.groundY - 110, "MAIF", {
      fontSize: "14px",
      color: "#ffffff",
      fontStyle: "bold",
      stroke: "#0033aa",
      strokeThickness: 3,
    }).setOrigin(0.5).setDepth(6);
  }

  private createParallaxLayers(scene: Phaser.Scene, w: number): void {
    // 3 couches de parallax : fond (0.1×), milieu (0.35×), avant (0.7×)
    // Générées procéduralement ; seront remplacées par de vraies textures plus tard
    const configs = [
      { key: "parallax_bg",  scrollFactor: 0.1, depth: 0, y: this.groundY * 0.35 },
      { key: "parallax_mid", scrollFactor: 0.35, depth: 1, y: this.groundY * 0.65 },
      { key: "parallax_fg",  scrollFactor: 0.7, depth: 1, y: this.groundY * 0.87 },
    ];
    for (const cfg of configs) {
      if (scene.textures.exists(cfg.key)) {
        const layer = scene.add.tileSprite(w / 2, cfg.y, w, this.groundY, cfg.key)
          .setDepth(cfg.depth)
          .setScrollFactor(0);
        this.parallaxLayers.push(layer);
      }
    }
  }

  /** Change l'environnement visuel selon la phase. */
  setEnvironment(environment: string): void {
    if (this.currentEnvironment === environment) return;
    this.currentEnvironment = environment;
    // Teinte du sol selon l'environnement
    const envTints: Record<string, number> = {
      "banlieue":         0xffffff,
      "centre-ville":     0xddddcc,
      "zone-industrielle":0xbbbbaa,
      "chaos":            0xcc9977,
    };
    this.groundTile.setTint(envTints[environment] ?? 0xffffff);
  }

  /**
   * Met à jour le rendu selon la position monde.
   * worldX = cumul de pixels scrollés depuis le début.
   */
  update(worldX: number, state: GameState): void {
    // Scroll du sol
    this.groundTile.tilePositionX = worldX;

    // Scroll parallax
    this.parallaxLayers.forEach((layer, i) => {
      const factors = [0.1, 0.35, 0.7];
      layer.tilePositionX = worldX * (factors[i] ?? 0.5);
    });

    const w = this.scene.scale.width;
    const segmentPx = GAME_CONFIG.SEGMENT_LENGTH_PX;

    // Position dans le segment courant
    const posInSeg = worldX % segmentPx; // 0 → segmentPx

    // Spawner les entités du segment courant si pas encore fait
    if (state.currentSegmentIndex !== this.lastRenderedSegment) {
      this.lastRenderedSegment = state.currentSegmentIndex;
      // Teinte du sol selon le risque (sans changer la texture pour ne pas perturber la physique)
      const tints: Record<string, number> = { safe: 0xffffff, risky: 0xddbb66, dangerous: 0xaa6644 };
      this.groundTile.setTint(tints[state.currentPathRisk] ?? 0xffffff);
      this.spawnSegmentEntities(state, w, segmentPx);
    }

    // Déplacer les entités vers la gauche
    const screenOffset = worldX;
    this.coins.forEach((coin) => {
      coin.image.x = coin.worldX - screenOffset + w * 0.2;
    });
    this.obstacles.forEach((obs) => {
      obs.image.x = obs.worldX - screenOffset + w * 0.2;
    });
    this.disasterObstacles.forEach((obs) => {
      obs.update(screenOffset, w * 0.2);
    });

    // Agence
    if (state.currentSegment.isAgency) {
      const agencyWorldX = state.currentSegmentIndex * segmentPx + segmentPx * 0.5;
      const agencyScreenX = agencyWorldX - screenOffset + w * 0.2;
      this.agencyImage.x = agencyScreenX;
      this.agencyText.x = agencyScreenX;
    }

    // Nettoyer les entités passées
    this.cleanupOffscreen(w);
  }

  private spawnSegmentEntities(state: GameState, w: number, segmentPx: number): void {
    const seg = state.currentSegment;
    const baseWorldX = state.currentSegmentIndex * segmentPx;

    // Pièces
    let coinSpacing = 0;
    for (const zone of seg.coins) {
      for (let i = 0; i < zone.count; i++) {
        const wx = baseWorldX + 100 + coinSpacing + i * 90;
        const wy = zone.isAirborne
          ? this.groundY - 120 - Math.random() * 40
          : this.groundY - 36;

        const img = this.scene.add.image(wx, wy, "coinGold").setDisplaySize(22, 22).setDepth(4);
        this.coins.push({
          image: img,
          worldX: wx,
          worldY: wy,
          collected: false,
          isAirborne: zone.isAirborne,
        });
        coinSpacing += 20;
      }
    }

    // Obstacles sinistres thématiques (DisasterObstacle) si le segment a un sinistre
    if (seg.disasterType) {
      const cfg = DISASTER_OBSTACLE_CONFIGS[seg.disasterType];
      if (cfg) {
        const wx = baseWorldX + 0.55 * segmentPx;
        const isCovered = state.activeContracts.some((c) => {
          // Import léger : on vérifie dans DISASTERS_CONFIG
          return true; // sera raffiné selon couverture
        });
        // Pour les obstacles générés par sinistres sur segment
        // On spawn l'obstacle sinistre à la place d'un obstacle générique
        const disObs = new DisasterObstacle(this.scene, seg.disasterType, wx, this.groundY, false);
        this.disasterObstacles.push(disObs);
      }
    }

    // Obstacles génériques — position via xRatio
    seg.obstacles.forEach((obs, i) => {
      const wx = baseWorldX + (obs.xRatio ?? (i === 0 ? 0.4 : 0.65)) * segmentPx;
      const h = obs.isHighObstacle ? 64 : 36;
      const wy = this.groundY - h / 2 - 2;
      const tex = obs.isHighObstacle ? "obstacle_high" : "obstacle";
      const img = this.scene.add.image(wx, wy, tex).setDisplaySize(40, h).setDepth(5);
      this.obstacles.push({ image: img, worldX: wx, worldY: wy, isHigh: obs.isHighObstacle });
    });

    // Agence positionnement initial
    if (seg.isAgency) {
      this.agencyImage.x = w + 96;
      this.agencyText.x = w + 96;
    }
  }

  checkCoinCollisions(player: Player, onCollect: (count: number, airborne: boolean) => void): void {
    const rawBounds = player.getBounds();
    const playerBounds = new Phaser.Geom.Rectangle(
      rawBounds.x - 8, rawBounds.y - 8, rawBounds.width + 16, rawBounds.height + 16
    );

    for (const coin of this.coins) {
      if (coin.collected) continue;
      const coinBounds = new Phaser.Geom.Rectangle(
        coin.image.x - 11, coin.image.y - 11, 22, 22
      );
      if (Phaser.Geom.Rectangle.Overlaps(playerBounds, coinBounds)) {
        coin.collected = true;
        coin.image.setAlpha(0);
        // Animation tween
        this.scene.tweens.add({
          targets: coin.image,
          y: coin.image.y - 30,
          alpha: 0,
          duration: 300,
          onComplete: () => coin.image.destroy(),
        });
        onCollect(1, coin.isAirborne);
      }
    }
    // Supprimer les collectées
    this.coins = this.coins.filter((c) => !c.collected || c.image.active);
  }

  checkObstacleCollision(player: Player, onHit: () => void): void {
    const playerBounds = player.getBounds();

    for (const obs of this.obstacles) {
      const obsBounds = new Phaser.Geom.Rectangle(
        obs.image.x - 18, obs.image.y - obs.image.displayHeight / 2,
        36, obs.image.displayHeight
      );

      // Slide évite les obstacles bas
      if (!obs.isHigh && player.isCurrentlySliding()) continue;
      // Saut évite les obstacles hauts (si le joueur est suffisamment haut)
      if (obs.isHigh && player.getY() < this.groundY - 80) continue;

      if (Phaser.Geom.Rectangle.Overlaps(playerBounds, obsBounds)) {
        obs.image.setTint(0xff8800);
        onHit();
      }
    }
  }

  showDisasterOverlay(type: DisasterType): void {
    const def = DISASTERS_CONFIG[type];
    this.disasterLabel.setText(`${def?.icon ?? "⚠️"} ${def?.label ?? "Sinistre"} !`);

    this.scene.tweens.add({
      targets: [this.disasterOverlay, this.disasterLabel],
      alpha: { from: 0, to: 1 },
      duration: 200,
      yoyo: true,
      hold: 800,
      onComplete: () => {
        this.disasterOverlay.setAlpha(0);
        this.disasterLabel.setAlpha(0);
      },
    });
  }

  private cleanupOffscreen(w: number): void {
    this.coins = this.coins.filter((c) => {
      if (c.image.x < -100) { c.image.destroy(); return false; }
      return true;
    });
    this.obstacles = this.obstacles.filter((o) => {
      if (o.image.x < -100) { o.image.destroy(); return false; }
      return true;
    });
    this.disasterObstacles = this.disasterObstacles.filter((o) => {
      if (o.isOffscreen(w)) { o.destroy(); return false; }
      return true;
    });
  }
}
