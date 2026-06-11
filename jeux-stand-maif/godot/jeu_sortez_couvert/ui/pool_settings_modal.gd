extends CanvasLayer

# Modale F10 du main_menu :
# - règle le volume de la musique et des effets (librement modifiable)
# - affiche le nombre de chapitres tirés par partie ; sa modification est
#   protégée par un mot de passe (bouton "Modifier" → porte mot de passe).

signal closed

# Pas de volume gagné/perdu par clic : 10 %.
const VOL_STEP := 0.1

@onready var _container: Control = $Container
@onready var _center: CenterContainer = $Container/CenterContainer
@onready var _menu_panel: Control = $Container/CenterContainer/MenuPanel
@onready var _pool_size_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/PoolSizeRow/PoolSizeValue
@onready var _btn_modify: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/PoolSizeRow/BtnModify
@onready var _pool_size_spin: SpinBox = $Container/CenterContainer/MenuPanel/Margin/VBox/PoolSizeRow/PoolSizeSpin
@onready var _available_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/PoolSizeRow/AvailableLabel
@onready var _btn_close: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/CloseRow/BtnClose

@onready var _music_bar: ProgressBar = $Container/CenterContainer/MenuPanel/Margin/VBox/MusicRow/MusicBar
@onready var _music_value: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/MusicRow/MusicValue
@onready var _btn_music_minus: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/MusicRow/BtnMusicMinus
@onready var _btn_music_plus: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/MusicRow/BtnMusicPlus

@onready var _sfx_bar: ProgressBar = $Container/CenterContainer/MenuPanel/Margin/VBox/SfxRow/SfxBar
@onready var _sfx_value: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/SfxRow/SfxValue
@onready var _btn_sfx_minus: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/SfxRow/BtnSfxMinus
@onready var _btn_sfx_plus: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/SfxRow/BtnSfxPlus

var _gate: PasswordGate = null

func _ready() -> void:
	_container.visible = false
	_btn_close.pressed.connect(hide_modal)
	_pool_size_spin.value_changed.connect(_on_pool_size_changed)
	# Clampe la valeur max sur le nombre de chapitres réellement disponibles
	_pool_size_spin.max_value = float(Globals.chapitres.count())
	_btn_modify.pressed.connect(_on_modify_pressed)

	_btn_music_minus.pressed.connect(_on_music_step.bind(-VOL_STEP))
	_btn_music_plus.pressed.connect(_on_music_step.bind(VOL_STEP))
	_btn_sfx_minus.pressed.connect(_on_sfx_step.bind(-VOL_STEP))
	_btn_sfx_plus.pressed.connect(_on_sfx_step.bind(VOL_STEP))
	_setup_password_gate()

func is_open() -> bool:
	return _container.visible

func show_modal() -> void:
	# Le volume est librement modifiable ; la taille du pool est verrouillée
	# (affichage seul) jusqu'à saisie du mot de passe via "Modifier".
	_menu_panel.visible = true
	_gate.visible = false
	_set_pool_editable(false)
	_refresh()
	_container.visible = true

func hide_modal() -> void:
	_container.visible = false
	_gate.visible = false
	closed.emit()

func _refresh() -> void:
	_pool_size_spin.value = Globals.story_engine.pool_size
	_pool_size_label.text = "%d chapitres" % Globals.story_engine.pool_size
	_available_label.text = "(disponibles : %d)" % Globals.chapitres.count()
	_update_music(Music.get_volume())
	_update_sfx(Sfx.get_volume())

# ─── Pool size : verrou mot de passe ───────────────────────────────────────────

# Bascule l'affichage : verrouillé = label "X chapitres" + bouton "Modifier" ;
# déverrouillé = SpinBox éditable.
func _set_pool_editable(editable: bool) -> void:
	_pool_size_spin.visible = editable
	_pool_size_label.visible = not editable
	_btn_modify.visible = not editable

func _on_modify_pressed() -> void:
	_menu_panel.visible = false
	_gate.visible = true
	_gate.reset()

func _setup_password_gate() -> void:
	_gate = PasswordGate.new()
	_gate.visible = false
	_gate.unlocked.connect(_on_gate_unlocked)
	_gate.cancelled.connect(_on_gate_cancelled)
	_center.add_child(_gate)

func _on_gate_unlocked() -> void:
	_gate.visible = false
	_menu_panel.visible = true
	_set_pool_editable(true)

func _on_gate_cancelled() -> void:
	_gate.visible = false
	_menu_panel.visible = true

func _on_pool_size_changed(value: float) -> void:
	Globals.story_engine.set_pool_size(int(value))
	_pool_size_label.text = "%d chapitres" % Globals.story_engine.pool_size

# ─── Volume ───────────────────────────────────────────────────────────────────

func _on_music_step(delta: float) -> void:
	Music.set_volume(Music.get_volume() + delta)
	_update_music(Music.get_volume())

func _on_sfx_step(delta: float) -> void:
	Sfx.set_volume(Sfx.get_volume() + delta)
	_update_sfx(Sfx.get_volume())

func _update_music(linear: float) -> void:
	_music_bar.value = linear
	_music_value.text = "%d %%" % roundi(linear * 100.0)
	_btn_music_minus.disabled = linear <= 0.0
	_btn_music_plus.disabled = linear >= 1.0

func _update_sfx(linear: float) -> void:
	_sfx_bar.value = linear
	_sfx_value.text = "%d %%" % roundi(linear * 100.0)
	_btn_sfx_minus.disabled = linear <= 0.0
	_btn_sfx_plus.disabled = linear >= 1.0
