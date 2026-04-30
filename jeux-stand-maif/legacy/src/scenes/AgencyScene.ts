import Phaser from "phaser";
import { GameEngine } from "../core/infini/services/GameEngine";
import { CONTRACTS_CONFIG } from "../core/shared/config/contractsConfig";
import type { ContractType, ContractLevel } from "../core/shared/models/Contract";

const AGENCY_TIMER_S = 12;

interface AgencyData {
  engine: GameEngine;
}

export class AgencyScene extends Phaser.Scene {
  private engine!: GameEngine;
  private timerText!: Phaser.GameObjects.Text;
  private timerVal = AGENCY_TIMER_S;
  private panel!: Phaser.GameObjects.Container;
  private contractRows: Phaser.GameObjects.Container[] = [];

  constructor() {
    super("AgencyScene");
  }

  init(data: AgencyData): void {
    this.engine = data.engine;
    this.timerVal = AGENCY_TIMER_S;
  }

  create(): void {
    const w = this.scale.width;
    const h = this.scale.height;

    // Overlay semi-transparent
    this.add.rectangle(w / 2, h / 2, w, h, 0x000000, 0.6);

    // Modal
    const modalW = Math.min(560, w - 40);
    const modalH = Math.min(480, h - 40);
    const mx = w / 2;
    const my = h / 2;

    const bg = this.add.rectangle(mx, my, modalW, modalH, 0x111133, 0.97);
    bg.setStrokeStyle(2, 0x4477cc);

    // Titre
    this.add.text(mx, my - modalH / 2 + 24, "🏢 Agence MAIF", {
      fontSize: "22px",
      color: "#ffffff",
      fontStyle: "bold",
    }).setOrigin(0.5);

    // Or actuel
    const state = this.engine.getState();
    this.add.text(mx, my - modalH / 2 + 54, `Or disponible : ${Math.floor(state.gold)} 🪙`, {
      fontSize: "16px",
      color: "#ffcc00",
    }).setOrigin(0.5);

    // Timer
    this.timerText = this.add.text(mx, my - modalH / 2 + 76, `Fermeture dans ${this.timerVal}s`, {
      fontSize: "13px",
      color: "#ff6644",
    }).setOrigin(0.5);

    // Contrats
    const startY = my - modalH / 2 + 110;
    const rowH = 56;
    CONTRACTS_CONFIG.forEach((def, i) => {
      this.createContractRow(mx, startY + i * rowH, def.type, def.label, def.icon, modalW - 20);
    });

    // Bouton fermer
    const closeBtn = this.add.text(mx, my + modalH / 2 - 24, "[ ENTRÉE ] Fermer", {
      fontSize: "15px",
      color: "#aabbcc",
    }).setOrigin(0.5).setInteractive({ useHandCursor: true });
    closeBtn.on("pointerdown", () => this.close());
    this.input.keyboard!.once("keydown-ENTER", () => this.close());
    this.input.keyboard!.once("keydown-ESC",   () => this.close());

    // Timer décompte
    this.time.addEvent({
      delay: 1000,
      repeat: AGENCY_TIMER_S - 1,
      callback: () => {
        this.timerVal--;
        this.timerText.setText(`Fermeture dans ${this.timerVal}s`);
        if (this.timerVal <= 0) this.close();
      },
    });
  }

  private createContractRow(x: number, y: number, type: ContractType, label: string, icon: string, _width: number): void {
    const state = this.engine.getState();
    const isActive = state.activeContracts.some((c) => c.type === type);
    const isPending = state.pendingContracts.some((c) => c.type === type);
    const contract = state.activeContracts.find((c) => c.type === type);
    const pending = state.pendingContracts.find((c) => c.type === type);

    const def = CONTRACTS_CONFIG.find((c) => c.type === type)!;

    let statusText = "";
    let statusColor = "#aaaaaa";
    if (isActive) {
      statusText = `✅ Actif (${contract!.level}) — Prime: ${def.levels[contract!.level].premiumPerTick}/tick`;
      statusColor = "#33ff88";
    } else if (isPending) {
      const rem = pending!.activatesAtSegment - state.currentSegmentIndex;
      statusText = `⏳ En carence (${rem} segments)`;
      statusColor = "#ffaa33";
    } else {
      statusText = `Basique: ${def.levels.basique.premiumPerTick}/tick — Premium: ${def.levels.premium.premiumPerTick}/tick`;
    }

    this.add.text(x - 220, y - 10, `${icon} ${label}`, {
      fontSize: "14px",
      color: "#ffffff",
      fontStyle: "bold",
    });
    this.add.text(x - 220, y + 10, statusText, {
      fontSize: "11px",
      color: statusColor,
    });

    // Boutons d'action
    if (!isActive && !isPending) {
      this.createActionBtn(x + 50, y, "Basique", () => this.subscribe(type, "basique"), 0x225588);
      this.createActionBtn(x + 145, y, "Premium", () => this.subscribe(type, "premium"), 0x446688);
    } else if (isActive && contract!.level === "basique") {
      this.createActionBtn(x + 80, y, "↑ Upgrade", () => this.upgrade(type), 0x336633);
      this.createActionBtn(x + 175, y, "Résilier", () => this.cancel(type), 0x883322);
    } else if (isActive) {
      this.createActionBtn(x + 110, y, "Résilier", () => this.cancel(type), 0x883322);
    }
  }

  private createActionBtn(x: number, y: number, label: string, cb: () => void, color: number): void {
    const btn = this.add.rectangle(x, y, 80, 28, color)
      .setInteractive({ useHandCursor: true })
      .setStrokeStyle(1, 0xffffff, 0.3);
    const txt = this.add.text(x, y, label, { fontSize: "11px", color: "#ffffff" }).setOrigin(0.5);
    btn.on("pointerover",  () => btn.setAlpha(0.8));
    btn.on("pointerout",   () => btn.setAlpha(1.0));
    btn.on("pointerdown",  cb);
    void txt;
  }

  private subscribe(type: ContractType, level: ContractLevel): void {
    this.engine.subscribeContract(type, level);
    this.refreshRows();
  }

  private upgrade(type: ContractType): void {
    this.engine.upgradeContract(type);
    this.refreshRows();
  }

  private cancel(type: ContractType): void {
    this.engine.cancelContract(type);
    this.refreshRows();
  }

  private refreshRows(): void {
    // Redémarre la scène pour rafraîchir (simple mais efficace en Phase 2)
    this.scene.restart({ engine: this.engine });
  }

  private close(): void {
    this.engine.closeAgency();
    this.scene.stop("AgencyScene");
  }
}
