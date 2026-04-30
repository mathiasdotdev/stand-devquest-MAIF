extends Control

@onready var _score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var _verdict_label: Label = $MarginContainer/VBoxContainer/VerdictLabel
@onready var _contracts_info: Label = $MarginContainer/VBoxContainer/ContractsInfo
@onready var _tips_container: VBoxContainer = $MarginContainer/VBoxContainer/TipsContainer
@onready var _next_btn: Button = $MarginContainer/VBoxContainer/BtnNext

var _answer: Dictionary
var _chapitre: Dictionary

func _ready() -> void:
	_answer = StoryEngine.answers.back()
	_chapitre = Chapitres.get_chapitre(_answer["chapitre_id"])

	_display_score()
	_display_contracts_info()
	_display_tips()

	var is_last: bool = StoryEngine.current_chapitre + 1 >= Chapitres.count()
	_next_btn.text = "Voir l'analyse finale" if is_last else "Chapitre suivant"
	_next_btn.pressed.connect(_on_next)

func _display_score() -> void:
	var score: int = _answer["score_earned"]
	_score_label.text = "Score : " + str(score) + " / 3"

	var colors := [Color(1, 0.35, 0.35), Color(1, 0.7, 0.3), Color(0.6, 1, 0.4), Color(0.3, 1, 0.5)]
	_score_label.add_theme_color_override("font_color", colors[clamp(score, 0, 3)])

	var verdicts := [
		"Raté. Les bons contrats étaient différents.",
		"Passable. Revoyez les risques de ce chapitre.",
		"Bien joué ! Presque parfait.",
		"Parfait ! Vous avez choisi les bons contrats.",
	]
	_verdict_label.text = verdicts[clamp(score, 0, 3)]

func _display_contracts_info() -> void:
	var recommended: Array = _chapitre["recommended_contracts"]
	var labels: Array = []
	for ct: String in recommended:
		var c: Dictionary = Contracts.get_by_type(ct)
		labels.append(c["icon"] + " " + c["label"])
	_contracts_info.text = "Recommandes : " + ", ".join(labels)
	if _answer["is_correct"]:
		_contracts_info.add_theme_color_override("font_color", Color(0.4, 1, 0.4, 1))
	else:
		_contracts_info.add_theme_color_override("font_color", Color(1, 0.65, 0.3, 1))

func _display_tips() -> void:
	for tip: Dictionary in _chapitre["prevention_tips"]:
		var lbl := Label.new()
		lbl.text = tip["emoji"] + "  " + tip["tip"]
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(0.75, 0.9, 1, 1))
		_tips_container.add_child(lbl)

func _on_next() -> void:
	var has_next: bool = StoryEngine.next_chapitre()
	if has_next:
		get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/chapitre_intro.tscn")
	else:
		get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/analysis.tscn")
