extends PanelContainer

signal advance

const CHARS_PER_SEC := 35.0

@onready var text_label: RichTextLabel = $MarginContainer/VBoxContainer/TextLabel
@onready var continue_label: Label = $MarginContainer/VBoxContainer/ContinueLabel

var _complete: bool = false
var _tween: Tween = null
var _blink_tween: Tween = null

func show_text(text: String) -> void:
	_complete = false
	continue_label.visible = false
	text_label.text = text
	text_label.visible_ratio = 0.0

	if _tween:
		_tween.kill()
	_tween = create_tween()
	var duration := float(text.length()) / CHARS_PER_SEC
	_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	_tween.tween_callback(_on_typewriter_done)

func _on_typewriter_done() -> void:
	_complete = true
	continue_label.visible = true
	if _blink_tween:
		_blink_tween.kill()
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(continue_label, "modulate:a", 0.0, 0.4)
	_blink_tween.tween_property(continue_label, "modulate:a", 1.0, 0.4)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var pressed: bool = (
		(event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo
			and ((event as InputEventKey).keycode == KEY_SPACE or (event as InputEventKey).keycode == KEY_ENTER or (event as InputEventKey).keycode == KEY_KP_ENTER))
		or (event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT)
	)
	if not pressed:
		return
	if not _complete:
		# Skip typewriter
		if _tween:
			_tween.kill()
		text_label.visible_ratio = 1.0
		_on_typewriter_done()
	else:
		if _blink_tween:
			_blink_tween.kill()
		continue_label.visible = false
		advance.emit()
	if is_inside_tree():
		get_viewport().set_input_as_handled()
