extends CanvasLayer

signal resume_requested
signal quit_requested

const BTN_PATH := "Container/CenterContainer/MenuPanel/Margin/VBox"

func _ready() -> void:
	$Container.visible = false
	get_node(BTN_PATH + "/BtnResume").pressed.connect(_on_resume)
	get_node(BTN_PATH + "/BtnQuit").pressed.connect(_on_quit)

func show_pause() -> void:
	get_tree().paused = true
	$Container.visible = true

func hide_pause() -> void:
	get_tree().paused = false
	$Container.visible = false

func _on_resume() -> void:
	hide_pause()
	resume_requested.emit()

func _on_quit() -> void:
	hide_pause()
	quit_requested.emit()
