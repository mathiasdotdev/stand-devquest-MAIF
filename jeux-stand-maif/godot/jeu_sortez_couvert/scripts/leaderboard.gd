extends Control

const ADMIN_MODAL_SCENE: PackedScene = preload("res://jeu_sortez_couvert/ui/admin_modal.tscn")
# Icône enveloppe (image, identique sur tous les OS) plutôt qu'un emoji dont le
# rendu dépend de la police système. Affichée UNIQUEMENT dans l'onglet "Général"
# pour indiquer si l'email est renseigné — jamais l'adresse elle-même.
const EMAIL_ICON: Texture2D = preload("res://jeu_sortez_couvert/ui/assets/email.png")

# Police plus lisible pour les data (noms de joueurs, dates, scores numériques)
# où la police décorative du thème devient illisible.
var _data_font: SystemFont

@onready var tabs: TabContainer = $MenuPanel/Margin/VBox/Tabs
# Sélecteurs d'onglet : de vrais boutons (même style que le reste de l'UI),
# plutôt que la barre d'onglets native du TabContainer.
@onready var btn_tab_email: Button = $MenuPanel/Margin/VBox/TabButtons/BtnAvecEmail
@onready var btn_tab_general: Button = $MenuPanel/Margin/VBox/TabButtons/BtnGeneral
# Onglet par défaut : seulement les joueurs joignables (email renseigné) → le #1
# est directement le gagnant à qui remettre le lot.
@onready var email_list: VBoxContainer = $MenuPanel/Margin/VBox/Tabs/AvecEmail/ScrollContainer/EntryList
# Onglet secondaire : tout le monde (avec ou sans email), avec l'icône email.
@onready var general_list: VBoxContainer = $MenuPanel/Margin/VBox/Tabs/General/ScrollContainer/EntryList
@onready var btn_retour: Button = $MenuPanel/Margin/VBox/BtnRetour

var _admin_modal: CanvasLayer

func _ready() -> void:
	_data_font = SystemFont.new()
	_data_font.font_names = PackedStringArray(["Segoe UI", "Arial", "Helvetica", "sans-serif"])
	btn_retour.pressed.connect(_on_retour)
	btn_tab_email.pressed.connect(func(): _select_tab(0))
	btn_tab_general.pressed.connect(func(): _select_tab(1))
	_setup_admin_modal()
	_refresh_tabs()
	_select_tab(0)

# Bascule d'onglet via les boutons : change le contenu affiché et atténue le
# bouton inactif pour signaler l'onglet courant.
func _select_tab(idx: int) -> void:
	tabs.current_tab = idx
	btn_tab_email.modulate = Color(1, 1, 1, 1) if idx == 0 else Color(1, 1, 1, 0.45)
	btn_tab_general.modulate = Color(1, 1, 1, 1) if idx == 1 else Color(1, 1, 1, 0.45)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		Sfx.play("switch")
		_toggle_admin_dialog()
		get_viewport().set_input_as_handled()

func _refresh_tabs() -> void:
	# Onglet "Avec email" : uniquement les entrées avec email (rang recalculé
	# entre elles → le meilleur joueur joignable est en #1). Pas d'icône email
	# (redondant, tout le monde en a un ici).
	var with_email: Array = []
	for e: Dictionary in Globals.leaderboard.get_entries("story"):
		if not String(e.get("email", "")).strip_edges().is_empty():
			with_email.append(e)
	_populate(email_list, with_email, false, "Aucun joueur avec email pour l'instant")

	# Onglet "Général" : tout le monde, avec l'icône email (ou "—").
	_populate(general_list, Globals.leaderboard.get_entries("story"), true, "Aucun score enregistré")

func _populate(container: VBoxContainer, entries: Array, show_email_icon: bool, empty_text: String) -> void:
	for child in container.get_children():
		child.queue_free()
	if entries.is_empty():
		var lbl := Label.new()
		lbl.text = empty_text
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_override("font", _data_font)
		lbl.add_theme_font_size_override("font_size", 20)
		lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8, 1))
		container.add_child(lbl)
		return
	for i in entries.size():
		container.add_child(_build_entry_row(i, entries[i], show_email_icon))

