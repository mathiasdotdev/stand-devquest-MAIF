extends Node

const SAVE_PATH: String = "user://balance.cfg"

# Defaults — ces valeurs servent au reset.
const D_STARTING_GOLD: int = 100
const D_RACE_DURATION: float = 90.0
const D_SPEED_TOP: float = 18.0
const D_SPEED_MULTIPLIER_MAX: float = 3.0
const D_IMPACT_COST_FACTOR: float = 4.0
const D_IMPACT_COST_MIN: float = 4.0
const D_IMPACT_COST_MAX: float = 40.0
const D_IMPACT_COOLDOWN_MS: int = 350
const D_STUN_DURATION_MS: int = 1000
const D_PVP_REBOUND_FORCE: float = 6000.0
const D_PVP_SIDE_THRESHOLD: float = 0.3
const D_PVP_COOLDOWN_MS: int = 250
const D_DRIFT_THRESHOLD: float = 0.25
const D_NO_STUN_SPEED_RATIO: float = 0.85
const D_NO_STUN_GOLD_REWARD: int = 5
const D_NO_STUN_SPEED_PENALTY: float = 0.8

# Valeurs runtime (lues partout dans le code, modifiables via le panel admin).
var starting_gold: int
var race_duration: float
var speed_top: float
var speed_multiplier_max: float
var impact_cost_factor: float
var impact_cost_min: float
var impact_cost_max: float
var impact_cooldown_ms: int
var stun_duration_ms: int
var pvp_rebound_force: float
var pvp_side_threshold: float
var pvp_cooldown_ms: int
var drift_threshold: float
var no_stun_speed_ratio: float
var no_stun_gold_reward: int
var no_stun_speed_penalty: float

func _ready() -> void:
	reset_to_defaults()
	load_from_file()

func reset_to_defaults() -> void:
	starting_gold = D_STARTING_GOLD
	race_duration = D_RACE_DURATION
	speed_top = D_SPEED_TOP
	speed_multiplier_max = D_SPEED_MULTIPLIER_MAX
	impact_cost_factor = D_IMPACT_COST_FACTOR
	impact_cost_min = D_IMPACT_COST_MIN
	impact_cost_max = D_IMPACT_COST_MAX
	impact_cooldown_ms = D_IMPACT_COOLDOWN_MS
	stun_duration_ms = D_STUN_DURATION_MS
	pvp_rebound_force = D_PVP_REBOUND_FORCE
	pvp_side_threshold = D_PVP_SIDE_THRESHOLD
	pvp_cooldown_ms = D_PVP_COOLDOWN_MS
	drift_threshold = D_DRIFT_THRESHOLD
	no_stun_speed_ratio = D_NO_STUN_SPEED_RATIO
	no_stun_gold_reward = D_NO_STUN_GOLD_REWARD
	no_stun_speed_penalty = D_NO_STUN_SPEED_PENALTY

func load_from_file() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	starting_gold = int(cfg.get_value("balance", "starting_gold", starting_gold))
	race_duration = float(cfg.get_value("balance", "race_duration", race_duration))
	speed_top = float(cfg.get_value("balance", "speed_top", speed_top))
	speed_multiplier_max = float(cfg.get_value("balance", "speed_multiplier_max", speed_multiplier_max))
	impact_cost_factor = float(cfg.get_value("balance", "impact_cost_factor", impact_cost_factor))
	impact_cost_min = float(cfg.get_value("balance", "impact_cost_min", impact_cost_min))
	impact_cost_max = float(cfg.get_value("balance", "impact_cost_max", impact_cost_max))
	impact_cooldown_ms = int(cfg.get_value("balance", "impact_cooldown_ms", impact_cooldown_ms))
	stun_duration_ms = int(cfg.get_value("balance", "stun_duration_ms", stun_duration_ms))
	pvp_rebound_force = float(cfg.get_value("balance", "pvp_rebound_force", pvp_rebound_force))
	pvp_side_threshold = float(cfg.get_value("balance", "pvp_side_threshold", pvp_side_threshold))
	pvp_cooldown_ms = int(cfg.get_value("balance", "pvp_cooldown_ms", pvp_cooldown_ms))
	drift_threshold = float(cfg.get_value("balance", "drift_threshold", drift_threshold))
	no_stun_speed_ratio = float(cfg.get_value("balance", "no_stun_speed_ratio", no_stun_speed_ratio))
	no_stun_gold_reward = int(cfg.get_value("balance", "no_stun_gold_reward", no_stun_gold_reward))
	no_stun_speed_penalty = float(cfg.get_value("balance", "no_stun_speed_penalty", no_stun_speed_penalty))

func save_to_file() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("balance", "starting_gold", starting_gold)
	cfg.set_value("balance", "race_duration", race_duration)
	cfg.set_value("balance", "speed_top", speed_top)
	cfg.set_value("balance", "speed_multiplier_max", speed_multiplier_max)
	cfg.set_value("balance", "impact_cost_factor", impact_cost_factor)
	cfg.set_value("balance", "impact_cost_min", impact_cost_min)
	cfg.set_value("balance", "impact_cost_max", impact_cost_max)
	cfg.set_value("balance", "impact_cooldown_ms", impact_cooldown_ms)
	cfg.set_value("balance", "stun_duration_ms", stun_duration_ms)
	cfg.set_value("balance", "pvp_rebound_force", pvp_rebound_force)
	cfg.set_value("balance", "pvp_side_threshold", pvp_side_threshold)
	cfg.set_value("balance", "pvp_cooldown_ms", pvp_cooldown_ms)
	cfg.set_value("balance", "drift_threshold", drift_threshold)
	cfg.set_value("balance", "no_stun_speed_ratio", no_stun_speed_ratio)
	cfg.set_value("balance", "no_stun_gold_reward", no_stun_gold_reward)
	cfg.set_value("balance", "no_stun_speed_penalty", no_stun_speed_penalty)
	cfg.save(SAVE_PATH)
