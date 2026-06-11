extends CanvasLayer

# Modale admin du classement (F10).
# - Voir / changer le chemin de sauvegarde du JSON via file picker natif
# - Filtres d'affichage : "avec email uniquement" + score effectif minimum
# Style fantasy, cohérent avec pause_menu / info_modal.

signal closed
signal path_changed
signal filter_changed

@onready var _container: Control = $Container
@onready var _center: CenterContainer = $Container/CenterContainer
@onready var _menu_panel: Control = $Container/CenterContainer/MenuPanel
@onready var _current_path_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/CurrentPathLabel
@onready var _default_path_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/DefaultPathLabel
@onready var _btn_choose: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/PathBtnRow/BtnChoose
@onready var _btn_reset: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/PathBtnRow/BtnReset
@onready var _email_only_check: CheckBox = $Container/CenterContainer/MenuPanel/Margin/VBox/EmailOnlyCheck
@onready var _min_score_spin: SpinBox = $Container/CenterContainer/MenuPanel/Margin/VBox/ScoreFilterRow/MinScoreSpin
@onready var _display_limit_spin: SpinBox = $Container/CenterContainer/MenuPanel/Margin/VBox/DisplayLimitRow/DisplayLimitSpin
@onready var _btn_close: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/CloseRow/BtnClose

var _file_dialog: FileDialog = null
var _gate: PasswordGate = null

func _ready() -> void:
	_container.visible = false
	_btn_close.pressed.connect(hide_modal)
	_btn_choose.pressed.connect(_on_choose_path)
	_btn_reset.pressed.connect(_on_reset)
	_email_only_check.toggled.connect(_on_filter_changed)
	_min_score_spin.value_changed.connect(_on_score_filter_changed)
	_display_limit_spin.value_changed.connect(_on_score_filter_changed)
	_create_file_dialog()
	_setup_password_gate()

func is_open() -> bool:
	return _container.visible

# Affiche d'abord la porte mot de passe ; les paramètres ne sont révélés
# qu'après saisie correcte (cf. _on_gate_unlocked).
func show_modal() -> void:
	_menu_panel.visible = false
	_gate.visible = true
	_gate.reset()
	_container.visible = true

func hide_modal() -> void:
	_container.visible = false
	_gate.visible = false
	_menu_panel.visible = false
	closed.emit()

# ---- Porte mot de passe -----------------------------------------------------

func _setup_password_gate() -> void:
	_gate = PasswordGate.new()
	_gate.visible = false
	_gate.unlocked.connect(_on_gate_unlocked)
	_gate.cancelled.connect(hide_modal)
	_center.add_child(_gate)

func _on_gate_unlocked() -> void:
	_gate.visible = false
	_refresh_path_display()
	_menu_panel.visible = true

# ---- Filtres ----------------------------------------------------------------

func get_email_only_filter() -> bool:
	return _email_only_check.button_pressed

func get_min_score_filter() -> float:
	return _min_score_spin.value

func get_display_limit() -> int:
	return int(_display_limit_spin.value)

func _on_filter_changed(_toggled: bool) -> void:
	filter_changed.emit()

func _on_score_filter_changed(_value: float) -> void:
	filter_changed.emit()

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
