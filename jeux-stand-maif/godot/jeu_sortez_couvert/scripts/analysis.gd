extends Control

@onready var _total_score_label: Label = $MarginContainer/VBoxContainer/TotalScoreLabel
@onready var _label_label: Label = $MarginContainer/VBoxContainer/LabelLabel
@onready var _chapter_info: Label = $MarginContainer/VBoxContainer/ChapterNav/ChapterInfo
@onready var _btn_prev: Button = $MarginContainer/VBoxContainer/ChapterNav/BtnPrev
@onready var _btn_next_chap: Button = $MarginContainer/VBoxContainer/ChapterNav/BtnNextChap
@onready var _best_label: Label = $MarginContainer/VBoxContainer/BestLabel
@onready var _worst_label: Label = $MarginContainer/VBoxContainer/WorstLabel
@onready var _name_input: LineEdit = $MarginContainer/VBoxContainer/NameRow/NameInput
@onready var _btn_save: Button = $MarginContainer/VBoxContainer/NameRow/BtnSaveScore
@onready var _save_status: Label = $MarginContainer/VBoxContainer/SaveStatus
@onready var _menu_btn: Button = $MarginContainer/VBoxContainer/BtnMenu

var _analysis: Dictionary
var _view_idx: int = 0
var _score_saved: bool = false

func _ready() -> void:
	_analysis = StoryEngine.get_analysis()

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
	_btn_save.pressed.connect(_on_save_score)
	_menu_btn.pressed.connect(_on_menu)

	if StoryEngine.player_name != "":
		_name_input.text = StoryEngine.player_name
	var score: int = _analysis["total_score"]
	if not Leaderboard.is_top_ten("story", score):
		_btn_save.disabled = true
		_save_status.text = "Score insuffisant pour le top 10"
		_save_status.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))

	_show_chapter_view(0)

func _show_chapter_view(idx: int) -> void:
	var answers: Array = _analysis["answers"]
	if answers.is_empty():
		_chapter_info.text = "Aucune donnee"
		return

	_view_idx = clamp(idx, 0, answers.size() - 1)
	var a: Dictionary = answers[_view_idx]
	var chapitre: Dictionary = Chapitres.get_chapitre(a["chapitre_id"])

	var chosen_labels: Array = []
	for ct: String in a["chosen_contracts"]:
		var c: Dictionary = Contracts.get_by_type(ct)
		chosen_labels.append(c.get("label", ct))

	var recommended_labels: Array = []
	for ct: String in a["correct_contracts"]:
		var c: Dictionary = Contracts.get_by_type(ct)
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

func _on_save_score() -> void:
	if _score_saved:
		return
	var name: String = _name_input.text.strip_edges()
	if name.is_empty():
		name = "Anonyme"
	var score: int = _analysis["total_score"]
	var rank: int = Leaderboard.add_entry("story", name, score)
	_score_saved = true
	_btn_save.disabled = true
	_name_input.editable = false
	if rank >= 0:
		_save_status.text = "Enregistré ! Rang #" + str(rank + 1)
	else:
		_save_status.text = "Score enregistré"

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
