extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnSortezCouvert.pressed.connect(_on_sortez_couvert)
	$CenterContainer/VBoxContainer/BtnPasdetolismo.pressed.connect(_on_pasdetolismo)
	$CenterContainer/VBoxContainer/BtnClassement.pressed.connect(_on_classement)
	$CenterContainer/VBoxContainer/BtnQuitter.pressed.connect(_on_quitter)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F10:
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/admin_panel.tscn")

func _on_sortez_couvert() -> void:
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/pseudo_input.tscn")

func _on_pasdetolismo() -> void:
	get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/pre_race_menu.tscn")

func _on_classement() -> void:
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/leaderboard.tscn")

func _on_quitter() -> void:
	get_tree().quit()
