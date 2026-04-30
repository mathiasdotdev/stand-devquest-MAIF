import Phaser from "phaser";
import type { DisasterType } from "../core/shared/models/Disaster";

export type AvoidMove = "jump" | "slide" | "none";

export interface DisasterObstacleConfig {
  type: DisasterType;
  avoidMove: AvoidMove;
  textureKey: string;
  displayW: number;
  displayH: number;
  /** Taille du corps physique relatif au display */
  bodyOffsetY: number;
  /** true = obstacle au-dessus de la tête (à passer en dessous) */
  isHigh: boolean;
  /** Couleur de tint fallback si texture absente */
  tint: number;
}

export const DISASTER_OBSTACLE_CONFIGS: Record<DisasterType, DisasterObstacleConfig> = {
  incendie:         { type: "incendie",         avoidMove: "jump",  textureKey: "obs_fireball",  displayW: 44, displayH: 44, bodyOffsetY: 0, isHigh: false, tint: 0xff4400 },
  accident_voiture: { type: "accident_voiture", avoidMove: "slide", textureKey: "obs_car",        displayW: 64, displayH: 36, bodyOffsetY: 0, isHigh: true,  tint: 0xaaaaaa },
  inondation:       { type: "inondation",       avoidMove: "jump",  textureKey: "obs_flood",      displayW: 80, displayH: 24, bodyOffsetY: 8, isHigh: false, tint: 0x2255ff },
  tempete:          { type: "tempete",          avoidMove: "slide", textureKey: "obs_wind",       displayW: 56, displayH: 40, bodyOffsetY: 0, isHigh: true,  tint: 0x8899bb },
  blessure:         { type: "blessure",         avoidMove: "jump",  textureKey: "obs_spike",      displayW: 32, displayH: 40, bodyOffsetY: 0, isHigh: false, tint: 0xff3333 },
  cambriolage:      { type: "cambriolage",      avoidMove: "slide", textureKey: "obs_burglar",    displayW: 28, displayH: 52, bodyOffsetY: 0, isHigh: true,  tint: 0x334422 },
  vol_vehicule:     { type: "vol_vehicule",     avoidMove: "jump",  textureKey: "obs_thief",      displayW: 28, displayH: 48, bodyOffsetY: 0, isHigh: false, tint: 0x443322 },
  degats_des_eaux:  { type: "degats_des_eaux",  avoidMove: "jump",  textureKey: "obs_water",      displayW: 60, displayH: 20, bodyOffsetY: 8, isHigh: false, tint: 0x3399ff },
};

/**
 * Un obstacle visuel représentant un sinistre dans le runner.
 * Géré dans SegmentRenderer (pool de sprites).
 */
export class DisasterObstacle {
  readonly type: DisasterType;
  readonly avoidMove: AvoidMove;
  readonly isHigh: boolean;
  readonly image: Phaser.GameObjects.Image;
  worldX: number;
  worldY: number;
  /** Si couvert par un contrat actif → moins de dommages + effet bouclier */
  isCovered: boolean;

  private shieldCircle?: Phaser.GameObjects.Arc;
  private animTimer = 0;

  constructor(
    scene: Phaser.Scene,
    type: DisasterType,
    worldX: number,
    groundY: number,
    isCovered: boolean
  ) {
    const cfg = DISASTER_OBSTACLE_CONFIGS[type];
    this.type = type;
    this.avoidMove = cfg.avoidMove;
    this.isHigh = cfg.isHigh;
    this.worldX = worldX;
    this.isCovered = isCovered;

    // Position Y : obstacles hauts = à hauteur de tête, obstacles bas = au sol
    this.worldY = cfg.isHigh
      ? groundY - 70  // à hauteur de tête
      : groundY - cfg.displayH / 2 - 2;

    // Texture procédurale si asset manquant, fallback vers texture générique
    const texKey = scene.textures.exists(cfg.textureKey)
      ? cfg.textureKey
      : (cfg.isHigh ? "obstacle_high" : "obstacle");

    this.image = scene.add.image(worldX, this.worldY, texKey)
      .setDisplaySize(cfg.displayW, cfg.displayH)
      .setDepth(5)
      .setTint(cfg.tint);

    // Bouclier si couvert
    if (isCovered) {
      this.shieldCircle = scene.add.arc(worldX, this.worldY, cfg.displayW * 0.7, 0, 360, false, 0x44aaff, 0.25)
        .setDepth(6);
    }
  }

  update(screenOffset: number, playerOriginX: number): void {
    const screenX = this.worldX - screenOffset + playerOriginX;
    this.image.x = screenX;
    if (this.shieldCircle) {
      this.shieldCircle.x = screenX;
    }

    // Animation : oscillation verticale légère pour les obstacles flottants
    this.animTimer += 16;
    if (this.type === "incendie" || this.type === "tempete") {
      this.image.y = this.worldY + Math.sin(this.animTimer / 200) * 4;
    }
  }

  destroy(): void {
    this.image.destroy();
    this.shieldCircle?.destroy();
  }

  isOffscreen(w: number): boolean {
    return this.image.x < -100;
  }

  getBounds(): Phaser.Geom.Rectangle {
    return this.image.getBounds();
  }
}
