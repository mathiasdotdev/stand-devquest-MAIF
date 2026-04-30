import Phaser from "phaser";
import { DISASTERS_CONFIG } from "../core/shared/config/disastersConfig";
import type { ActiveContract } from "../core/shared/models/Contract";
import type { Fork } from "../core/infini/models/Fork";
import type { Path } from "../core/infini/models/Path";
import { GameEngine } from "../core/infini/services/GameEngine";

interface MapSceneData {
  engine: GameEngine;
}

const TILE_SIZE = 24;
const NODE_GAP = 8;
const NODE_STRIDE = TILE_SIZE + NODE_GAP;

const PATH_TINTS: Record<string, number> = {
  safe: 0x44ff88,
  risky: 0xffaa22,
  dangerous: 0xff4444,
};

export class MapScene extends Phaser.Scene {
  private engine!: GameEngine;
  private selectedIndex = 0;
  private forkCircles: {
    index: number;
    circle: Phaser.GameObjects.Arc;
    baseColor: number;
    isLocked: boolean;
  }[] = [];
  private detailText!: Phaser.GameObjects.Text;

  constructor() {
    super("MapScene");
  }

  init(data: MapSceneData): void {
    this.engine = data.engine;
    this.selectedIndex = 0;
    this.forkCircles = [];
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    this.add.rectangle(w / 2, h / 2, w, h, 0x0a0a1a);

    this.add
      .text(w / 2, 18, "📍 Choisissez votre prochain chemin", {
        fontSize: "16px",
        color: "#ffdd88",
        fontStyle: "bold",
      })
      .setOrigin(0.5, 0);

    const mapPanelX = 20;
    const mapPanelW = Math.floor(w * 0.62);
    const mapPanelH = h - 110;
    this.add
      .rectangle(mapPanelX + mapPanelW / 2, 45 + mapPanelH / 2, mapPanelW, mapPanelH, 0x111122, 0.9)
      .setStrokeStyle(1, 0x334488);

    const infoPanelX = mapPanelX + mapPanelW + 10;
    const infoPanelW = w - infoPanelX - 10;
    this.add
      .rectangle(infoPanelX + infoPanelW / 2, 45 + mapPanelH / 2, infoPanelW, mapPanelH, 0x111122, 0.9)
      .setStrokeStyle(1, 0x334488);

    this.drawInfoPanel(infoPanelX, 50, infoPanelW);
    this.drawMap(mapPanelX + 10, 55, mapPanelW - 20, mapPanelH - 20);
    this.drawBottomBar(h, w);

    // Clavier : event.key est fiable sur tous les layouts
    this.input.keyboard!.on("keydown", (event: KeyboardEvent) => {
      switch (event.key) {
        case "1":
          this.selectPath(0);
          break;
        case "2":
          this.selectPath(1);
          break;
        case "3":
          this.selectPath(2);
          break;
        case "ArrowLeft":
          this.navigatePath(-1);
          break;
        case "ArrowRight":
          this.navigatePath(1);
          break;
        case "Enter":
          this.confirmChoice();
          break;
      }
    });

    // Affiche le détail du chemin sélectionné par défaut
    this.showPathDetail(this.selectedIndex);

    this.cameras.main.fadeIn(300, 0, 0, 0);
  }

  // ── Panneau info droite ──────────────────────────────────────────────────

  private drawInfoPanel(x: number, y: number, panelW: number): void {
    const state = this.engine.getState();

    this.add.text(x + 10, y, `💰 ${state.gold} or`, {
      fontSize: "14px",
      color: "#ffdd44",
      fontStyle: "bold",
    });
    this.add.text(x + 10, y + 22, `📍 ${Math.floor(state.distanceKm * 1000)} m`, {
      fontSize: "12px",
      color: "#88aacc",
    });
    this.add.text(x + 10, y + 50, "Contrats actifs :", {
      fontSize: "11px",
      color: "#aabbdd",
    });

    if (state.activeContracts.length === 0) {
      this.add.text(x + 10, y + 66, "Aucun contrat", { fontSize: "11px", color: "#886666" });
    } else {
      state.activeContracts.forEach((c, i) => {
        const penalty = c.penaltyMultiplier > 1 ? ` (+${Math.round((c.penaltyMultiplier - 1) * 100)}%)` : "";
        this.add.text(x + 10, y + 66 + i * 16, `• ${c.type} [${c.level}]${penalty}`, {
          fontSize: "10px",
          color: "#88ffaa",
        });
      });
    }

    const legendY = y + 180;
    this.add.text(x + 10, legendY, "Légende :", { fontSize: "11px", color: "#aabbdd" });
    const legend = [
      { color: 0x44ff88, label: "Chemin sûr" },
      { color: 0xffaa22, label: "Risqué" },
      { color: 0xff4444, label: "Dangereux" },
      { color: 0x882222, label: "🔒 Bloqué" },
      { color: 0x4488ff, label: "🏠 Agence" },
      { color: 0x334455, label: "Fog of war" },
    ];
    legend.forEach((item, i) => {
      this.add.rectangle(x + 16, legendY + 20 + i * 18, 10, 10, item.color);
      this.add.text(x + 26, legendY + 15 + i * 18, item.label, {
        fontSize: "10px",
        color: "#ccddee",
      });
    });

    this.detailText = this.add.text(x + 10, legendY + 130, "", {
      fontSize: "10px",
      color: "#ffdd88",
      wordWrap: { width: panelW - 20 },
    });
  }

