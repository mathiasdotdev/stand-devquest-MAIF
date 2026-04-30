extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnSortezCouvert.pressed.connect(_on_sortez_couvert)
	$CenterContainer/VBoxContainer/BtnPasdetolismo.pressed.connect(_on_pasdetolismo)
	$CenterContainer/VBoxContainer/BtnClassement.pressed.connect(_on_classement)
	$CenterContainer/VBoxContainer/BtnQuitter.pressed.connect(_on_quitter)

func _on_sortez_couvert() -> void:
	StoryEngine.reset()
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/intro.tscn")

func _on_pasdetolismo() -> void:
	get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/main.tscn")

func _on_classement() -> void:
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/leaderboard.tscn")

func _on_quitter() -> void:
	get_tree().quit()
