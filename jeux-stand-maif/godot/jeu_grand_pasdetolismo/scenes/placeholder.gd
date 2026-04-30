extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnRetour.pressed.connect(func(): get_tree().change_scene_to_file("res://main_menu/main_menu.tscn"))
