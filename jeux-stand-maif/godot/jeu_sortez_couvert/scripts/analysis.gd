extends Control

@onready var _total_score_label: Label = $MarginContainer/VBoxContainer/TotalScoreLabel
@onready var _label_label: Label = $MarginContainer/VBoxContainer/LabelLabel
@onready var _chapter_info: Label = $MarginContainer/VBoxContainer/ChapterNav/ChapterInfo
@onready var _btn_prev: Button = $MarginContainer/VBoxContainer/ChapterNav/BtnPrev
@onready var _btn_next_chap: Button = $MarginContainer/VBoxContainer/ChapterNav/BtnNextChap
@onready var _best_label: Label = $MarginContainer/VBoxContainer/BestLabel
@onready var _worst_label: Label = $MarginContainer/VBoxContainer/WorstLabel
@onready var _prize_label: Label = $MarginContainer/VBoxContainer/PrizeLabel
@onready var _menu_btn: Button = $MarginContainer/VBoxContainer/BtnMenu

var _analysis: Dictionary
var _view_idx: int = 0

func _ready() -> void:
	StorySceneLayout.apply(self)

	_analysis = Globals.story_engine.get_analysis()

	_total_score_label.text = "Score total : " + str(_analysis["total_score"]) + " / " + str(_analysis["max_score"])
	_label_label.text = _analysis["label"]

	var label_colors := {
		"Expert MAIF": Color(0.3, 1, 0.5),
		"Bon eleve": Color(0.3, 0.8, 1),
		"A ameliorer": Color(1, 0.7, 0.2),
		"Debutant": Color(1, 0.4, 0.4),
	}
	var col: Color = label_colors.get(_analysis["label"], Color(1, 1, 1))
	_label_label.add_theme_color_override("font_color", col)

	_best_label.text = "Meilleur : " + _analysis["best_choice"]
	_worst_label.text = "A ameliorer : " + _analysis["worst_choice"]

	_btn_prev.pressed.connect(_on_prev)
	_btn_next_chap.pressed.connect(_on_next_chap)
	_menu_btn.pressed.connect(_on_menu)
	_show_chapter_view(0)

	# On garde uniquement les top scores (avec pénalité d'indices pour le classement).
	save_score_if_top_ten()
	_update_prize_section()

func _show_chapter_view(idx: int) -> void:
	var answers: Array = _analysis["answers"]
	if answers.is_empty():
		_chapter_info.text = "Aucune donnee"
		return

	_view_idx = clamp(idx, 0, answers.size() - 1)
	var a: Dictionary = answers[_view_idx]
	var chapitre: Dictionary = Globals.chapitres.get_chapitre(a["chapitre_id"])

	var chosen_labels: Array = []
	for ct: String in a["chosen_contracts"]:
		var c: Dictionary = Globals.contracts.get_by_type(ct)
		chosen_labels.append(c.get("label", ct))

	var recommended_labels: Array = []
	for ct: String in a["correct_contracts"]:
		var c: Dictionary = Globals.contracts.get_by_type(ct)
		recommended_labels.append(c.get("label", ct))

	var verdict: String
	if a["is_correct"]:
		verdict = "✓ " + str(a["score_earned"]) + "/3 pts"
	else:
		verdict = "✗ " + str(a["score_earned"]) + "/3 pts"

	var hint_note: String = ""
	if a["hints_used"] > 0:
		hint_note = " (" + str(a["hints_used"]) + " indice(s))"

	_chapter_info.text = (
		"Ch. " + str(_view_idx + 1) + " — " + chapitre["emoji"] + " " + chapitre["titre"] + "\n"
		+ "Vous : " + (", ".join(chosen_labels) if not chosen_labels.is_empty() else "aucun contrat") + "\n"
		+ "Recommande : " + ", ".join(recommended_labels) + "\n"
		+ verdict + hint_note
	)

	_btn_prev.disabled = _view_idx <= 0
	_btn_next_chap.disabled = _view_idx >= answers.size() - 1

func _on_prev() -> void:
	_show_chapter_view(_view_idx - 1)

func _on_next_chap() -> void:
	_show_chapter_view(_view_idx + 1)


func save_score_if_top_ten() -> void:
	var score: int = _analysis["total_score"]
	var hints_used: int = _total_hints_used()
	if Globals.leaderboard.is_top_ten("story", score, hints_used):
		if Globals.story_engine.player_name.is_empty():
			Globals.story_engine.player_name = "Anonyme"
		Globals.leaderboard.add_entry("story", Globals.story_engine.player_name, score, Globals.story_engine.player_email, hints_used)

func _total_hints_used() -> int:
	var total_hints := 0
	for a: Dictionary in _analysis.get("answers", []):
		total_hints += int(a.get("hints_used", 0))
	return total_hints

func _update_prize_section() -> void:
	var best_entry: Dictionary = Globals.leaderboard.get_best_entry("story")
	if best_entry.is_empty():
		_prize_label.text = "🎁 Cadeau meilleur score : aucun score enregistré pour l'instant."
		return
	var best_name: String = String(best_entry.get("name", "Anonyme"))
	var best_score: int = int(best_entry.get("score", 0))
	var best_hints: int = int(best_entry.get("hints_used", 0))
	var best_effective: float = float(best_entry.get("effective_score", best_score))
	_prize_label.text = "🎁 Cadeau meilleur score : %s mène avec %d/18 (%0.1f après pénalité), %d indice(s). En cas d'égalité au score brut, moins d'indices = mieux classé." % [best_name, best_score, best_effective, best_hints]

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
