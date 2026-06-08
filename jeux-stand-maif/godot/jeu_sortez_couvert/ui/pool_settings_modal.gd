extends CanvasLayer

# Modale F10 du main_menu : règle le nombre de chapitres tirés par partie.
# La valeur est persistée via story_engine (user://pool_size.cfg).

signal closed

@onready var _container: Control = $Container
@onready var _pool_size_spin: SpinBox = $Container/CenterContainer/MenuPanel/Margin/VBox/PoolSizeRow/PoolSizeSpin
@onready var _available_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/PoolSizeRow/AvailableLabel
@onready var _btn_close: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/CloseRow/BtnClose

func _ready() -> void:
	_container.visible = false
	_btn_close.pressed.connect(hide_modal)
	_pool_size_spin.value_changed.connect(_on_pool_size_changed)
	# Clampe la valeur max sur le nombre de chapitres réellement disponibles
	_pool_size_spin.max_value = float(Globals.chapitres.count())

func is_open() -> bool:
	return _container.visible

func show_modal() -> void:
	_refresh()
	_container.visible = true

func hide_modal() -> void:
	_container.visible = false
	closed.emit()

func _refresh() -> void:
	_pool_size_spin.value = Globals.story_engine.pool_size
	_available_label.text = "(disponibles : %d)" % Globals.chapitres.count()

func _on_pool_size_changed(value: float) -> void:
	Globals.story_engine.set_pool_size(int(value))
