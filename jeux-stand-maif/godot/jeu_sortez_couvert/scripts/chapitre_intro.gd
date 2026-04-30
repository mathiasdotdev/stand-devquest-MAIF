extends Control

const ConseillerScene = preload("res://jeu_sortez_couvert/ui/conseiller.tscn")
const DialogueBoxScene = preload("res://jeu_sortez_couvert/ui/dialogue_box.tscn")

@onready var _chapitre_num_label: Label = $MarginContainer/VBoxContainer/ChapitreNumLabel
@onready var _titre_label: Label = $MarginContainer/VBoxContainer/TitreLabel
@onready var _contexte_label: Label = $MarginContainer/VBoxContainer/ContexteLabel
@onready var _conseiller_area: Control = $MarginContainer/VBoxContainer/ConseillerArea
@onready var _dialogue_area: Control = $MarginContainer/VBoxContainer/DialogueArea

var _conseiller: Node
var _dialogue_box: Node
var _chapitre: Dictionary
var _line_idx: int = 0

func _ready() -> void:
	_chapitre = Chapitres.get_chapitre(StoryEngine.current_chapitre)
	_chapitre_num_label.text = "Chapitre " + str(StoryEngine.current_chapitre + 1) + " / " + str(Chapitres.count())
	_titre_label.text = _chapitre["emoji"] + "  " + _chapitre["titre"]
	_contexte_label.text = _chapitre["contexte"]

	_conseiller = ConseillerScene.instantiate()
	_conseiller_area.add_child(_conseiller)

	_dialogue_box = DialogueBoxScene.instantiate()
	_dialogue_area.add_child(_dialogue_box)
	_dialogue_box.advance.connect(_on_advance)

	_show_line(0)

func _show_line(idx: int) -> void:
	var intro_lines: Array = _chapitre["intro"]
	if idx >= intro_lines.size():
		get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/contract_selection.tscn")
		return
	var line: Dictionary = intro_lines[idx]
	_dialogue_box.show_text(line["text"])
	_conseiller.set_expression(line["expression"])

func _on_advance() -> void:
	_line_idx += 1
	_show_line(_line_idx)
