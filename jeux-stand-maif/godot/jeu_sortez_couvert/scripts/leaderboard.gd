extends Control

func _ready() -> void:
	_populate_tab("story", $VBox/Tabs/Histoire/ScrollContainer/EntryList)
	_populate_tab("racing", $VBox/Tabs/Pasdetolismo/ScrollContainer/EntryList)
	$VBox/BtnRetour.pressed.connect(_on_retour)

func _populate_tab(mode: String, container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()
	var entries: Array = Leaderboard.get_entries(mode)
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
		score_lbl.text = "%d / 18" % int(entry.get("score", 0))
	else:
		score_lbl.text = "%d pts" % int(entry.get("score", 0))
	score_lbl.custom_minimum_size = Vector2(120, 0)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_lbl.add_theme_font_size_override("font_size", 20)
	score_lbl.add_theme_color_override("font_color", Color(0.27, 0.67, 1, 1))
	row.add_child(score_lbl)

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
