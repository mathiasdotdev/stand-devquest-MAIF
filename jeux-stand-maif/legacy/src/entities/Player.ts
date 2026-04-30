import Phaser from "phaser";
import { GAME_CONFIG } from "../core/infini/config/gameConfig";

type Character = "male" | "female";

export class Player {
  private scene: Phaser.Scene;
  private sprite: Phaser.Physics.Arcade.Sprite;
  private character: Character;

  private isSliding = false;
  private slideTimer = 0;
  private isHurt = false;
  private hurtTimer = 0;
  private shieldActive = false;
  private shieldTimer = 0;
  private shieldCircle?: Phaser.GameObjects.Arc;
  private readonly SHIELD_DURATION_MS = 500;

  // Animation marche
  private walkFrame: 0 | 1 = 0;
  private walkTimer = 0;
  private readonly WALK_FRAME_MS = 150;

  private readonly DISPLAY_W = 40;
  private readonly DISPLAY_H = 60;

  constructor(scene: Phaser.Scene, x: number, y: number, character: Character = "male") {
    this.scene = scene;
    this.character = character;

    this.sprite = scene.physics.add.sprite(x, y, `${character}_idle`);
    this.sprite.setCollideWorldBounds(true);
    this.sprite.setGravityY(GAME_CONFIG.PLAYER_GRAVITY);
    this.sprite.setMaxVelocity(1000, 800);
    this.sprite.setDepth(10);
    this.sprite.setDisplaySize(this.DISPLAY_W, this.DISPLAY_H);
    // Corps physique = taille d'affichage (sinon c'est la taille de la texture PNG)
    this.sprite.setBodySize(this.DISPLAY_W, this.DISPLAY_H);

    // Cercle bouclier (caché par défaut)
    this.shieldCircle = scene.add.arc(x, y, 36, 0, 360, false, 0x44aaff, 0.3)
      .setDepth(11)
      .setVisible(false);
  }

  update(delta: number): void {
    // Slide timer
    if (this.isSliding) {
      this.slideTimer -= delta;
      if (this.slideTimer <= 0) {
        this.isSliding = false;
      }
    }

    // Hurt timer + flash
    if (this.isHurt) {
      this.hurtTimer -= delta;
      const visible = Math.floor(this.hurtTimer / 100) % 2 === 0;
      this.sprite.setAlpha(visible ? 1 : 0.3);
      if (this.hurtTimer <= 0) {
        this.isHurt = false;
        this.sprite.setAlpha(1);
      }
    }

    // Bouclier timer
    if (this.shieldActive) {
      this.shieldTimer -= delta;
      if (this.shieldCircle) {
        this.shieldCircle.setPosition(this.sprite.x, this.sprite.y);
        this.shieldCircle.setAlpha(Math.max(0, this.shieldTimer / this.SHIELD_DURATION_MS) * 0.5);
      }
      if (this.shieldTimer <= 0) {
        this.shieldActive = false;
        this.shieldCircle?.setVisible(false);
      }
    }

    // Walk frame alternance
    this.walkTimer += delta;
    if (this.walkTimer >= this.WALK_FRAME_MS) {
      this.walkTimer = 0;
      this.walkFrame = this.walkFrame === 0 ? 1 : 0;
    }

    this.updateTexture();
  }

  private updateTexture(): void {
    const c = this.character;
    const body = this.sprite.body as Phaser.Physics.Arcade.Body;
    const onGround = body.blocked.down || body.touching.down;
    const vy = body.velocity.y;

    let pose: string;
    if (this.isHurt)         pose = "hurt";
    else if (this.isSliding) pose = "slide";
    else if (!onGround)      pose = vy < 0 ? "jump" : "fall";
    else                     pose = `walk${this.walkFrame + 1}`;

    this.sprite.setTexture(`${c}_${pose}`);
  }

  jump(): void {
    if (this.isOnGround() && !this.isSliding) {
      this.sprite.setVelocityY(GAME_CONFIG.PLAYER_JUMP_VELOCITY);
      this.scene.sound.play("sfx_jump", { volume: 0.5 });
    }
  }

  slide(): void {
    if (this.isOnGround() && !this.isSliding) {
      this.isSliding = true;
      this.slideTimer = GAME_CONFIG.PLAYER_SLIDE_DURATION_MS;
      // Ne pas changer setDisplaySize : ça modifie scaleY → le body physique rétrécit
      // et le joueur tombe à travers le sol. La texture "slide" suffit visuellement.
    }
  }

  unslide(): void {
    // Slide se reset automatiquement via timer
  }

  hurt(): void {
    if (this.isHurt) return;
    this.isHurt = true;
    this.hurtTimer = 600;
    this.scene.sound.play("sfx_hurt", { volume: 0.6 });
  }

  /** Active l'effet bouclier doré (sinistre couvert). */
  activateShield(): void {
    this.shieldActive = true;
    this.shieldTimer = this.SHIELD_DURATION_MS;
    if (this.shieldCircle) {
      this.shieldCircle.setVisible(true).setFillStyle(0xffcc44, 0.4);
    }
  }

  isOnGround(): boolean {
    const body = this.sprite.body as Phaser.Physics.Arcade.Body;
    return body.blocked.down || body.touching.down;
  }

  isCurrentlySliding(): boolean { return this.isSliding; }
  isCurrentlyHurt(): boolean { return this.isHurt; }

  getBounds(): Phaser.Geom.Rectangle { return this.sprite.getBounds(); }

  getX(): number { return this.sprite.x; }
  getY(): number { return this.sprite.y; }

  getSprite(): Phaser.Physics.Arcade.Sprite { return this.sprite; }
}
