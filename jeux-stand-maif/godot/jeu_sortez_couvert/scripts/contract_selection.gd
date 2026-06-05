extends "res://jeu_sortez_couvert/scripts/pause_layout.gd"

const CONTRACT_CARD_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/contract_card.tscn")

@onready var _titre_label: Label = $MarginContainer/VBoxContainer/TitreLabel
@onready var _cards_container: HBoxContainer = $MarginContainer/VBoxContainer/CardsContainer
@onready var _hint_btn1: Button = $MarginContainer/VBoxContainer/ButtonsRow/BtnIndice1
@onready var _hint_btn2: Button = $MarginContainer/VBoxContainer/ButtonsRow/BtnIndice2
@onready var _confirm_btn: Button = $MarginContainer/VBoxContainer/ButtonsRow/BtnConfirmer
@onready var _hint_label: Label = $MarginContainer/VBoxContainer/HintLabel
@onready var _background: Sprite2D = $Background

var _cards: Array = []
var _chapitre: Dictionary

func _ready() -> void:
	super._ready() # necessaire pour le pause_layout
	StorySceneLayout.cover_viewport(_background)

	_chapitre = Globals.chapitres.get_chapitre(Globals.story_engine.current_chapitre)
	_titre_label.text = (
		_chapitre["emoji"] + "  Chapitre " + str(Globals.story_engine.current_chapitre + 1)
		+ " — " + _chapitre["titre"]
	)

	_hint_btn1.pressed.connect(_on_hint_pressed)
	_hint_btn2.pressed.connect(_on_hint_pressed)
	_confirm_btn.pressed.connect(_on_confirm)

	_hint_label.text = ""
	_build_cards()
	_update_hint_buttons()

func _build_cards() -> void:
	for contract: Dictionary in Globals.contracts.CONTRACTS:
		var card: Node = CONTRACT_CARD_SCENE.instantiate()
		_cards_container.add_child(card)
		card.setup(contract)
		card.toggled.connect(_on_card_toggled)
		_cards.append(card)

func _on_card_toggled(type: String) -> void:
	Globals.story_engine.toggle_contract(type)
	for card: Node in _cards:
		card.set_selected(Globals.story_engine.is_selected(card.contract_type))

func _on_hint_pressed() -> void:
	if Globals.story_engine.hints_used_this_chapitre >= 2:
		return
	Globals.story_engine.use_hint()
	_hint_label.text = Globals.story_engine.get_hint_text()
	_update_hint_buttons()

func _update_hint_buttons() -> void:
	_hint_btn1.disabled = Globals.story_engine.hints_used_this_chapitre >= 1
	_hint_btn2.disabled = Globals.story_engine.hints_used_this_chapitre >= 2

func _on_confirm() -> void:
	Globals.story_engine.resolve_current_chapitre()
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/chapitre_result.tscn")
