extends "res://jeu_sortez_couvert/scripts/pause_layout.gd"

# Script partagé pour les scènes story dialoguées (intro, chapitre_intro, etc.)
# Hérite de pause_layout.gd (Echap + pause menu) et ajoute le pattern :
# - instancier le conseiller dans ConseillerArea
# - instancier la dialogue_box dans DialogueArea
# - itérer sur une liste de lignes via le bouton Continuer
#
# Une scène fille extends ce script et appelle `setup_story(title, lines)` dans
# son _ready(), puis override `_on_story_complete()` pour décider de la suite.

const CONSEILLER_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/conseiller.tscn")
const DIALOGUE_BOX_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/dialogue_box.tscn")

var _conseiller: Node
var _dialogue_box: Node
var _lines: Array = []
var _line_idx: int = 0

func _ready() -> void:
	super._ready()
	var conseiller_area: Control = get_node_or_null("ConseillerArea")
	var dialogue_area: Control = get_node_or_null("DialogueArea")
	if conseiller_area:
		_conseiller = CONSEILLER_SCENE.instantiate()
		conseiller_area.add_child(_conseiller)
	if dialogue_area:
		_dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
		dialogue_area.add_child(_dialogue_box)
		_dialogue_box.advance.connect(_on_advance)

func setup_story(title: String, lines: Array) -> void:
	if _dialogue_box:
		_dialogue_box.set_title(title)
	_lines = lines
	_line_idx = 0
	_show_line(0)

func _show_line(idx: int) -> void:
	if idx >= _lines.size():
		_on_story_complete()
		return
	var line: Dictionary = _lines[idx]
	if _dialogue_box:
		_dialogue_box.show_text(String(line.get("text", "")))
	if _conseiller:
		_conseiller.set_expression(String(line.get("expression", "question")))

func _on_advance() -> void:
	_line_idx += 1
	_show_line(_line_idx)

# À override dans la scène fille : que faire après la dernière ligne ?
func _on_story_complete() -> void:
	pass
