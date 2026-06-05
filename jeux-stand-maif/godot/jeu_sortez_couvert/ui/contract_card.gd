extends PanelContainer

signal toggled(type: String)

const BUTTON_TEX: Texture2D = preload("res://jeu_sortez_couvert/ui/theme/button_border.png")

const COLOR_NORMAL := Color(0.18, 0.24, 0.35, 1)
const COLOR_HOVER := Color(0.92, 0.74, 0.32, 1)
const COLOR_SELECTED := Color(0.92, 0.74, 0.32, 1)

var contract_type: String = ""
var _selected: bool = false
var _hovered: bool = false

@onready var icon_label: Label = $MarginContainer/VBoxContainer/IconLabel
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(contract: Dictionary) -> void:
	contract_type = contract["type"]
	icon_label.text = contract["icon"]
	name_label.text = contract["label"]
	_apply_style()

func set_selected(selected: bool) -> void:
	_selected = selected
	_apply_style()

func is_card_selected() -> bool:
	return _selected

func _on_mouse_entered() -> void:
	_hovered = true
	_apply_style()

func _on_mouse_exited() -> void:
	_hovered = false
	_apply_style()

func _apply_style() -> void:
	var style := StyleBoxTexture.new()
	style.texture = BUTTON_TEX
	style.texture_margin_left = 16
	style.texture_margin_top = 16
	style.texture_margin_right = 16
	style.texture_margin_bottom = 16
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	# Hover = même rendu que selected (le clic confirme l'état déjà visualisé)
	var highlight: bool = _selected or _hovered
	style.modulate_color = COLOR_SELECTED if highlight else COLOR_NORMAL
	add_theme_stylebox_override("panel", style)
	var text_color: Color = Color(0.08, 0.06, 0.02, 1) if highlight else Color(0.95, 0.95, 0.97, 1)
	icon_label.add_theme_color_override("font_color", text_color)
	name_label.add_theme_color_override("font_color", text_color)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Sfx.play("click")
		toggled.emit(contract_type)
		get_viewport().set_input_as_handled()
