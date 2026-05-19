extends Control

# Script de base pour toutes les scènes du mode histoire
# Gère l'affichage du menu pause et l'input global "Echap"

var pause_menu: CanvasLayer = null

func _ready() -> void:
	if not get_node_or_null("PauseMenu"):
		var pause_menu_scene: PackedScene = preload("res://jeu_sortez_couvert/ui/pause_menu.tscn")
		pause_menu = pause_menu_scene.instantiate()
		pause_menu.name = "PauseMenu"
		add_child(pause_menu)
	else:
		pause_menu = get_node("PauseMenu")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_menu:
			var container: Node = pause_menu.get_node_or_null("Container")
			if container and container.visible:
				pause_menu.hide_pause()
			else:
				pause_menu.show_pause()
			get_viewport().set_input_as_handled()
