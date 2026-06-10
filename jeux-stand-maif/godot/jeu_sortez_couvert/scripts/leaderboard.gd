extends Control

const MODE_IDS := ["story", "racing"]
const MODE_LABELS := ["Histoire", "Pasdetolismo"]
const ADMIN_MODAL_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/admin_modal.tscn")
# Icône enveloppe (image, identique sur tous les OS) plutôt qu'un emoji ✉️ dont
# le rendu dépend de la police système.
const EMAIL_ICON: Texture2D = preload("res://jeu_sortez_couvert/ui/assets/email.png")

# Nombre d'entrées affichées dans l'UI par défaut (override possible via la modale F10)
const DEFAULT_DISPLAY_LIMIT := 10

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
# État des filtres (live depuis la modale F10)
var _filter_email_only: bool = false
var _filter_min_score: float = 0.0
var _filter_display_limit: int = DEFAULT_DISPLAY_LIMIT

func _ready() -> void:
	_data_font = SystemFont.new()
	_data_font.font_names = PackedStringArray(["Segoe UI", "Arial", "Helvetica", "sans-serif"])
	btn_retour.pressed.connect(_on_retour)
	_setup_admin_modal()
	_refresh_tabs()
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

	# On récupère TOUTES les entrées, puis on filtre, puis on limite à DISPLAY_LIMIT.
	var leaderboard: Node = get_node("/root/Leaderboard")
	var entries: Array = _apply_filters(leaderboard.get_entries(mode))
	if entries.is_empty():
		var lbl := Label.new()
		lbl.text = _empty_text()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_override("font", _data_font)
		lbl.add_theme_font_size_override("font_size", 20)
		lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8, 1))
		container.add_child(lbl)
		return
	var display_count: int = min(entries.size(), _filter_display_limit)
	for i in display_count:
		container.add_child(_build_entry_row(mode, i, entries[i]))

# Retourne les entrées filtrées par email_only / min_score effectif.
# Le tri (meilleur en tête) est déjà fait par le data store.
func _apply_filters(entries: Array) -> Array:
	if not _filter_email_only and _filter_min_score <= 0.0:
		return entries
	var filtered: Array = []
	for e: Dictionary in entries:
		if _filter_email_only and String(e.get("email", "")).strip_edges().is_empty():
			continue
		if _filter_min_score > 0.0 and float(e.get("effective_score", 0.0)) < _filter_min_score:
			continue
		filtered.append(e)
	return filtered

func _empty_text() -> String:
	if _filter_email_only or _filter_min_score > 0.0:
		return "Aucun score ne correspond aux filtres"
	return "Aucun score enregistré"

func _build_entry_row(mode: String, idx: int, entry: Dictionary) -> Control:
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

	# Indicateur email : icône enveloppe si renseigné, "—" gris sinon.
	row.add_child(_build_email_indicator(String(entry.get("email", "")).strip_edges()))

	var ts: int = LeaderboardStore.get_timestamp(entry)
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
		var raw_score: int = LeaderboardStore.get_score_total(entry)
		var hints: int = LeaderboardStore.get_hints_total(entry)
		var effective: float = float(entry.get("effective_score", raw_score))
		var max_total: int = Globals.story_engine.pool_size * 3
		score_lbl.text = "%d / %d (%0.1f)" % [raw_score, max_total, effective]
		score_lbl.tooltip_text = _story_tooltip(entry, hints)
	else:
		score_lbl.text = "%d pts" % int(entry.get("score", 0))
	score_lbl.custom_minimum_size = Vector2(160, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_override("font", _data_font)
	score_lbl.add_theme_font_size_override("font_size", 24)
	score_lbl.add_theme_color_override("font_color", Color(1, 0.92, 0.55, 1))
	row.add_child(score_lbl)

	return panel

# Colonne email : icône enveloppe (email.png) si un email est renseigné, sinon
# un tiret gris. On utilise une image plutôt que l'emoji ✉️ pour un rendu
# identique quel que soit l'OS / la police système.
func _build_email_indicator(email_str: String) -> Control:
	if email_str.is_empty():
		var dash := Label.new()
		dash.custom_minimum_size = Vector2(32, 0)
		dash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dash.add_theme_font_override("font", _data_font)
		dash.text = "—"
		dash.tooltip_text = "Pas d'email — gain non récupérable"
		dash.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65, 1))
		dash.add_theme_font_size_override("font_size", 22)
		return dash
	var icon := TextureRect.new()
	icon.texture = EMAIL_ICON
	icon.custom_minimum_size = Vector2(32, 24)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.tooltip_text = "Email : " + email_str
	return icon

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

func _story_tooltip(entry: Dictionary, total_hints: int) -> String:
	var base: String = "Indices: %d | Pénalité: -%0.1f" % [total_hints, float(total_hints) * 0.5]
	var chapters: Array = LeaderboardStore.get_chapter_breakdown(entry)
	if chapters.is_empty():
		return base
	var lines: PackedStringArray = [base, ""]
	for c: Dictionary in chapters:
		var d: Dictionary = c["data"]
		var title: String = String(d.get("title", ""))
		var score_str: String = String(d.get("score", "?/?"))
		var hint: int = int(d.get("hint_used", 0))
		var line: String = "Ch.%d — %s : %s" % [int(c["index"]), title, score_str]
		if hint > 0:
			line += "  (%d indice%s)" % [hint, "s" if hint > 1 else ""]
		lines.append(line)
	return "\n".join(lines)

func _on_retour() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

# ---- Modale admin (F10) -----------------------------------------------------

func _setup_admin_modal() -> void:
	_admin_modal = ADMIN_MODAL_SCENE.instantiate()
	add_child(_admin_modal)
	_admin_modal.path_changed.connect(_on_admin_path_changed)
	_admin_modal.filter_changed.connect(_on_admin_filter_changed)

func _toggle_admin_dialog() -> void:
	if _admin_modal.is_open():
		_admin_modal.hide_modal()
		return
	_admin_modal.show_modal()

func _on_admin_path_changed() -> void:
	_refresh_tabs()

func _on_admin_filter_changed() -> void:
	_filter_email_only = _admin_modal.get_email_only_filter()
	_filter_min_score = _admin_modal.get_min_score_filter()
	_filter_display_limit = _admin_modal.get_display_limit()
	_refresh_tabs()
