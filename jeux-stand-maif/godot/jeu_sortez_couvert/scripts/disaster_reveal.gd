extends Control

@onready var _titre_label: Label = $MarginContainer/VBoxContainer/TitreLabel
@onready var _disasters_container: VBoxContainer = $MarginContainer/VBoxContainer/DisastersContainer
@onready var _continue_btn: Button = $MarginContainer/VBoxContainer/BtnContinuer

var _answer: Dictionary

func _ready() -> void:
	_answer = StoryEngine.resolve_current_chapitre()
	_continue_btn.visible = false
	_continue_btn.pressed.connect(_on_continue)

	var chapitre: Dictionary = Chapitres.get_chapitre(_answer["chapitre_id"])
	_titre_label.text = chapitre["emoji"] + "  " + chapitre["titre"] + " — Sinistres survenus"

	_show_disasters()

func _show_disasters() -> void:
	var disaster_hits: Array = _answer["disaster_hits"]

	if disaster_hits.is_empty():
		var label := Label.new()
		label.text = "Aucun sinistre cette fois ! Vous avez eu de la chance."
		label.add_theme_color_override("font_color", Color(0.5, 1, 0.5, 1))
		label.add_theme_font_size_override("font_size", 18)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_disasters_container.add_child(label)
		_continue_btn.visible = true
		return

	var delay := 0.0
	for hit: Dictionary in disaster_hits:
		var dis: Dictionary = Disasters.get_disaster(hit["type"])
		var panel := _make_disaster_panel(dis, hit)
		panel.modulate.a = 0.0
		_disasters_container.add_child(panel)

		var tween := create_tween()
		tween.tween_interval(delay)
		tween.tween_property(panel, "modulate:a", 1.0, 0.5)
		delay += 1.2

	var final_tween := create_tween()
	final_tween.tween_interval(delay + 0.2)
	final_tween.tween_callback(func(): _continue_btn.visible = true)

func _make_disaster_panel(dis: Dictionary, hit: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)

	var icon_lbl := Label.new()
	icon_lbl.text = dis["icon"]
	icon_lbl.add_theme_font_size_override("font_size", 32)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var name_lbl := Label.new()
	name_lbl.text = dis["label"]
	name_lbl.add_theme_font_size_override("font_size", 16)
	info.add_child(name_lbl)

	var narrative_lbl := Label.new()
	narrative_lbl.text = hit["narrative"]
	narrative_lbl.add_theme_font_size_override("font_size", 13)
	narrative_lbl.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 1))
	narrative_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(narrative_lbl)

	var badge_lbl := Label.new()
	if hit["was_covered"]:
		badge_lbl.text = "COUVERT"
		badge_lbl.add_theme_color_override("font_color", Color(0.3, 1, 0.3, 1))
	else:
		badge_lbl.text = "NON COUVERT\n-" + str(dis["base_damage"]) + " euros"
		badge_lbl.add_theme_color_override("font_color", Color(1, 0.35, 0.35, 1))
	badge_lbl.add_theme_font_size_override("font_size", 14)
	badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(badge_lbl)

	return panel

func _on_continue() -> void:
	get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/chapitre_result.tscn")
