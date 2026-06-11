extends Control

@onready var name_input: LineEdit = $CenterContainer/MenuPanel/Margin/VBox/NameInput
@onready var name_error: Label = $CenterContainer/MenuPanel/Margin/VBox/NameError
@onready var email_input: LineEdit = $CenterContainer/MenuPanel/Margin/VBox/EmailInput
@onready var email_error: Label = $CenterContainer/MenuPanel/Margin/VBox/EmailError
@onready var btn_start: Button = $CenterContainer/MenuPanel/Margin/VBox/Footer/BtnStart
@onready var btn_back: Button = $CenterContainer/MenuPanel/Margin/VBox/Footer/BtnBack

var _email_regex: RegEx = RegEx.new()
# Message d'erreur email d'origine (format invalide), pour le restaurer après
# avoir affiché le message "déjà participé".
var _default_email_error: String = ""

func _ready() -> void:
	_email_regex.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
	_default_email_error = email_error.text

	var story_engine: Node = get_node("/root/StoryEngine")
	if story_engine.player_name != "":
		name_input.text = story_engine.player_name
	if story_engine.player_email != "":
		email_input.text = story_engine.player_email

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
		name_error.show()
		name_input.grab_focus()
		return
	if not _is_email_valid(player_email):
		email_error.text = _default_email_error
		email_error.show()
		email_input.grab_focus()
		return
	# Unicité de l'email : une seule tentative par email (le surnom, lui, peut
	# se répéter). Email vide = pas de contrôle possible (joueur anonyme).
	if not player_email.is_empty() and Globals.leaderboard.has_email("story", player_email):
		email_error.text = "Cet email a déjà participé — une seule tentative par email"
		email_error.show()
		email_input.grab_focus()
		return
	Globals.story_engine.reset()
	Globals.story_engine.player_name = player_name
	Globals.story_engine.player_email = player_email
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/intro.tscn")

func _on_text_changed(new_text: String) -> void:
	# Auto-capitalisation de la première lettre du pseudo
	if not new_text.is_empty():
		var first: String = new_text.left(1)
		if first != first.to_upper():
			var caret: int = name_input.caret_column
			name_input.text = first.to_upper() + new_text.substr(1)
			name_input.caret_column = caret
			new_text = name_input.text
	var is_valid: bool = not new_text.strip_edges().is_empty()
	btn_start.disabled = not is_valid
	if is_valid:
		name_error.hide()

func _on_email_changed(new_text: String) -> void:
	var lowered: String = new_text.to_lower()
	if lowered != new_text:
		var caret: int = email_input.caret_column
		email_input.text = lowered
		email_input.caret_column = caret
		new_text = lowered
	if _is_email_valid(new_text.strip_edges()):
		email_error.text = _default_email_error
		email_error.hide()

func _is_email_valid(email: String) -> bool:
	if email.is_empty():
		return true
	return _email_regex.search(email) != null

func _on_back() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
