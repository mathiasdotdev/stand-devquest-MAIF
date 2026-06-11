extends Control

# Script de base pour toutes les scènes du mode histoire
# Gère l'affichage du menu pause et l'input global "Echap"
# Centralise aussi l'action Quit du menu pause

const MAIN_MENU_SCENE := "res://main_menu/main_menu.tscn"

var pause_menu: CanvasLayer = null

func _ready() -> void:
	if not get_node_or_null("PauseMenu"):
		var pause_menu_scene: PackedScene = preload("res://jeu_sortez_couvert/ui/pause_menu.tscn")
		pause_menu = pause_menu_scene.instantiate()
		pause_menu.name = "PauseMenu"
		add_child(pause_menu)
	else:
		pause_menu = get_node("PauseMenu")

	pause_menu.quit_requested.connect(_on_pause_quit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_menu:
			var container: Node = pause_menu.get_node_or_null("Container")
			if container and container.visible:
				Sfx.play("back")
				pause_menu.hide_pause()
			else:
				Sfx.play("click")
				pause_menu.show_pause()
			get_viewport().set_input_as_handled()

func _on_pause_quit() -> void:
	get_tree().paused = false
	# Partie quittée en cours : on efface l'identité du joueur pour ne pas
	# pré-remplir nom/email du visiteur suivant dans l'écran pseudo_input.
	Globals.story_engine.clear_player()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
