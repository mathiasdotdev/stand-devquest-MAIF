extends Control

const COLOR_LABELS: Dictionary = {
	"green":  "Vert",
	"orange": "Orange",
	"red":    "Rouge",
	"white":  "Blanc",
}
const COLOR_RGB: Dictionary = {
	"green":  Color(0.34, 0.78, 0.41),
	"orange": Color(0.98, 0.55, 0.18),
	"red":    Color(0.87, 0.27, 0.27),
	"white":  Color(0.92, 0.92, 0.92),
}

@onready var results_row: HBoxContainer = $Center/Panel/Margin/VBox/ResultsRow
@onready var winner_label: Label = $Center/Panel/Margin/VBox/WinnerLabel
@onready var leaderboard_section: VBoxContainer = $Center/Panel/Margin/VBox/LeaderboardSection
@onready var leaderboard_message: Label = $Center/Panel/Margin/VBox/LeaderboardSection/Message
@onready var name_input: LineEdit = $Center/Panel/Margin/VBox/LeaderboardSection/NameInput
@onready var btn_save: Button = $Center/Panel/Margin/VBox/LeaderboardSection/BtnSave
@onready var btn_rejouer: Button = $Center/Panel/Margin/VBox/Footer/BtnRejouer
@onready var btn_menu: Button = $Center/Panel/Margin/VBox/Footer/BtnMenu

var _solo_score: int = 0
var _saved: bool = false

func _ready() -> void:
	btn_rejouer.pressed.connect(_on_rejouer)
	btn_menu.pressed.connect(_on_menu)
	btn_save.pressed.connect(_on_save)
	_render_results()
	_render_winner()
	_render_leaderboard()

func _render_results() -> void:
	for child in results_row.get_children():
		child.queue_free()
	for r in RaceSession.last_results:
		var player_dict: Dictionary = {}
		for p in RaceSession.players:
			if int(p.get("player_id", -1)) == int(r["player_id"]):
				player_dict = p
				break
		results_row.add_child(_build_result_panel(r, player_dict))

func _build_result_panel(result: Dictionary, player: Dictionary) -> Control:
	var color_key: String = player.get("color", "yellow") as String
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = COLOR_RGB.get(color_key, Color.DIM_GRAY).darkened(0.55)
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", sb)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	margin.add_child(vb)

	var color_dot := ColorRect.new()
	color_dot.custom_minimum_size = Vector2(24, 24)
	color_dot.color = COLOR_RGB.get(color_key, Color.DIM_GRAY)
	vb.add_child(color_dot)

	vb.add_child(_label("Joueur %d (%s)" % [int(result["player_id"]) + 1, COLOR_LABELS.get(color_key, color_key)], 20, Color(1, 1, 1)))
	vb.add_child(_label("🎯 Score : %d" % int(result["score"]), 22, Color(1, 1, 0.6)))
	vb.add_child(_label("📏 Distance : %d m" % int(result["distance"]), 16, Color(0.85, 0.95, 1)))
	vb.add_child(_label("💰 Or restant : %d" % int(result["gold_remaining"]), 16, Color(1, 0.9, 0.35)))

	var status_text: String = "✅ A tenu la course" if result.get("alive", false) else "💥 Hors-service"
	var status_color: Color = Color(0.5, 1, 0.5) if result.get("alive", false) else Color(1, 0.45, 0.45)
	vb.add_child(_label(status_text, 14, status_color))

	return panel

func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l

func _render_winner() -> void:
	if RaceSession.mode != "multi" or RaceSession.last_results.size() < 2:
		winner_label.visible = false
		return
	var best_idx: int = 0
	var best_score: float = -1.0
	for i in RaceSession.last_results.size():
		var s: float = float(RaceSession.last_results[i]["score"])
		if s > best_score:
			best_score = s
			best_idx = i
	var winner_id: int = int(RaceSession.last_results[best_idx]["player_id"])
	winner_label.visible = true
	winner_label.text = "🏆 Joueur %d remporte la course !" % (winner_id + 1)

func _render_leaderboard() -> void:
	if RaceSession.mode != "solo" or RaceSession.last_results.is_empty():
		leaderboard_section.visible = false
		return
	_solo_score = int(RaceSession.last_results[0]["score"])
	if not Leaderboard.is_top_ten("racing", _solo_score):
		leaderboard_section.visible = false
		return
	leaderboard_section.visible = true
	leaderboard_message.text = "🏅 Top 10 ! Entre ton nom :"
	name_input.text = ""
	name_input.grab_focus()

func _on_save() -> void:
	if _saved:
		return
	var n: String = name_input.text.strip_edges()
	if n.is_empty():
		n = "Joueur"
	Leaderboard.add_entry("racing", n, _solo_score)
	_saved = true
	leaderboard_message.text = "🏅 Score enregistre !"
	name_input.editable = false
	btn_save.disabled = true

func _on_rejouer() -> void:
	get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/pre_race_menu.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
