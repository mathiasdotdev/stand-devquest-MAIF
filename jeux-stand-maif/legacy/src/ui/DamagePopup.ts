import Phaser from "phaser";
import type { DisasterResult } from "../core/shared/models/Disaster";
import { DISASTERS_CONFIG } from "../core/shared/config/disastersConfig";

export class DamagePopup {
  private scene: Phaser.Scene;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
  }

  showDisaster(result: DisasterResult): void {
    const def = DISASTERS_CONFIG[result.type];
    const icon = def?.icon ?? "⚠️";
    const label = def?.label ?? "Sinistre";

    if (result.wasCovered) {
      const msg = result.franchiseAmount > 0
        ? `${icon} ${label} (franchise -${result.franchiseAmount}🪙)`
        : `${icon} ${label} — Couvert ✅`;
      this.showText(msg, 0x33cc66);
    } else {
      this.showText(`${icon} ${label} — -${result.actualCost}🪙 !`, 0xff3333);
    }
  }

  showTick(amount: number): void {
    if (amount <= 0) return;
    this.showText(`📋 Primes : -${amount}🪙`, 0xffaa33);
  }

  showText(message: string, color: number = 0xffffff): void {
    const w = this.scene.scale.width;
    const h = this.scene.scale.height;

    const colorHex = "#" + color.toString(16).padStart(6, "0");
    const text = this.scene.add.text(w / 2, h * 0.42, message, {
      fontSize: "20px",
      color: colorHex,
      fontStyle: "bold",
      stroke: "#000000",
      strokeThickness: 4,
      shadow: { offsetX: 2, offsetY: 2, color: "#000000", blur: 4, fill: true },
    })
      .setOrigin(0.5)
      .setDepth(30)
      .setScrollFactor(0);

    this.scene.tweens.add({
      targets: text,
      y: text.y - 60,
      alpha: 0,
      duration: 1800,
      ease: "Power2",
      onComplete: () => text.destroy(),
    });
  }
}
