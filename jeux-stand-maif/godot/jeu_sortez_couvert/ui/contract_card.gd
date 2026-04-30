extends PanelContainer

signal toggled(type: String)

var contract_type: String = ""
var _selected: bool = false

@onready var icon_label: Label = $MarginContainer/VBoxContainer/IconLabel
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel

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
	if _selected:
		self_modulate = Color(0.6, 1.0, 0.6, 1.0)
	else:
		self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggled.emit(contract_type)
		get_viewport().set_input_as_handled()
