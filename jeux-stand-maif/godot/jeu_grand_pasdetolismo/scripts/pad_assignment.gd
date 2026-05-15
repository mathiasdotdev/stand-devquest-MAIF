extends Control

const COLOR_LABELS: Dictionary = {
	"yellow": "Jaune",
	"green":  "Vert",
	"purple": "Violet",
	"red":    "Rouge",
}
const COLOR_RGB: Dictionary = {
	"yellow": Color(0.98, 0.82, 0.18),
	"green":  Color(0.34, 0.78, 0.41),
	"purple": Color(0.62, 0.36, 0.86),
	"red":    Color(0.87, 0.27, 0.27),
}

@onready var title_label: Label = $Center/VBox/Title
@onready var prompt_label: Label = $Center/VBox/Prompt
@onready var color_dot: ColorRect = $Center/VBox/ColorDot
@onready var progress_label: Label = $Center/VBox/Progress
@onready var hint_label: Label = $Center/VBox/Hint
@onready var btn_back: Button = $Footer/BtnBack

var _pending_indices: Array = []
var _current: int = 0
var _assigned_devices: Array = []

func _ready() -> void:
	btn_back.pressed.connect(_on_back)
	for i in RaceSession.players.size():
		var p: Dictionary = RaceSession.players[i]
		if String(p.get("control_scheme", "")) == "pad":
			_pending_indices.append(i)
	if _pending_indices.is_empty():
		_proceed_to_race()
		return
	_show_next_prompt()

func _show_next_prompt() -> void:
	if _current >= _pending_indices.size():
		_proceed_to_race()
		return
	var idx: int = int(_pending_indices[_current])
	var p: Dictionary = RaceSession.players[idx]
	var color_key: String = String(p.get("color", "yellow"))
	title_label.text = "Joueur %d" % (idx + 1)
	prompt_label.text = "Appuie sur A (ou X sur PlayStation) sur ta manette"
	color_dot.color = COLOR_RGB.get(color_key, Color.WHITE)
	progress_label.text = "%s — manette %d / %d" % [COLOR_LABELS.get(color_key, color_key), _current + 1, _pending_indices.size()]
	hint_label.text = "Tu peux annuler avec le bouton ci-dessous."

func _input(event: InputEvent) -> void:
	if not (event is InputEventJoypadButton):
		return
	var jb: InputEventJoypadButton = event as InputEventJoypadButton
	if not jb.pressed:
		return
	if jb.button_index != JOY_BUTTON_A:
		return
	if jb.device in _assigned_devices:
		hint_label.text = "Cette manette est deja attribuee a un autre joueur."
		return
	var idx: int = int(_pending_indices[_current])
	RaceSession.players[idx]["pad_device"] = jb.device
	_assigned_devices.append(jb.device)
	_current += 1
	_show_next_prompt()

func _proceed_to_race() -> void:
	get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/race.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/pre_race_menu.tscn")
