extends CanvasLayer

# Modale admin du classement (F10).
# - Voir / changer le chemin de sauvegarde du JSON via file picker natif
# Style fantasy, cohérent avec pause_menu / info_modal.

signal closed
signal path_changed

@onready var _container: Control = $Container
@onready var _current_path_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/CurrentPathLabel
@onready var _default_path_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/DefaultPathLabel
@onready var _btn_choose: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/PathBtnRow/BtnChoose
@onready var _btn_reset: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/PathBtnRow/BtnReset
@onready var _btn_close: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/CloseRow/BtnClose

var _file_dialog: FileDialog = null

func _ready() -> void:
	_container.visible = false
	_btn_close.pressed.connect(hide_modal)
	_btn_choose.pressed.connect(_on_choose_path)
	_btn_reset.pressed.connect(_on_reset)
	_create_file_dialog()

func is_open() -> bool:
	return _container.visible

func show_modal() -> void:
	_refresh_path_display()
	_container.visible = true

func hide_modal() -> void:
	_container.visible = false
	closed.emit()

# ---- File dialog ------------------------------------------------------------

func _create_file_dialog() -> void:
	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.filters = PackedStringArray(["*.json ; Fichier JSON"])
	_file_dialog.title = "Emplacement du classement"
	_file_dialog.ok_button_text = "Enregistrer ici"
	_file_dialog.cancel_button_text = "Annuler"
	_file_dialog.use_native_dialog = true
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)

func _on_choose_path() -> void:
	var current: String = Globals.leaderboard.get_current_save_path()
	if not current.is_empty():
		_file_dialog.current_path = ProjectSettings.globalize_path(current)
	_file_dialog.popup_centered_ratio(0.7)

func _on_file_selected(path: String) -> void:
	Globals.leaderboard.set_custom_save_path(path)
	_refresh_path_display()
	path_changed.emit()

func _on_reset() -> void:
	Globals.leaderboard.set_custom_save_path("")
	_refresh_path_display()
	path_changed.emit()

func _refresh_path_display() -> void:
	var current: String = Globals.leaderboard.get_current_save_path()
	var default_path: String = Globals.leaderboard.get_default_save_path()
	_current_path_label.text = "Actuellement : " + current
	_default_path_label.text = "Défaut : " + default_path
