extends "res://jeu_sortez_couvert/scripts/story_scene.gd"

const NEXT_CHAPITRE_SCENE := "res://jeu_sortez_couvert/scenes/chapitre_intro.tscn"
const ANALYSIS_SCENE := "res://jeu_sortez_couvert/scenes/analysis.tscn"
const MAX_SCORE_PER_CHAPITRE: int = 3

@onready var _chapitre_num_label: Label = $ChapitreNumLabel
@onready var _score_label: Label = $ScoreLabel

func _ready() -> void:
	super._ready()

	var answer: Dictionary = Globals.story_engine.answers.back()
	var chapitre_id: int = int(answer.get("chapitre_id", 0))
	var score_earned: int = int(answer.get("score_earned", 0))

	_chapitre_num_label.text = "Chapitre %d / %d" % [chapitre_id + 1, Globals.chapitres.count()]
	_score_label.text = "Score : %d / %d" % [score_earned, MAX_SCORE_PER_CHAPITRE]
	_score_label.add_theme_color_override("font_color", _color_for_score(score_earned))

	var lines: Array = _build_lines(answer)
	# Pas de titre dans la bulle pour chapitre_result : info chapitre en haut à gauche,
	# on garde tout l'espace de la bulle pour l'explication.
	setup_story("", lines)

	# Sons de feedback
	if score_earned >= 2:
		Sfx.play("win")
	elif _is_mostly_uncovered(answer):
		Sfx.play("fail")

func _color_for_score(score: int) -> Color:
	if score >= 2:
		return Color(0.4, 0.95, 0.5)   # vert
	if score >= 1:
		return Color(1.0, 0.78, 0.35)  # orange
	return Color(1.0, 0.45, 0.45)      # rouge

func _is_mostly_uncovered(answer: Dictionary) -> bool:
	var disasters: Array = answer.get("disaster_hits", [])
	var total: int = max(disasters.size(), 1)
	var uncovered: int = 0
	for hit: Dictionary in disasters:
		if not bool(hit.get("was_covered", false)):
			uncovered += 1
	return uncovered >= int(ceil(float(total) / 2.0))

func _build_lines(answer: Dictionary) -> Array:
	var result: Array = []
	var score: int = int(answer.get("score_earned", 0))
	var disasters: Array = answer.get("disaster_hits", [])
	var total_count: int = disasters.size()
	var covered_count: int = 0
	for hit: Dictionary in disasters:
		if bool(hit.get("was_covered", false)):
			covered_count += 1
	var uncovered_count: int = total_count - covered_count

	if score >= 3:
		result.append({
			"expression": "hyper-good",
			"text": "Incroyable ! Tout est couvert au juste prix. Vous avez joué comme un véritable chef de clan.",
		})
	elif score >= 2:
		result.append({
			"expression": "ok",
			"text": "Bien joué ! La majorité des risques est couverte.",
		})
	elif uncovered_count >= int(ceil(float(max(total_count, 1)) / 2.0)):
		result.append({
			"expression": "wrong",
			"text": "Aïe... trop de risques ne sont pas couverts. Il faut renforcer la protection.",
		})
	else:
		result.append({
			"expression": "wrong",
			"text": "C'est encore fragile (trop de contrats inutiles ou pas assez de couverture). On corrige ça ensemble.",
		})

	var chosen_contracts: Array = answer.get("chosen_contracts", [])
	for hit: Dictionary in disasters:
		var narrative: String = str(hit.get("narrative", ""))
		var disaster_type: String = hit.get("type", "")
		var was_covered: bool = bool(hit.get("was_covered", false))
		var dis: Dictionary = Globals.disasters.get_disaster(disaster_type)
		var covering_contracts: Array = dis.get("covering_contracts", [])
		var covering_set: Dictionary = {}
		for ct in covering_contracts:
			covering_set[ct] = true
		var contract_labels: Array = []
		for ct in covering_contracts:
			var c: Dictionary = Globals.contracts.get_by_type(ct)
			contract_labels.append(c.get("icon", "") + " " + c.get("label", ct))
		if was_covered:
			var player_contracts: Array[Variant] = []
			for ct in chosen_contracts:
				if covering_set.has(ct):
					var c: Dictionary = Globals.contracts.get_by_type(ct)
					player_contracts.append(c.get("icon", "") + " " + c.get("label", ct))
			var contract_str: String = ", ".join(player_contracts) if player_contracts.size() > 0 else "?"
			result.append({
				"expression": "explain",
				"text": "✅ Couvert par " + contract_str + " : " + narrative,
			})
		else:
			var contract_str: String = ", ".join(contract_labels) if contract_labels.size() > 0 else "?"
			result.append({
				"expression": "explain",
				"text": "❌ Non couvert (contrat utile : " + contract_str + ") : " + narrative,
			})

	return result

func _on_story_complete() -> void:
	var has_next: bool = Globals.story_engine.next_chapitre()
	if has_next:
		get_tree().change_scene_to_file(NEXT_CHAPITRE_SCENE)
	else:
		get_tree().change_scene_to_file(ANALYSIS_SCENE)
