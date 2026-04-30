import Phaser from "phaser";
import type { GameMode } from "../core/shared/models/GameMode";
import { LeaderboardStore } from "../persistence/LeaderboardStore";
import { formatDistance } from "../core/shared/utils/math";

export class LeaderboardScene extends Phaser.Scene {
  private currentMode: GameMode = "story";

  constructor() {
    super("LeaderboardScene");
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    this.add.rectangle(w / 2, h / 2, w, h, 0x000022, 1);

    this.add.text(w / 2, 30, "🏆 Classement", {
      fontSize: "32px",
      color: "#ffcc00",
      fontStyle: "bold",
    }).setOrigin(0.5);

    // Onglets
    const storyTab = this.add.text(w / 2 - 90, 80, "Mode Histoire", {
      fontSize: "16px",
      color: "#ffffff",
    }).setOrigin(0.5).setInteractive({ useHandCursor: true });
    const infiniteTab = this.add.text(w / 2 + 90, 80, "Mode Infini", {
      fontSize: "16px",
      color: "#aaaaaa",
    }).setOrigin(0.5).setInteractive({ useHandCursor: true });

    storyTab.on("pointerdown", () => {
      this.currentMode = "story";
      storyTab.setColor("#ffffff");
      infiniteTab.setColor("#aaaaaa");
      this.refreshList(listContainer, w);
    });
    infiniteTab.on("pointerdown", () => {
      this.currentMode = "infinite";
      infiniteTab.setColor("#ffffff");
      storyTab.setColor("#aaaaaa");
      this.refreshList(listContainer, w);
    });

    // Liste
    const listContainer = this.add.container(0, 0);
    this.refreshList(listContainer, w);

    // Retour menu
    const backBtn = this.add.text(w / 2, h - 40, "← Retour au menu", {
      fontSize: "16px",
      color: "#4499ff",
    }).setOrigin(0.5).setInteractive({ useHandCursor: true });
    backBtn.on("pointerdown", () => this.scene.start("MenuScene"));
    this.input.keyboard!.once("keydown-ESC", () => this.scene.start("MenuScene"));
  }

  private refreshList(container: Phaser.GameObjects.Container, w: number): void {
    container.removeAll(true);

    const entries = LeaderboardStore.getEntries(this.currentMode);
    if (entries.length === 0) {
      container.add(
        this.add.text(w / 2, 180, "Aucun score enregistré.", {
          fontSize: "16px",
          color: "#667788",
        }).setOrigin(0.5)
      );
      return;
    }

    entries.slice(0, 10).forEach((entry, i) => {
      const y = 130 + i * 38;
      const rankColors = ["#ffcc00", "#aaaaaa", "#cc8833"];
      const rankColor = i < 3 ? rankColors[i] : "#778899";

      container.add(this.add.text(w / 2 - 220, y, `${i + 1}.`, { fontSize: "16px", color: rankColor }));
      container.add(this.add.text(w / 2 - 190, y, entry.name, { fontSize: "16px", color: "#ffffff" }));
      container.add(this.add.text(w / 2 + 60,  y, formatDistance(entry.distanceKm), { fontSize: "16px", color: "#aaddff" }).setOrigin(1, 0));
      container.add(this.add.text(w / 2 + 140, y, new Date(entry.timestamp).toLocaleDateString("fr-FR"), { fontSize: "12px", color: "#556677" }));
    });
  }
}
