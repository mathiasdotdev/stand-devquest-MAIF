extends Control

const MODE_IDS := ["story", "racing"]
const MODE_LABELS := ["Histoire", "Pasdetolismo"]
const ADMIN_MODAL_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/admin_modal.tscn")

# Nombre d'entrées affichées dans l'UI (le data store en garde l'historique complet en JSON)
const DISPLAY_LIMIT := 10

# Feature flipping pour masquer l'onglet Pasdetolismo
const PASDETOLISMO_ENABLED := false

# Police plus lisible pour les data (noms de joueurs, dates, scores numériques)
# où la police décorative du thème devient illisible.
var _data_font: SystemFont

@onready var tabs: TabContainer = $MenuPanel/Margin/VBox/Tabs
@onready var history_list: VBoxContainer = $MenuPanel/Margin/VBox/Tabs/Histoire/ScrollContainer/EntryList
@onready var racing_list: VBoxContainer = $MenuPanel/Margin/VBox/Tabs/Pasdetolismo/ScrollContainer/EntryList
@onready var btn_retour: Button = $MenuPanel/Margin/VBox/BtnRetour

var _admin_modal: CanvasLayer
var _admin_inline_delete: bool = false

func _ready() -> void:
	_data_font = SystemFont.new()
	_data_font.font_names = PackedStringArray(["Segoe UI", "Arial", "Helvetica", "sans-serif"])
	_refresh_tabs()
	btn_retour.pressed.connect(_on_retour)
	_setup_admin_modal()
	if not PASDETOLISMO_ENABLED:
		tabs.get_tab_bar().set_tab_hidden(1, true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		Sfx.play("switch")
		_toggle_admin_dialog()
		get_viewport().set_input_as_handled()

func _refresh_tabs() -> void:
	_populate_tab("story", history_list)
	_populate_tab("racing", racing_list)

func _populate_tab(mode: String, container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

	var leaderboard: Node = get_node("/root/Leaderboard")
	# On limite à top N pour l'affichage — l'historique complet reste dans le JSON
	var entries: Array = leaderboard.get_entries(mode, DISPLAY_LIMIT)
	if entries.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucun score enregistré"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_override("font", _data_font)
		lbl.add_theme_font_size_override("font_size", 20)
		lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8, 1))
		container.add_child(lbl)
		return
	for i in entries.size():
		container.add_child(_build_entry_row(mode, i, entries[i]))

