extends Control

# Script de base pour toutes les scènes du mode histoire
# Gère l'affichage du menu pause et l'input global "Echap"

var pause_menu: CanvasLayer = null

func _ready():
	print("[pause_layout] _ready called in ", self.name)
	if not get_node_or_null("PauseMenu"):
		var pause_menu_scene = preload("res://jeu_sortez_couvert/ui/pause_menu.tscn")
		pause_menu = pause_menu_scene.instantiate()
		pause_menu.name = "PauseMenu"
		add_child(pause_menu)
		print("[pause_layout] PauseMenu instancié et ajouté")
	else:
		pause_menu = get_node("PauseMenu")
		print("[pause_layout] PauseMenu déjà présent")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		print("[pause_layout] Echap détecté dans _unhandled_input, pause_menu:", pause_menu)
		if pause_menu:
			var container: Node = pause_menu.get_node_or_null("Container")
			print("[pause_layout] container:", container, " visible:", container and container.visible)
			if container and container.visible:
				pause_menu.hide_pause()
				print("[pause_layout] Masquage du menu pause")
			else:
				pause_menu.show_pause()
				print("[pause_layout] Affichage du menu pause")
			get_viewport().set_input_as_handled()
