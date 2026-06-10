extends Node

# Autoload Sfx : centralise les sons UI du jeu.
# - Précharge les sons à l'init
# - Auto-câblage : chaque Button qui entre dans l'arbre reçoit un son on press,
#   choisi via une heuristique sur le nom (Quit/Retour/Back/Cancel/Fermer -> back,
#   Confirm/Start/Continue/Commencer/Valider/Continue -> selection,
#   Indice/Hint -> hint, sinon -> click).
# - Override possible via `btn.set_meta("_sfx", "<name>")`.
# - Sons "win" / "fail" déclenchés manuellement depuis le code (résultat chapitre).
# - "switch" déclenché manuellement (modale admin leaderboard via F10).

const SFX_DIR := "res://jeu_sortez_couvert/ui/assets/kenney_interface-sounds/Audio/"
const AUDIO_CONFIG := "user://audio.cfg"

# Volume linéaire par défaut (0..1). 1.0 = 0 dB (pleine échelle), le réglage d'origine.
const DEFAULT_VOLUME := 1.0

const SOUND_FILES := {
	"click":   "click_005.ogg",
	"back":    "click_001.ogg",
	"selection": "click_003.ogg",
	"hint":    "question_002.ogg",
	"win":     "confirmation_004.ogg",
	"fail":    "error_003.ogg",
	"switch":  "switch_004.ogg"
}

var _streams: Dictionary = {}
var _volume: float = DEFAULT_VOLUME

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_volume()
	for key in SOUND_FILES.keys():
		var stream: AudioStream = load(SFX_DIR + SOUND_FILES[key])
		if stream != null:
			_streams[key] = stream
	get_tree().node_added.connect(_on_node_added)
	_wire_existing(get_tree().root)

# ─── API publique ────────────────────────────────────────────────────────────

func play(sound_name: String) -> void:
	var stream: AudioStream = _streams.get(sound_name)
	if stream == null:
		return
	if _volume <= 0.0:
		return  # muet : inutile de créer un player
	var player := AudioStreamPlayer.new()
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.stream = stream
	player.volume_db = _to_db(_volume)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

func get_volume() -> float:
	return _volume

func set_volume(linear: float) -> void:
	_volume = clampf(linear, 0.0, 1.0)
	_save_volume()

# ─── Auto-câblage des Buttons ────────────────────────────────────────────────

func _on_node_added(node: Node) -> void:
	if node is Button:
		_wire_button(node)

func _wire_existing(node: Node) -> void:
	if node is Button:
		_wire_button(node)
	for child in node.get_children():
		_wire_existing(child)

func _wire_button(btn: Button) -> void:
	if btn.has_meta("_sfx_wired"):
		return
	btn.set_meta("_sfx_wired", true)
	btn.pressed.connect(_on_button_pressed.bind(btn))

func _on_button_pressed(btn: Button) -> void:
	var sound: String = ""
	if btn.has_meta("_sfx"):
		sound = String(btn.get_meta("_sfx"))
	else:
		sound = _detect_sound_from_name(btn.name)
	play(sound)

func _detect_sound_from_name(node_name: StringName) -> String:
	var lname := String(node_name).to_lower()
	if lname.contains("quit") or lname.contains("retour") or lname.contains("back") \
			or lname.contains("cancel") or lname.contains("fermer") or lname.contains("close"):
		return "back"
	if lname.contains("confirm") or lname.contains("start") or lname.contains("continue") \
			or lname.contains("commencer") or lname.contains("valider"):
		return "selection"
	if lname.contains("indice") or lname.contains("hint"):
		return "hint"
	return "click"

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
	_volume = clampf(float(cfg.get_value("audio", "sfx", DEFAULT_VOLUME)), 0.0, 1.0)

func _save_volume() -> void:
	var cfg := ConfigFile.new()
	# Charge l'existant pour ne pas écraser la clé "music" gérée par l'autoload Music.
	cfg.load(AUDIO_CONFIG)
	cfg.set_value("audio", "sfx", _volume)
	cfg.save(AUDIO_CONFIG)
