extends Control

const MODE_IDS := ["story", "racing"]
const MODE_LABELS := ["Histoire", "Pasdetolismo"]

var _admin_dialog: AcceptDialog
var _show_emails_check: CheckBox
var _inline_delete_check: CheckBox
var _btn_clear_mode: Button
var _btn_clear_all: Button
var _admin_reveal_emails: bool = false
var _admin_inline_delete: bool = false

# Feature flipping pour masquer l’onglet Pasdetolismo
const PASDETOLISMO_ENABLED := false

func _ready() -> void:
	_refresh_tabs()
	$VBox/BtnRetour.pressed.connect(_on_retour)
	_create_admin_dialog()
	if not PASDETOLISMO_ENABLED:
		$VBox/Tabs.get_tab_bar().set_tab_hidden(1, true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F10:
		_toggle_admin_dialog()
		get_viewport().set_input_as_handled()

func _refresh_tabs() -> void:
	_populate_tab("story", $VBox/Tabs/Histoire/ScrollContainer/EntryList)
	_populate_tab("racing", $VBox/Tabs/Pasdetolismo/ScrollContainer/EntryList)

func _leaderboard() -> Node:
	return get_node("/root/Leaderboard")

func _populate_tab(mode: String, container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()
	
	var leaderboard: Node = get_node("/root/Leaderboard")
	var entries: Array = leaderboard.get_entries(mode)
	if entries.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucun score enregistré"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		container.add_child(lbl)
		return
	for i in entries.size():
		container.add_child(_build_entry_row(mode, i, entries[i]))

func _build_entry_row(mode: String, idx: int, entry: Dictionary) -> Control:
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = _row_bg_color(idx)
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
	rank.custom_minimum_size = Vector2(50, 0)
	rank.add_theme_font_size_override("font_size", 20)
	rank.add_theme_color_override("font_color", _rank_color(idx))
	row.add_child(rank)

	var name_lbl := Label.new()
	name_lbl.text = String(entry.get("name", "???"))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	row.add_child(name_lbl)

	if _admin_reveal_emails and not String(entry.get("email", "")).is_empty():
		var email_lbl := Label.new()
		email_lbl.text = "<" + String(entry.get("email", "")) + ">"
		email_lbl.add_theme_font_size_override("font_size", 14)
		email_lbl.add_theme_color_override("font_color", Color(0.72, 0.82, 1.0, 1))
		row.add_child(email_lbl)

	var ts: int = int(entry.get("timestamp", 0))
	if ts > 0:
		var dt: Dictionary = Time.get_datetime_dict_from_unix_time(ts)
		var date_lbl := Label.new()
		date_lbl.text = "%02d/%02d/%d" % [int(dt.day), int(dt.month), int(dt.year)]
		date_lbl.add_theme_font_size_override("font_size", 14)
		date_lbl.add_theme_color_override("font_color", Color(0.65, 0.72, 0.85, 1))
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
	score_lbl.custom_minimum_size = Vector2(120, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_size_override("font_size", 20)
	score_lbl.add_theme_color_override("font_color", Color(0.27, 0.67, 1, 1))
	row.add_child(score_lbl)

	if _admin_inline_delete:
		var delete_btn := Button.new()
		delete_btn.text = "Suppr."
		delete_btn.tooltip_text = "Supprimer l'entrée #%d" % (idx + 1)
		delete_btn.custom_minimum_size = Vector2(78, 0)
		delete_btn.pressed.connect(func() -> void:
			var leaderboard: Node = _leaderboard()
			leaderboard.remove_entry(mode, idx)
			_refresh_tabs()
			_update_admin_controls()
		)
		row.add_child(delete_btn)

	return panel

func _rank_color(idx: int) -> Color:
	if idx == 0:
		return Color(1.0, 0.84, 0.0, 1)
	elif idx == 1:
		return Color(0.78, 0.78, 0.82, 1)
	elif idx == 2:
		return Color(0.85, 0.55, 0.25, 1)
	return Color(0.55, 0.62, 0.75, 1)

func _row_bg_color(idx: int) -> Color:
	if idx == 0:
		return Color(0.16, 0.13, 0.05, 0.85)
	elif idx == 1:
		return Color(0.10, 0.11, 0.14, 0.85)
	elif idx == 2:
		return Color(0.14, 0.10, 0.06, 0.85)
	return Color(0.08, 0.10, 0.16, 0.75)

func _on_retour() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func _create_admin_dialog() -> void:
	_admin_dialog = AcceptDialog.new()
	_admin_dialog.title = "Paramètres classement"
	_admin_dialog.dialog_text = ""
	_admin_dialog.min_size = Vector2i(540, 320)
	_admin_dialog.max_size = Vector2i(720, 420)
	add_child(_admin_dialog)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	_admin_dialog.add_child(content)

	var help_lbl := Label.new()
	help_lbl.text = "Admin local: suppression rapide par ligne + suppression ciblée + vidage."
	help_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(help_lbl)

	_show_emails_check = CheckBox.new()
	_show_emails_check.text = "Afficher les emails dans la liste (vue admin locale)"
	content.add_child(_show_emails_check)

	_inline_delete_check = CheckBox.new()
	_inline_delete_check.text = "Activer la suppression directe dans la liste"
	content.add_child(_inline_delete_check)

	_btn_clear_mode = _admin_dialog.add_button("Vider ce mode", true, "clear_mode")
	_btn_clear_all = _admin_dialog.add_button("Tout supprimer", true, "clear_all")
	_admin_dialog.get_ok_button().text = "Fermer"

	_show_emails_check.toggled.connect(_on_toggle_email_visibility)
	_inline_delete_check.toggled.connect(_on_toggle_inline_delete)
	_admin_dialog.custom_action.connect(_on_admin_custom_action)
	_admin_dialog.visibility_changed.connect(_on_admin_dialog_visibility_changed)

	_update_admin_controls()

func _toggle_admin_dialog() -> void:
	_show_emails_check.button_pressed = _admin_reveal_emails
	_inline_delete_check.button_pressed = _admin_inline_delete
	_update_admin_controls()
	_refresh_tabs()
	_admin_dialog.popup_centered(Vector2i(560, 340))

func _selected_mode() -> String:
	return "story" # Mode par défaut, car il n'y a plus de sélecteur

func _update_admin_controls() -> void:
	var mode := _selected_mode()
	var leaderboard: Node = _leaderboard()
	var count: int = leaderboard.get_entries(mode).size()
	_btn_clear_mode.disabled = count == 0
	_btn_clear_all.disabled = leaderboard.get_entries("story").is_empty() and leaderboard.get_entries("racing").is_empty()

func _on_toggle_email_visibility(show_emails: bool) -> void:
	_admin_reveal_emails = show_emails
	_refresh_tabs()

func _on_toggle_inline_delete(enabled: bool) -> void:
	_admin_inline_delete = enabled
	_refresh_tabs()

func _on_admin_dialog_visibility_changed() -> void:
	pass # Ne rien faire ici pour laisser persister la suppression directe

func _on_admin_custom_action(action: StringName) -> void:
	var mode := _selected_mode()
	var leaderboard: Node = _leaderboard()
	match String(action):
		"clear_mode":
			leaderboard.clear_mode(mode)
		"clear_all":
			leaderboard.clear_all()
		_:
			return
	_refresh_tabs()
	_update_admin_controls()