func _build_entry_row(idx: int, entry: Dictionary, show_email_icon: bool) -> Control:
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

	# Temps passé sur la tentative (l'adresse email n'est jamais affichée ici).
	var duration: int = LeaderboardStore.get_duration_seconds(entry)
	if duration > 0:
		var time_lbl := Label.new()
		time_lbl.text = _format_duration(duration)
		time_lbl.custom_minimum_size = Vector2(90, 0)
		time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		time_lbl.tooltip_text = "Temps passé"
		time_lbl.add_theme_font_override("font", _data_font)
		time_lbl.add_theme_font_size_override("font_size", 16)
		time_lbl.add_theme_color_override("font_color", Color(0.7, 0.85, 0.78, 1))
		row.add_child(time_lbl)

	# Onglet "Général" : indicateur email (icône si renseigné, "—" sinon), placé
	# à droite de la durée. On n'affiche JAMAIS l'adresse — juste sa présence.
	if show_email_icon:
		var has_email: bool = not String(entry.get("email", "")).strip_edges().is_empty()
		row.add_child(_build_email_indicator(has_email))

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
	var raw_score: int = LeaderboardStore.get_score_total(entry)
	var hints: int = LeaderboardStore.get_hints_total(entry)
	var effective: float = float(entry.get("effective_score", raw_score))
	# Note sur 20, basée sur le score effectif (= ce qui classe les joueurs),
	# pour que la note affichée soit cohérente avec le classement.
	# max_total = nb de chapitres joués × 3 (robuste si le pool a changé).
	var chapters: Array = LeaderboardStore.get_chapter_breakdown(entry)
	var nb_chapters: int = chapters.size() if not chapters.is_empty() else Globals.story_engine.pool_size
	var max_total: int = max(1, nb_chapters * 3)
	var note_sur_20: float = effective * 20.0 / float(max_total)
	score_lbl.text = "%0.1f / 20" % note_sur_20
	score_lbl.tooltip_text = "Score : %d / %d (effectif %0.1f)\n%s" % [raw_score, max_total, effective, _story_tooltip(entry, hints)]
	score_lbl.custom_minimum_size = Vector2(160, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_override("font", _data_font)
	score_lbl.add_theme_font_size_override("font_size", 24)
	score_lbl.add_theme_color_override("font_color", Color(1, 0.92, 0.55, 1))
	row.add_child(score_lbl)

	return panel

# Indicateur de présence d'email : icône enveloppe si renseigné, "—" sinon.
# IMPORTANT : on n'affiche jamais l'adresse (ni en texte, ni au survol) — juste
# l'information "email renseigné ou non".
func _build_email_indicator(has_email: bool) -> Control:
	if not has_email:
		var dash := Label.new()
		dash.custom_minimum_size = Vector2(32, 0)
		dash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dash.add_theme_font_override("font", _data_font)
		dash.text = "—"
		dash.tooltip_text = "Pas d'email"
		dash.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65, 1))
		dash.add_theme_font_size_override("font_size", 22)
		return dash
	var icon := TextureRect.new()
	icon.texture = EMAIL_ICON
	icon.custom_minimum_size = Vector2(32, 24)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.tooltip_text = "Email renseigné"
	return icon

# Formate une durée en secondes → "Xmin YYs" ou "Ys".
func _format_duration(secs: int) -> String:
	if secs <= 0:
		return "—"
	@warning_ignore("integer_division")
	var minutes: int = secs / 60
	var seconds: int = secs % 60
	if minutes > 0:
		return "%dmin %02ds" % [minutes, seconds]
	return "%ds" % seconds

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

func _toggle_admin_dialog() -> void:
	if _admin_modal.is_open():
		_admin_modal.hide_modal()
		return
	_admin_modal.show_modal()

func _on_admin_path_changed() -> void:
	_refresh_tabs()
