extends PanelContainer

signal toggled(type: String)

var contract_type: String = ""
var _selected: bool = false

@onready var icon_label: Label = $MarginContainer/VBoxContainer/IconLabel
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var panel: PanelContainer = self

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

func _apply_style() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if _selected:
		style.bg_color = Color(0.27, 0.67, 1, 0.18) # Bleu clair très visible, alpha pour garder l'icône visible
		style.set_border_width_all(3)
		style.border_color = Color(0.27, 0.67, 1, 1)
	else:
		style.bg_color = Color(0.09, 0.11, 0.16, 1) # Fond sombre par défaut
		style.set_border_width_all(0)
	panel.add_theme_stylebox_override("panel", style)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggled.emit(contract_type)
		get_viewport().set_input_as_handled()
