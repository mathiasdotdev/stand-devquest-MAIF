extends Node

# Autoload Music : musique de fond persistante entre les changements de scène.
# - Joue knightcore.ogg en boucle dès le démarrage du jeu
# - Volume réglable (linéaire 0..1) via set_volume(), persisté dans user://audio.cfg
# - Survit aux changements de scène (autoload)
# - process_mode = ALWAYS pour continuer pendant les pauses

const TRACK_PATH := "res://jeu_sortez_couvert/ui/assets/knightcore.ogg"
const AUDIO_CONFIG := "user://audio.cfg"

# Volume linéaire par défaut (0..1). 0.25 ≈ -12 dB : un peu en dessous des SFX
# pour ne pas couvrir les clics et la voix-off du dialogue.
const DEFAULT_VOLUME := 0.25

var _player: AudioStreamPlayer
var _volume: float = DEFAULT_VOLUME

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_volume()
	_player = AudioStreamPlayer.new()
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_player.volume_db = _to_db(_volume)
	# Le bus "Music" n'existe pas par défaut — on reste sur "Master".
	# Le volume est géré directement sur le player (un seul, persistant).
	_player.bus = "Master"
	add_child(_player)

	if ResourceLoader.exists(TRACK_PATH):
		var stream: AudioStream = load(TRACK_PATH)
		if stream != null:
			# La boucle est définie côté import (.ogg.import → loop=true).
			_player.stream = stream
			_player.play()

# ─── API publique ────────────────────────────────────────────────────────────

func stop() -> void:
	if _player != null:
		_player.stop()

func play() -> void:
	if _player != null and _player.stream != null and not _player.playing:
		_player.play()

func get_volume() -> float:
	return _volume

func set_volume(linear: float) -> void:
	_volume = clampf(linear, 0.0, 1.0)
	if _player != null:
		_player.volume_db = _to_db(_volume)
	_save_volume()

func is_playing() -> bool:
	return _player != null and _player.playing

# ─── Persistence volume ───────────────────────────────────────────────────────

func _to_db(linear: float) -> float:
	# linear_to_db(0) = -inf : on clampe à -80 dB (silence) pour éviter -inf.
	return -80.0 if linear <= 0.0 else linear_to_db(linear)

func _load_volume() -> void:
	if not FileAccess.file_exists(AUDIO_CONFIG):
		return
	var cfg := ConfigFile.new()
	if cfg.load(AUDIO_CONFIG) != OK:
		return
	_volume = clampf(float(cfg.get_value("audio", "music", DEFAULT_VOLUME)), 0.0, 1.0)

func _save_volume() -> void:
	var cfg := ConfigFile.new()
	# Charge l'existant pour ne pas écraser la clé "sfx" gérée par l'autoload Sfx.
	cfg.load(AUDIO_CONFIG)
	cfg.set_value("audio", "music", _volume)
	cfg.save(AUDIO_CONFIG)
