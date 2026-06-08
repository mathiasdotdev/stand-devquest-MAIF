extends "res://jeu_sortez_couvert/scripts/pause_layout.gd"

const CONTRACT_CARD_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/contract_card.tscn")
const INFO_MODAL_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/info_modal.tscn")

@onready var _titre_label: Label = $MarginContainer/VBoxContainer/TitreLabel
@onready var _context_label: Label = $MarginContainer/VBoxContainer/ContextBubble/Margin/VBox/ContextLabel
@onready var _cards_container: HBoxContainer = $MarginContainer/VBoxContainer/CardsContainer
@onready var _hint_btn: Button = $MarginContainer/VBoxContainer/ButtonsRow/BtnIndice
@onready var _confirm_btn: Button = $MarginContainer/VBoxContainer/ButtonsRow/BtnConfirmer
@onready var _hint_label: Label = $MarginContainer/VBoxContainer/ContextBubble/Margin/VBox/HintLabel

var _cards: Array = []
var _chapitre: Dictionary
var _empty_modal: CanvasLayer = null

func _ready() -> void:
	super._ready() # necessaire pour le pause_layout

	_empty_modal = INFO_MODAL_SCENE.instantiate()
	add_child(_empty_modal)

	_chapitre = Globals.chapitres.get_chapitre(Globals.story_engine.current_chapitre)
	_titre_label.text = (
		_chapitre["emoji"] + "  Chapitre " + str(Globals.story_engine.pool_index + 1)
		+ " — " + _chapitre["titre"]
	)
	_context_label.text = String(_chapitre.get("resume", _chapitre.get("contexte", "")))

	_hint_btn.pressed.connect(_on_hint_pressed)
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
	var remaining: int = 2 - Globals.story_engine.hints_used_this_chapitre
	_hint_btn.text = "Indices (%d/2) — −0.5 pt" % remaining
	_hint_btn.disabled = remaining <= 0

func _on_confirm() -> void:
	if Globals.story_engine.selected_contracts.is_empty():
		Sfx.play("back")
		_empty_modal.show_modal("Aucun contrat", "Sélectionnez au moins un contrat avant de confirmer.")
		return
	Globals.story_engine.resolve_current_chapitre()
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/chapitre_result.tscn")
