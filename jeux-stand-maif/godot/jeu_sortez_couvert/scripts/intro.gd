extends "res://jeu_sortez_couvert/scripts/pause_layout.gd"

const ConseillerScene: PackedScene = preload("res://jeu_sortez_couvert/ui/conseiller.tscn")
const DialogueBoxScene: PackedScene = preload("res://jeu_sortez_couvert/ui/dialogue_box.tscn")

const INTRO_LINES: Array = [
	{"text": "Bienvenue chez MAIF ! Je suis Assurix le Barbu, votre conseiller, ici pour vous guider.", "expression": "souriant"},
	{"text": "Au cours de 6 chapitres, vous allez vivre des situations de la vraie vie.", "expression": "normal"},
	{"text": "Chaque chapitre vous présente des risques du quotidien.", "expression": "normal"},
	{"text": "Votre mission : choisir les contrats d'assurance les plus adaptés avant que le sinistre survienne !", "expression": "souriant"},
	{"text": "Prêt à devenir un expert MAIF ? Allons-y !", "expression": "fier"},
]

@onready var _conseiller_area: Control = $MarginContainer/VBoxContainer/ConseillerArea
@onready var _dialogue_area: Control = $MarginContainer/VBoxContainer/DialogueArea
@onready var _background: Sprite2D = $Background

var _conseiller: Node
var _dialogue_box: Node
var _line_idx: int = 0
var _intro_lines: Array = []

func _ready() -> void:
	super._ready() # necessaire pour le pause_layout
	if _background.texture:
		var screen_size: Vector2 = get_viewport_rect().size
		var tex_size: Vector2 = Vector2(_background.texture.get_width(), _background.texture.get_height())
		var scale_factor: float = max(screen_size.x / tex_size.x, screen_size.y / tex_size.y)
		_background.scale = Vector2(scale_factor, scale_factor)
		_background.position = get_viewport_rect().size / 2
		_background.centered = true

	StorySceneLayout.apply(self)

	var story_engine: Node = get_node("/root/StoryEngine")

	_intro_lines = INTRO_LINES.duplicate(true)
	_conseiller = ConseillerScene.instantiate()
	_conseiller_area.add_child(_conseiller)

	_dialogue_box = DialogueBoxScene.instantiate()
	_dialogue_area.add_child(_dialogue_box)
	_dialogue_box.advance.connect(_on_advance)

	if story_engine.player_name.strip_edges() != "":
		_intro_lines[0]["text"] = "Bienvenue chez MAIF, " + story_engine.player_name + " ! Je suis Assurix le Barbu, votre conseiller, ici pour vous guider."

	_show_line(0)

func _show_line(idx: int) -> void:
	if idx >= _intro_lines.size():
		get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/chapitre_intro.tscn")
		return
	var line: Dictionary = _intro_lines[idx]
	_dialogue_box.show_text(line["text"])
	_conseiller.set_expression(line["expression"])

func _on_advance() -> void:
	_line_idx += 1
	_show_line(_line_idx)
