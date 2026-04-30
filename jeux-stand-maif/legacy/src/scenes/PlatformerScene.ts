import Phaser from "phaser";
import { GameEngine } from "../core/infini/services/GameEngine";
import type { GameMode } from "../core/shared/models/GameMode";
import type { GameEvent } from "../core/infini/models/GameEvent";
import type { DisasterResult } from "../core/shared/models/Disaster";
import { GAME_CONFIG } from "../core/infini/config/gameConfig";
import { Player } from "../entities/Player";
import { HUD } from "../ui/HUD";
import { DamagePopup } from "../ui/DamagePopup";
import { SegmentRenderer } from "../entities/SegmentRenderer";

interface PlatformerSceneData {
  mode?: GameMode;
  engine?: GameEngine; // réutilisé si on revient de MapScene
}

export class PlatformerScene extends Phaser.Scene {
  private engine!: GameEngine;
  private player!: Player;
  private hud!: HUD;
  private damagePopup!: DamagePopup;
  private segmentRenderer!: SegmentRenderer;

  private worldX = 0;
  private scrollSpeed = GAME_CONFIG.SCROLL_SPEED_PX;

  private cursors!: Phaser.Types.Input.Keyboard.CursorKeys;
  private jumpKey!: Phaser.Input.Keyboard.Key;

  constructor() {
    super("PlatformerScene");
  }

  init(data: PlatformerSceneData): void {
    // Réutiliser le moteur existant si on revient de MapScene
    if (data.engine) {
      this.engine = data.engine;
    } else {
      this.engine = new GameEngine(data.mode ?? "story");
    }
    this.worldX = 0;
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    const groundSurfaceY = Math.floor(h * GAME_CONFIG.GROUND_Y_RATIO);

    // Background
    this.add.image(w / 2, groundSurfaceY / 2, "bg_land")
      .setDisplaySize(w, groundSurfaceY);

    // Sol scrollant
    this.segmentRenderer = new SegmentRenderer(this, h);

    // Sol physique
    const GROUND_BODY_H = 40;
    const groundRect = this.add.rectangle(
      w / 2, groundSurfaceY + GROUND_BODY_H / 2,
      w + 400, GROUND_BODY_H,
      0x000000, 0
    );
    this.physics.add.existing(groundRect, true);

    // Joueur
    const PLAYER_HALF_H = 30;
    const character = (this.registry.get("character") as "male" | "female") ?? "male";
    this.player = new Player(this, w * 0.2, groundSurfaceY - PLAYER_HALF_H, character);
    this.physics.add.collider(this.player.getSprite(), groundRect);

    // HUD
    this.hud = new HUD(this);
    this.damagePopup = new DamagePopup(this);

    // Input
    this.cursors = this.input.keyboard!.createCursorKeys();
    this.jumpKey = this.input.keyboard!.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);
    this.input.keyboard!.on("keydown-ESC", () => this.togglePause());
    this.input.keyboard!.on("keydown", (e: KeyboardEvent) => {
      if (e.key === "D" && e.shiftKey) this.scene.start("AdminScene");
    });

    // Fade in depuis MapScene
    this.cameras.main.fadeIn(300, 0, 0, 0);
  }

  update(_time: number, delta: number): void {
    if (this.engine.getState().isGameOver) return;
    if (this.engine.getState().isPaused) return;
    if (this.engine.getState().isInAgency) return;

    const jumpPressed =
      Phaser.Input.Keyboard.JustDown(this.cursors.up) ||
      Phaser.Input.Keyboard.JustDown(this.jumpKey);
    const slidePressed = this.cursors.down.isDown;

    if (jumpPressed) this.player.jump();
    if (slidePressed) this.player.slide();
    else this.player.unslide();

    const events = this.engine.advance(delta);

    const speedMult: Record<string, number> = { safe: 1.0, risky: 1.2, dangerous: 1.4 };
    this.scrollSpeed = GAME_CONFIG.SCROLL_SPEED_PX * (speedMult[this.engine.getState().currentPathRisk] ?? 1.0);
    this.worldX += this.scrollSpeed * (delta / 1000);
    this.segmentRenderer.update(this.worldX, this.engine.getState());

    this.processEvents(events);

    this.segmentRenderer.checkCoinCollisions(this.player, (count, airborne) => {
      this.engine.collectCoins(count, airborne);
    });

    this.segmentRenderer.checkObstacleCollision(this.player, () => {
      if (!this.player.isCurrentlyHurt()) {
        const hitEvents = this.engine.obstacleHit(25);
        this.processEvents(hitEvents);
        this.damagePopup.showText("-25 🪙 Impact !", 0xff6600);
        this.cameras.main.shake(150, 0.005);
      }
      this.player.hurt();
    });

    this.hud.update(this.engine.getState());
    this.player.update(delta);
  }

  private processEvents(events: GameEvent[]): void {
    for (const ev of events) {
      switch (ev.type) {
        case "TICK": {
          const d = ev.data as { amount: number; totalDeducted: number };
          if (d.amount > 0) {
            this.damagePopup.showTick(d.amount);
            this.cameras.main.shake(120, 0.003);
          }
          break;
        }
        case "DISASTER_HIT": {
          const result = ev.data as DisasterResult;
          this.damagePopup.showDisaster(result);
          this.cameras.main.shake(300, 0.008);
          this.cameras.main.flash(200, 255, 0, 0, false);
          this.segmentRenderer.showDisasterOverlay(result.type);
          break;
        }
        case "CONTRACT_ACTIVATED": {
          this.damagePopup.showText("Contrat activé !", 0x33ff88);
          break;
        }
        case "FORK_AHEAD": {
          // Transition vers MapScene
          this.cameras.main.fadeOut(300, 0, 0, 0);
          this.cameras.main.once("camerafadeoutcomplete", () => {
            this.scene.start("MapScene", { engine: this.engine });
          });
          break;
        }
        case "AGENCY_REACHED": {
          this.time.delayedCall(300, () => {
            this.scene.launch("AgencyScene", { engine: this.engine });
          });
          break;
        }
        case "PHASE_CHANGE": {
          const { phase } = ev.data as { phase: 1 | 2 | 3 };
          const labels = ["", "Jeune Conducteur", "Assuré Confirmé", "Vétéran"];
          this.damagePopup.showText(`Phase ${phase} : ${labels[phase]}`, 0xffdd44);
          break;
        }
        case "MILESTONE_BONUS": {
          const { amount } = ev.data as { amount: number; segmentCount: number };
          this.damagePopup.showText(`Milestone +${amount} 🪙`, 0xffcc00);
          break;
        }
        case "GAME_OVER": {
          const d = ev.data as {
            distanceKm: number; gold: number;
            totalGoldCollected: number; totalPremiumsPaid: number; totalDisasterDamage: number
          };
          this.time.delayedCall(800, () => {
            this.scene.start("GameOverScene", {
              mode: this.engine.getState().mode,
              distanceKm: d.distanceKm,
              totalGoldCollected: d.totalGoldCollected,
              totalPremiumsPaid: d.totalPremiumsPaid,
              totalDisasterDamage: d.totalDisasterDamage,
              phase: this.engine.getState().phase,
              bestCombo: this.engine.getState().bestCombo,
              disastersCovered: this.engine.getState().disastersCovered,
              disastersUncovered: this.engine.getState().disastersUncovered,
            });
          });
          break;
        }
      }
    }
  }

  private togglePause(): void {
    const paused = this.engine.getState().isPaused;
    this.engine.setPaused(!paused);
    if (!paused) {
      this.hud.showPauseOverlay();
    } else {
      this.hud.hidePauseOverlay();
    }
  }
}
