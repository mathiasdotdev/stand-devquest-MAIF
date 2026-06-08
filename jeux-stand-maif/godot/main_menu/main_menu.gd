extends Control

# Feature flipping pour le bouton Pasdetolismo
const PASDETOLISMO_ENABLED := false
const POOL_SETTINGS_MODAL_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/pool_settings_modal.tscn")

@onready var btn_sortez_couvert: Button = $CenterContainer/MenuPanel/Margin/VBoxContainer/BtnSortezCouvert
@onready var btn_pasdetolismo: Button = $CenterContainer/MenuPanel/Margin/VBoxContainer/BtnPasdetolismo
@onready var btn_classement: Button = $CenterContainer/MenuPanel/Margin/VBoxContainer/BtnClassement
@onready var btn_quitter: Button = $CenterContainer/MenuPanel/Margin/VBoxContainer/BtnQuitter

var _pool_modal: CanvasLayer = null

func _ready() -> void:
	btn_sortez_couvert.pressed.connect(_on_sortez_couvert)
	btn_pasdetolismo.visible = PASDETOLISMO_ENABLED
	if PASDETOLISMO_ENABLED:
		btn_pasdetolismo.pressed.connect(_on_pasdetolismo)
	btn_classement.pressed.connect(_on_classement)
	btn_quitter.pressed.connect(_on_quitter)
	_pool_modal = POOL_SETTINGS_MODAL_SCENE.instantiate()
	add_child(_pool_modal)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F10:
			Sfx.play("switch")
			_toggle_pool_modal()
			get_viewport().set_input_as_handled()

func _toggle_pool_modal() -> void:
	if _pool_modal.is_open():
		_pool_modal.hide_modal()
	else:
		_pool_modal.show_modal()

func _on_sortez_couvert() -> void:
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/pseudo_input.tscn")

func _on_pasdetolismo() -> void:
	get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/pre_race_menu.tscn")

func _on_classement() -> void:
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/leaderboard.tscn")

func _on_quitter() -> void:
	get_tree().quit()