  // ── Carte ────────────────────────────────────────────────────────────────

  private drawMap(x: number, y: number, _w: number, _h: number): void {
    const state = this.engine.getState();
    const history = state.mapHistory;
    const currentFork = state.currentFork;

    const centerX = x + _w / 2;
    let curY = y + TILE_SIZE / 2;

    this.drawNode(centerX, curY, 0x888888, "⚑", 1.0);
    curY += NODE_STRIDE;

    for (const entry of history) {
      curY = this.drawHistoryRow(entry.fork, entry.pathChosen, centerX, curY, _w);
    }

    if (currentFork) {
      this.drawCurrentFork(currentFork, centerX, curY, _w);
    }
  }

  private drawHistoryRow(fork: Fork, chosenIndex: number, centerX: number, startY: number, mapW: number): number {
    const paths = fork.paths;
    const count = paths.length;
    const spacing = Math.min(NODE_STRIDE * 3, mapW / (count + 1));
    const baseX = centerX - (spacing * (count - 1)) / 2;

    this.add.line(0, 0, centerX, startY - NODE_STRIDE / 2, centerX, startY, 0x444466, 0.6).setOrigin(0);

    paths.forEach((path, i) => {
      const nx = baseX + i * spacing;
      const isChosen = i === chosenIndex;
      const color = isChosen ? (path.isAgency ? 0x4488ff : (PATH_TINTS[path.risk] ?? 0x888888)) : 0x334455;
      const alpha = isChosen ? 1.0 : 0.4;

      this.add.line(0, 0, centerX, startY - NODE_STRIDE / 2, nx, startY, 0x334466, alpha * 0.5).setOrigin(0);
      this.drawNode(nx, startY, color, this.pathIcon(path, false), alpha);
    });

    return startY + NODE_STRIDE;
  }

  private drawCurrentFork(fork: Fork, centerX: number, startY: number, mapW: number): void {
    const state = this.engine.getState();
    const paths = fork.paths;
    const count = paths.length;
    const spacing = Math.min(NODE_STRIDE * 3, mapW / (count + 1));
    const baseX = centerX - (spacing * (count - 1)) / 2;

    this.add.line(0, 0, centerX, startY - NODE_STRIDE / 2, centerX, startY - 4, 0x4466aa, 1).setOrigin(0);

    paths.forEach((path, i) => {
      const nx = baseX + i * spacing;
      const isLocked = this.isPathLocked(path, state.activeContracts);
      const isSelected = i === this.selectedIndex && !isLocked;

      const baseColor = isLocked ? 0x441111 : path.isAgency ? 0x4488ff : (PATH_TINTS[path.risk] ?? 0x888888);
      const strokeColor = isSelected ? 0xffdd00 : isLocked ? 0x882222 : baseColor;

      this.add.line(0, 0, centerX, startY - NODE_STRIDE / 2, nx, startY, 0x4466aa, 0.8).setOrigin(0);

      // Cercle interactif
      const circle = this.add
        .circle(nx, startY, TILE_SIZE / 2, baseColor, isSelected ? 0.6 : 0.25)
        .setStrokeStyle(isSelected ? 3 : 1.5, strokeColor);

      this.forkCircles.push({ index: i, circle, baseColor, isLocked });

      // Icône
      this.add.text(nx, startY, this.pathIcon(path, isLocked), { fontSize: "14px" }).setOrigin(0.5);

      // Label clé — en dessous du cercle, en coordonnées monde
      this.add
        .text(nx, startY + TILE_SIZE / 2 + 6, `[${i + 1}]`, {
          fontSize: "10px",
          color: isLocked ? "#664444" : "#ffdd88",
        })
        .setOrigin(0.5, 0);

      // Multiplicateur
      this.add
        .text(nx, startY + TILE_SIZE / 2 + 18, `×${path.coinMultiplier.toFixed(1)}`, {
          fontSize: "9px",
          color: isLocked ? "#553333" : "#aaddff",
        })
        .setOrigin(0.5, 0);

      // Interactivité clic
      if (!isLocked) {
        circle.setInteractive(new Phaser.Geom.Circle(0, 0, TILE_SIZE / 2 + 4), Phaser.Geom.Circle.Contains);
        circle.on("pointerover", () => {
          circle.setStrokeStyle(3, 0xffffff);
          this.showPathDetail(i);
        });
        circle.on("pointerout", () => {
          const sel = this.selectedIndex === i;
          circle.setStrokeStyle(sel ? 3 : 1.5, sel ? 0xffdd00 : baseColor);
        });
        circle.on("pointerdown", () => this.selectPath(i));
      }
    });
  }

