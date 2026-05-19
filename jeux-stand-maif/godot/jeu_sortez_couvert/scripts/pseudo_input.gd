extends Control

@onready var name_input: LineEdit = $Center/Panel/Margin/VBox/NameInput
@onready var email_input: LineEdit = $Center/Panel/Margin/VBox/EmailInput
@onready var btn_start: Button = $Center/Panel/Margin/VBox/Footer/BtnStart
@onready var btn_back: Button = $Center/Panel/Margin/VBox/Footer/BtnBack
@onready var _background: Sprite2D = $Background

func _ready() -> void:
	StorySceneLayout.cover_viewport(_background)

	if Globals.story_engine.player_name != "":
		name_input.text = Globals.story_engine.player_name
	if Globals.story_engine.player_email != "":
		email_input.text = Globals.story_engine.player_email

	name_input.text_submitted.connect(func(_t): _on_start())
	name_input.text_changed.connect(_on_text_changed)
	email_input.text_submitted.connect(func(_t): _on_start())
	email_input.text_changed.connect(_on_email_changed)
	btn_start.pressed.connect(_on_start)
	btn_back.pressed.connect(_on_back)
	name_input.grab_focus()
	name_input.caret_column = name_input.text.length()
	_on_text_changed(name_input.text)
	_on_email_changed(email_input.text)

func _on_start() -> void:
	var player_name: String = name_input.text.strip_edges()
	var player_email: String = email_input.text.strip_edges()
	if player_name.is_empty():
		# Donne un feedback rapide si le pseudo est vide.
		name_input.add_theme_color_override("border_color", Color(1,0.3,0.3))
		name_input.add_theme_constant_override("border_width", 2)
		return
	if not _is_email_valid(player_email):
		email_input.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		email_input.grab_focus()
		return
	Globals.story_engine.reset()
	Globals.story_engine.player_name = player_name
	Globals.story_engine.player_email = player_email
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/intro.tscn")

func _on_text_changed(new_text: String) -> void:
	var is_valid: bool = not new_text.strip_edges().is_empty()
	btn_start.disabled = not is_valid
	if is_valid:
		name_input.remove_theme_color_override("border_color")
		name_input.remove_theme_constant_override("border_width")

func _on_email_changed(new_text: String) -> void:
	if _is_email_valid(new_text.strip_edges()):
		email_input.remove_theme_color_override("font_color")

func _is_email_valid(email: String) -> bool:
	if email.is_empty():
		return true
	return email.contains("@") and email.contains(".")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
