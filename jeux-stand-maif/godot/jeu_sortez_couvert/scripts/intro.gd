extends Control

const ConseillerScene = preload("res://jeu_sortez_couvert/ui/conseiller.tscn")
const DialogueBoxScene = preload("res://jeu_sortez_couvert/ui/dialogue_box.tscn")

const INTRO_LINES: Array = [
	{"text": "Bienvenue chez MAIF ! Je suis votre conseiller, ici pour vous guider.", "expression": "souriant"},
	{"text": "Au cours de 6 chapitres, vous allez vivre des situations de la vraie vie.", "expression": "normal"},
	{"text": "Chaque chapitre vous presente des risques du quotidien.", "expression": "normal"},
	{"text": "Votre mission : choisir les contrats d'assurance les plus adaptes avant que le sinistre survienne !", "expression": "souriant"},
	{"text": "Pret a devenir un expert MAIF ? Allons-y !", "expression": "fier"},
]

@onready var _conseiller_area: Control = $MarginContainer/VBoxContainer/ConseillerArea
@onready var _dialogue_area: Control = $MarginContainer/VBoxContainer/DialogueArea

var _conseiller: Node
var _dialogue_box: Node
var _line_idx: int = 0

func _ready() -> void:
	_conseiller = ConseillerScene.instantiate()
	_conseiller_area.add_child(_conseiller)

	_dialogue_box = DialogueBoxScene.instantiate()
	_dialogue_area.add_child(_dialogue_box)
	_dialogue_box.advance.connect(_on_advance)

	_show_line(0)

func _show_line(idx: int) -> void:
	if idx >= INTRO_LINES.size():
		get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/chapitre_intro.tscn")
		return
	var line: Dictionary = INTRO_LINES[idx]
	_dialogue_box.show_text(line["text"])
	_conseiller.set_expression(line["expression"])

func _on_advance() -> void:
	_line_idx += 1
	_show_line(_line_idx)
