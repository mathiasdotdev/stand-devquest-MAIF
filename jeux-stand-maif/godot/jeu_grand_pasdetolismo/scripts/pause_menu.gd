extends CanvasLayer

func _ready() -> void:
	$Container.visible = false
	$Container/Center/VBox/BtnReprendre.pressed.connect(_on_reprendre)
	$Container/Center/VBox/BtnRecommencer.pressed.connect(_on_recommencer)
	$Container/Center/VBox/BtnMenu.pressed.connect(_on_menu)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	var paused: bool = not get_tree().paused
	get_tree().paused = paused
	$Container.visible = paused

func _on_reprendre() -> void:
	get_tree().paused = false
	$Container.visible = false

func _on_recommencer() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
