extends PanelContainer

signal advance
signal skip

const CHARS_PER_SEC := 60.0

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var text_label: RichTextLabel = $MarginContainer/VBoxContainer/TextLabel
@onready var btn_skip: Button = $MarginContainer/VBoxContainer/Footer/BtnSkip
@onready var btn_continue: Button = $MarginContainer/VBoxContainer/Footer/BtnContinue

var _complete: bool = false
var _tween: Tween = null

func _ready() -> void:
	btn_continue.pressed.connect(_on_advance_pressed)
	btn_skip.pressed.connect(_on_skip_pressed)
	_update_btn_state()

# Affiche / masque le bouton "Passer" (skip). Utilisé par les scènes avec
# plusieurs lignes d'explication (ex : chapitre_result) pour sauter directement
# à la suite. Masqué par défaut.
func set_skip_visible(v: bool) -> void:
	btn_skip.visible = v

# Définit le titre persistant en haut de la bulle (par ex. "Apprenez à vous protéger avec la MAIF").
# Vide ou absent → titre masqué.
func set_title(t: String) -> void:
	title_label.text = t
	title_label.visible = not t.strip_edges().is_empty()

func show_text(text: String) -> void:
	_complete = false
	_update_btn_state()
	text_label.text = text
	text_label.visible_ratio = 0.0

	if _tween:
		_tween.kill()
	_tween = create_tween()
	var duration := float(text.length()) / CHARS_PER_SEC
	_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	_tween.tween_callback(_on_typewriter_done)

func _on_typewriter_done() -> void:
	_complete = true
	_update_btn_state()

# Le bouton reste TOUJOURS dans le layout pour éviter le reflow.
# Quand le texte n'est pas terminé : transparent + désactivé (= invisible mais espace réservé).
func _update_btn_state() -> void:
	if _complete:
		btn_continue.disabled = false
		btn_continue.modulate = Color(1, 1, 1, 1)
	else:
		btn_continue.disabled = true
		btn_continue.modulate = Color(1, 1, 1, 0)

func _on_advance_pressed() -> void:
	advance.emit()

func _on_skip_pressed() -> void:
	skip.emit()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	# Laisse le bouton "Passer" gérer lui-même son clic (sinon ce handler
	# consommerait l'événement et le bouton ne se déclencherait jamais).
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed \
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT \
			and btn_skip.visible \
			and btn_skip.get_global_rect().has_point((event as InputEventMouseButton).position):
		return
	var pressed: bool = (
		(event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo
			and ((event as InputEventKey).keycode == KEY_SPACE or (event as InputEventKey).keycode == KEY_ENTER or (event as InputEventKey).keycode == KEY_KP_ENTER))
		or (event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT)
	)
	if not pressed:
		return
	if not _complete:
		# Skip typewriter
		if _tween:
			_tween.kill()
		text_label.visible_ratio = 1.0
		_on_typewriter_done()
	else:
		Sfx.play("selection")
		advance.emit()
	if is_inside_tree():
		get_viewport().set_input_as_handled()
