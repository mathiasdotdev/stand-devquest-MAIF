extends Node

# Autoload Music : musique de fond persistante entre les changements de scène.
# - Joue knightcore.ogg en boucle dès le démarrage du jeu
# - Volume ajustable via set_volume() / mute via stop()
# - Survit aux changements de scène (autoload)
# - process_mode = ALWAYS pour continuer pendant les pauses

const TRACK_PATH := "res://jeu_sortez_couvert/ui/assets/knightcore.ogg"

# Volume initial (en dB). -12 dB = un peu en dessous des SFX pour ne pas couvrir
# les clics et la voix-off du dialogue.
const DEFAULT_VOLUME_DB := -12.0

var _player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = AudioStreamPlayer.new()
	_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_player.volume_db = DEFAULT_VOLUME_DB
	# Le bus "Music" n'existe pas par défaut — on reste sur "Master".
	# Si tu veux un slider musique/sfx séparé plus tard, créer un bus dédié.
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

func set_volume(db: float) -> void:
	if _player != null:
		_player.volume_db = db

func is_playing() -> bool:
	return _player != null and _player.playing