  private drawNode(x: number, y: number, color: number, icon: string, alpha: number): void {
    this.add.circle(x, y, TILE_SIZE / 2, color, 0.3 * alpha).setStrokeStyle(1.5, color);
    this.add.text(x, y, icon, { fontSize: "12px" }).setOrigin(0.5).setAlpha(alpha);
  }

  private pathIcon(path: Path, isLocked: boolean): string {
    if (isLocked) return "🔒";
    if (path.isAgency) return "🏠";
    if (path.disasterType) {
      return DISASTERS_CONFIG[path.disasterType].icon;
    }
    const icons: Record<string, string> = { safe: "✅", risky: "⚠️", dangerous: "💥" };
    return icons[path.risk] ?? "?";
  }

  private isPathLocked(path: Path, contracts: readonly ActiveContract[]): boolean {
    return !!(
      path.isMajor &&
      path.disasterType &&
      !contracts.some((c) => DISASTERS_CONFIG[path.disasterType!].coveringContracts.includes(c.type))
    );
  }

  // ── Barre du bas ──────────────────────────────────────────────────────────

  private drawBottomBar(h: number, w: number): void {
    const barY = h - 45;

    this.add.rectangle(w / 2, barY + 15, w, 50, 0x080818, 0.95).setStrokeStyle(1, 0x334488);

    this.add
      .text(w / 2, barY + 4, "[1] [2] [3]  ou  [←][→] + [Entrée]  pour choisir", {
        fontSize: "11px",
        color: "#6677aa",
      })
      .setOrigin(0.5, 0);
  }

  // ── Sélection ────────────────────────────────────────────────────────────

  private navigatePath(dir: number): void {
    const fork = this.engine.getState().currentFork;
    if (!fork) return;
    const count = fork.paths.length;
    const state = this.engine.getState();
    let next = (this.selectedIndex + dir + count) % count;
    let attempts = 0;
    while (attempts < count) {
      if (!this.isPathLocked(fork.paths[next], state.activeContracts)) break;
      next = (next + dir + count) % count;
      attempts++;
    }
    this.selectedIndex = next;
    this.updateSelectionVisual();
    this.showPathDetail(next);
  }

  private selectPath(index: number): void {
    const fork = this.engine.getState().currentFork;
    if (!fork || index >= fork.paths.length) return;
    if (this.isPathLocked(fork.paths[index], this.engine.getState().activeContracts)) return;
    this.selectedIndex = index;
    this.confirmChoice();
  }

  private confirmChoice(): void {
    const fork = this.engine.getState().currentFork;
    if (!fork) {
      this.transitionToPlatformer();
      return;
    }

    const state = this.engine.getState();
    const chosen = fork.paths[this.selectedIndex];
    if (this.isPathLocked(chosen, state.activeContracts)) {
      const accessible = fork.paths.findIndex((p) => !this.isPathLocked(p, state.activeContracts));
      if (accessible < 0) return;
      this.selectedIndex = accessible;
    }

    this.engine.choosePath(this.selectedIndex);
    this.transitionToPlatformer();
  }

  private transitionToPlatformer(): void {
    // Désactiver les inputs pour éviter double-appel
    this.input.keyboard!.removeAllListeners();
    this.input.removeAllListeners();

    this.cameras.main.fadeOut(300, 0, 0, 0);
    this.cameras.main.once("camerafadeoutcomplete", () => {
      this.scene.start("PlatformerScene", { engine: this.engine });
    });
  }

  private updateSelectionVisual(): void {
    for (const { index, circle, baseColor, isLocked } of this.forkCircles) {
      if (isLocked) continue;
      const isSelected = index === this.selectedIndex;
      circle.setStrokeStyle(isSelected ? 3 : 1.5, isSelected ? 0xffdd00 : baseColor);
      circle.setFillStyle(baseColor, isSelected ? 0.6 : 0.25);
    }
  }

  private showPathDetail(index: number): void {
    const fork = this.engine.getState().currentFork;
    if (!fork || !this.detailText) return;
    const path = fork.paths[index];
    if (!path) return;
    const disasterInfo = path.disasterType
      ? `\n${DISASTERS_CONFIG[path.disasterType].icon} ${DISASTERS_CONFIG[path.disasterType].label}${path.isMajor ? " (OBLIGATOIRE)" : ""}`
      : "\nAucun sinistre";
    this.detailText.setText(
      `Chemin ${index + 1} : ${path.label}\n` +
        `Risque : ${{ safe: "faible", risky: "risqué", dangerous: "dangereux" }[path.risk] ?? path.risk}\n` +
        `Or : ×${path.coinMultiplier.toFixed(1)}` +
        disasterInfo,
    );
  }
}
