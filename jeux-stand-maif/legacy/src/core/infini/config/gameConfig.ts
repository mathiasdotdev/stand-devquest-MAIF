export const GAME_CONFIG = {
  // Économie de départ
  STARTING_GOLD: 350,

  // Segments et distance
  SEGMENT_LENGTH_KM: 0.1,   // 100m par segment
  TICK_INTERVAL: 5,          // segments entre deux prélèvements de primes
  CARENCE_DURATION: 2,       // segments d'attente avant activation d'un contrat

  // Vitesse (physique Phaser)
  SCROLL_SPEED_PX: 200,      // px/s (vitesse de scrolling du monde)
  SEGMENT_LENGTH_PX: 800,    // pixels par segment (= une "largeur d'écran")

  // Vitesse dérivée (km/s) = SCROLL_SPEED_PX / (SEGMENT_LENGTH_PX / SEGMENT_LENGTH_KM) / 1000
  // = 200 / 8000 / 1000 → calculé dans GameEngine
  PIXELS_PER_KM: 8000,       // 8000 px = 1 km

  // Phases (partagées mode infini)
  PHASE_2_START_SEGMENT: 30,   // 3 km
  PHASE_3_START_SEGMENT: 60,   // 6 km
  INFINITE_START_SEGMENT: 100, // Phase 4 : scaling continu

  // Multiplicateurs de coût des dommages par phase
  DAMAGE_MULTIPLIER: {
    1: 1.0,
    2: 1.5,
    3: 2.5,
  } as Record<1 | 2 | 3, number>,

  // Probabilité de sinistre par segment par phase
  DISASTER_PROB: {
    1: 0.12,
    2: 0.22,
    3: 0.38,
  } as Record<1 | 2 | 3, number>,

  // Probabilité de fork par segment par phase
  FORK_PROB: {
    1: 0.20,
    2: 0.30,
    3: 0.40,
  } as Record<1 | 2 | 3, number>,

  // Probabilité de faux positif sur les panneaux de fork (signal trompeur)
  FALSE_POSITIVE_PROB: {
    1: 0.35,
    2: 0.25,
    3: 0.15,
  } as Record<1 | 2 | 3, number>,

  // Agences MAIF
  AGENCY_INTERVAL_MIN: 12,   // min segments entre deux agences
  AGENCY_INTERVAL_MAX: 20,   // max segments entre deux agences
  FIRST_AGENCY_SEGMENT: 8,   // première agence

  // Pièces
  COIN_GROUND_VALUE: 3,
  COIN_AIR_VALUE: 8,
  COINS_PER_SEGMENT_MIN: 3,
  COINS_PER_SEGMENT_MAX: 7,
  AIRBORNE_COIN_PROB: 0.3,   // prob qu'une pièce soit en hauteur

  // Mode infini — combo
  COMBO_TIERS: [
    { threshold: 5,  label: "Prudent",  coinBonus: 0.15, tickFree: false, freeCover: false },
    { threshold: 10, label: "Avisé",    coinBonus: 0.30, tickFree: false, freeCover: false },
    { threshold: 15, label: "Expert",   coinBonus: 0.50, tickFree: true,  freeCover: false },
    { threshold: 20, label: "Légende",  coinBonus: 0.75, tickFree: true,  freeCover: true  },
  ],

  // Mode infini — milestones (tous les N segments)
  MILESTONE_INTERVAL: 50,
  MILESTONE_BASE_BONUS: 100, // +100 à N=50, +200 à N=100, etc. (+100 par palier)

  // Mode infini — scaling continu (validé par simulation : vise 180-350s avg)
  INFINITE_COST_SCALE_PER_SEGMENT: 0.018,    // +1.8% par segment → ×2.8 à seg 50
  INFINITE_DISASTER_SCALE_PER_SEGMENT: 0.012, // +1.2% par segment → prob × 1.6 à seg 50

  // Position du sol (surface, en fraction de la hauteur écran)
  // Partagé entre GameScene (physics) et SegmentRenderer (visuel)
  GROUND_Y_RATIO: 0.82,

  // Player physics
  PLAYER_JUMP_VELOCITY: -520,
  PLAYER_GRAVITY: 1200,
  PLAYER_SLIDE_DURATION_MS: 500,

  // Obstacle
  OBSTACLE_HIGH_MIN_HEIGHT: 40, // obstacles hauts nécessitent un saut
};
