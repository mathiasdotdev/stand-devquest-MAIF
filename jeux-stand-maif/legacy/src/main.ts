import Phaser from "phaser";
import { BootScene } from "./scenes/BootScene";
import { MenuScene } from "./scenes/MenuScene";
import { PlatformerScene } from "./scenes/PlatformerScene";
import { MapScene } from "./scenes/MapScene";
import { AgencyScene } from "./scenes/AgencyScene";
import { GameOverScene } from "./scenes/GameOverScene";
import { LeaderboardScene } from "./scenes/LeaderboardScene";
import { AdminScene } from "./scenes/AdminScene";
import { StoryIntroScene } from "./scenes/story/StoryIntroScene";
import { ChapitreIntroScene } from "./scenes/story/ChapitreIntroScene";
import { ContractSelectionScene } from "./scenes/story/ContractSelectionScene";
import { DisasterRevealScene } from "./scenes/story/DisasterRevealScene";
import { ChapitreResultScene } from "./scenes/story/ChapitreResultScene";
import { StoryAnalysisScene } from "./scenes/story/StoryAnalysisScene";

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  parent: document.body,
  backgroundColor: "#000011",
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
    width: 900,
    height: 550,
  },
  physics: {
    default: "arcade",
    arcade: {
      gravity: { x: 0, y: 0 },
      debug: false,
    },
  },
  scene: [
    BootScene, MenuScene,
    PlatformerScene, MapScene, AgencyScene, GameOverScene, LeaderboardScene, AdminScene,
    StoryIntroScene, ChapitreIntroScene, ContractSelectionScene,
    DisasterRevealScene, ChapitreResultScene, StoryAnalysisScene,
  ],
};

new Phaser.Game(config);
