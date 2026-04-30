extends Control

func _ready() -> void:
	_populate_tab("story", $VBox/Tabs/Histoire/ScrollContainer/EntryList)
	_populate_tab("racing", $VBox/Tabs/Pasdetolismo/ScrollContainer/EntryList)
	$VBox/BtnRetour.pressed.connect(_on_retour)

func _populate_tab(mode: String, container: VBoxContainer) -> void:
	var entries: Array = Leaderboard.get_entries(mode)
	if entries.is_empty():
		var lbl := Label.new()
		lbl.text = "Aucun score enregistré"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		container.add_child(lbl)
		return
	for i in entries.size():
		var entry: Dictionary = entries[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		var rank := Label.new()
		rank.text = "#" + str(i + 1)
		rank.custom_minimum_size = Vector2(40, 0)
		rank.add_theme_font_size_override("font_size", 18)
		if i == 0:
			rank.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0, 1))
		elif i == 1:
			rank.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 1))
		elif i == 2:
			rank.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2, 1))
		var name_lbl := Label.new()
		name_lbl.text = entry["name"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 18)
		var score_lbl := Label.new()
		if mode == "story":
			score_lbl.text = str(entry["score"]) + " / 18"
		else:
			score_lbl.text = str(entry["score"]) + " pts"
		score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		score_lbl.add_theme_font_size_override("font_size", 18)
		score_lbl.add_theme_color_override("font_color", Color(0.27, 0.67, 1, 1))
		row.add_child(rank)
		row.add_child(name_lbl)
		row.add_child(score_lbl)
		container.add_child(row)

func _on_retour() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
