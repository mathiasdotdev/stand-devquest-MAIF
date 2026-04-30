extends Control

const ContractCardScene = preload("res://jeu_sortez_couvert/ui/contract_card.tscn")

@onready var _titre_label: Label = $MarginContainer/VBoxContainer/TitreLabel
@onready var _cards_container: HBoxContainer = $MarginContainer/VBoxContainer/CardsContainer
@onready var _hint_btn1: Button = $MarginContainer/VBoxContainer/ButtonsRow/BtnIndice1
@onready var _hint_btn2: Button = $MarginContainer/VBoxContainer/ButtonsRow/BtnIndice2
@onready var _confirm_btn: Button = $MarginContainer/VBoxContainer/ButtonsRow/BtnConfirmer
@onready var _hint_label: Label = $MarginContainer/VBoxContainer/HintLabel

var _cards: Array = []
var _chapitre: Dictionary

func _ready() -> void:
	_chapitre = Chapitres.get_chapitre(StoryEngine.current_chapitre)
	_titre_label.text = (
		_chapitre["emoji"] + "  Chapitre " + str(StoryEngine.current_chapitre + 1)
		+ " — " + _chapitre["titre"]
	)

	_hint_btn1.pressed.connect(_on_hint_pressed)
	_hint_btn2.pressed.connect(_on_hint_pressed)
	_confirm_btn.pressed.connect(_on_confirm)

	_hint_label.text = ""
	_build_cards()
	_update_hint_buttons()

func _build_cards() -> void:
	for contract: Dictionary in Contracts.CONTRACTS:
		var card: Node = ContractCardScene.instantiate()
		_cards_container.add_child(card)
		card.setup(contract)
		card.toggled.connect(_on_card_toggled)
		_cards.append(card)

func _on_card_toggled(type: String) -> void:
	StoryEngine.toggle_contract(type)
	for card: Node in _cards:
		card.set_selected(StoryEngine.is_selected(card.contract_type))

func _on_hint_pressed() -> void:
	if StoryEngine.hints_used_this_chapitre >= 2:
		return
	StoryEngine.use_hint()
	_hint_label.text = StoryEngine.get_hint_text()
	_update_hint_buttons()

func _update_hint_buttons() -> void:
	_hint_btn1.disabled = StoryEngine.hints_used_this_chapitre >= 1
	_hint_btn2.disabled = StoryEngine.hints_used_this_chapitre >= 2

func _on_confirm() -> void:
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/disaster_reveal.tscn")