func _build_entry_row(mode: String, idx: int, entry: Dictionary) -> Control:
	# Outer container : panel (gauche, expand_fill) + bouton Suppr (droite, hors panel)
	# Le bouton Suppr est toujours dans la structure mais visible = _admin_inline_delete
	# → la ligne se réduit légèrement quand admin_inline_delete est on,
	#   mais le panneau garde une structure stable.
	var outer := HBoxContainer.new()
	outer.add_theme_constant_override("separation", 8)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = _row_bg_color(idx)
	sb.border_color = _row_border_color(idx)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", sb)
	outer.add_child(panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	panel.add_child(row)

	var rank := Label.new()
	rank.text = "#" + str(idx + 1)
	rank.custom_minimum_size = Vector2(70, 0)
	rank.add_theme_font_override("font", _data_font)
	rank.add_theme_font_size_override("font_size", 24)
	rank.add_theme_color_override("font_color", _rank_color(idx))
	row.add_child(rank)

	var name_lbl := Label.new()
	name_lbl.text = String(entry.get("name", "???"))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_override("font", _data_font)
	name_lbl.add_theme_font_size_override("font_size", 22)
	name_lbl.add_theme_color_override("font_color", Color(0.96, 0.96, 0.98, 1))
	row.add_child(name_lbl)

	var ts: int = int(entry.get("timestamp", 0))
	if ts > 0:
		var dt: Dictionary = Time.get_datetime_dict_from_unix_time(ts)
		var date_lbl := Label.new()
		date_lbl.text = "%02d/%02d/%d" % [int(dt.day), int(dt.month), int(dt.year)]
		date_lbl.add_theme_font_override("font", _data_font)
		date_lbl.add_theme_font_size_override("font_size", 14)
		date_lbl.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92, 1))
		row.add_child(date_lbl)

	var score_lbl := Label.new()
	if mode == "story":
		var raw_score: int = int(entry.get("score", 0))
		var hints: int = int(entry.get("hints_used", 0))
		var effective: float = float(entry.get("effective_score", raw_score))
		score_lbl.text = "%d / 18 (%0.1f)" % [raw_score, effective]
		score_lbl.tooltip_text = "Indices: %d | Pénalité: -%0.1f" % [hints, float(hints) * 0.5]
	else:
		score_lbl.text = "%d pts" % int(entry.get("score", 0))
	score_lbl.custom_minimum_size = Vector2(160, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_override("font", _data_font)
	score_lbl.add_theme_font_size_override("font_size", 24)
	score_lbl.add_theme_color_override("font_color", Color(1, 0.92, 0.55, 1))
	row.add_child(score_lbl)

	# Bouton Suppr hors panneau, à droite (visible uniquement si admin_inline_delete)
	# Styles compactés pour matcher la hauteur du panneau de ligne
	if _admin_inline_delete:
		var delete_btn := Button.new()
		delete_btn.text = "✕"
		delete_btn.tooltip_text = "Supprimer l'entrée #%d" % (idx + 1)
		delete_btn.custom_minimum_size = Vector2(56, 0)
		delete_btn.add_theme_font_override("font", _data_font)
		delete_btn.add_theme_font_size_override("font_size", 22)
		# Override des styleboxes pour réduire le padding à celui du panneau de ligne
		# (le thème par défaut a content_margin 14 → fait dépasser le bouton)
		delete_btn.add_theme_stylebox_override("normal", _delete_btn_stylebox(false, false))
		delete_btn.add_theme_stylebox_override("hover", _delete_btn_stylebox(true, false))
		delete_btn.add_theme_stylebox_override("pressed", _delete_btn_stylebox(false, true))
		delete_btn.add_theme_stylebox_override("focus", _delete_btn_stylebox(true, false))
		delete_btn.add_theme_color_override("font_color", Color(0.96, 0.96, 0.98, 1))
		delete_btn.add_theme_color_override("font_hover_color", Color(1, 0.5, 0.5, 1))
		delete_btn.pressed.connect(func() -> void:
			Globals.leaderboard.remove_entry(mode, idx)
			_refresh_tabs()
			_update_admin_controls()
		)
		outer.add_child(delete_btn)

	return outer

func _delete_btn_stylebox(hover: bool, pressed: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	if hover:
		sb.bg_color = Color(0.55, 0.18, 0.18, 0.85)
		sb.border_color = Color(1.0, 0.55, 0.55, 0.85)
	elif pressed:
		sb.bg_color = Color(0.30, 0.10, 0.10, 0.9)
		sb.border_color = Color(0.85, 0.45, 0.45, 0.85)
	else:
		sb.bg_color = Color(0.20, 0.12, 0.14, 0.85)
		sb.border_color = Color(0.55, 0.30, 0.35, 0.55)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 6
	sb.corner_radius_top_right = 6
	sb.corner_radius_bottom_left = 6
	sb.corner_radius_bottom_right = 6
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb

func _rank_color(idx: int) -> Color:
	if idx == 0:
		return Color(1.0, 0.84, 0.0, 1)
	elif idx == 1:
		return Color(0.85, 0.85, 0.92, 1)
	elif idx == 2:
		return Color(0.92, 0.62, 0.30, 1)
	return Color(0.65, 0.72, 0.85, 1)

func _row_bg_color(idx: int) -> Color:
	if idx == 0:
		return Color(0.20, 0.15, 0.05, 0.85)
	elif idx == 1:
		return Color(0.12, 0.14, 0.18, 0.85)
	elif idx == 2:
		return Color(0.18, 0.12, 0.07, 0.85)
	return Color(0.10, 0.12, 0.18, 0.75)

func _row_border_color(idx: int) -> Color:
	if idx == 0:
		return Color(1.0, 0.84, 0.0, 0.55)
	elif idx == 1:
		return Color(0.85, 0.85, 0.92, 0.40)
	elif idx == 2:
		return Color(0.92, 0.62, 0.30, 0.45)
	return Color(0.55, 0.62, 0.78, 0.25)

func _on_retour() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

# ---- Modale admin (F10) -----------------------------------------------------

func _setup_admin_modal() -> void:
	_admin_modal = ADMIN_MODAL_SCENE.instantiate()
	add_child(_admin_modal)
	_admin_modal.clear_all_requested.connect(_on_admin_clear_all)
	_admin_modal.inline_delete_toggled.connect(_on_admin_inline_delete_toggled)
	_admin_modal.path_changed.connect(_on_admin_path_changed)
	_update_admin_controls()

func _toggle_admin_dialog() -> void:
	if _admin_modal.is_open():
		_admin_modal.hide_modal()
		return
	_admin_modal.set_inline_delete(_admin_inline_delete)
	_update_admin_controls()
	_refresh_tabs()
	_admin_modal.show_modal()

func _selected_mode() -> String:
	return "story" # Mode par défaut, car il n'y a plus de sélecteur

func _update_admin_controls() -> void:
	if _admin_modal == null:
		return
	var empty: bool = Globals.leaderboard.get_entries("story").is_empty() \
		and Globals.leaderboard.get_entries("racing").is_empty()
	_admin_modal.set_clear_all_disabled(empty)

func _on_admin_inline_delete_toggled(enabled: bool) -> void:
	_admin_inline_delete = enabled
	_refresh_tabs()

func _on_admin_clear_all() -> void:
	Globals.leaderboard.clear_all()
	_refresh_tabs()
	_update_admin_controls()

func _on_admin_path_changed() -> void:
	# Le path a changé : on rafraîchit l'affichage (le data store a déjà ré-écrit)
	_refresh_tabs()
	_update_admin_controls()
