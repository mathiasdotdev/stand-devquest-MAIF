extends Control

@onready var name_input: LineEdit = $Center/Panel/Margin/VBox/NameInput
@onready var btn_start: Button = $Center/Panel/Margin/VBox/Footer/BtnStart
@onready var btn_back: Button = $Center/Panel/Margin/VBox/Footer/BtnBack

func _ready() -> void:
	if StoryEngine.player_name != "":
		name_input.text = StoryEngine.player_name
	name_input.text_submitted.connect(func(_t): _on_start())
	btn_start.pressed.connect(_on_start)
	btn_back.pressed.connect(_on_back)
	name_input.grab_focus()
	name_input.caret_column = name_input.text.length()

func _on_start() -> void:
	var n: String = name_input.text.strip_edges()
	if n.is_empty():
		n = "Joueur"
	StoryEngine.player_name = n
	StoryEngine.reset()
	StoryEngine.player_name = n
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/intro.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
