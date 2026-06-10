extends "res://jeu_sortez_couvert/scripts/story_scene.gd"

const NEXT_CHAPITRE_SCENE := "res://jeu_sortez_couvert/scenes/chapitre_intro.tscn"
const ANALYSIS_SCENE := "res://jeu_sortez_couvert/scenes/analysis.tscn"
const MAX_SCORE_PER_CHAPITRE: int = 3

@onready var _chapitre_num_label: Label = $ChapitreNumLabel
@onready var _score_label: Label = $ScoreLabel

func _ready() -> void:
	super._ready()

	var answer: Dictionary = Globals.story_engine.answers.back()
	var score_earned: int = int(answer.get("score_earned", 0))

	_chapitre_num_label.text = "Chapitre %d / %d" % [Globals.story_engine.pool_index + 1, Globals.story_engine.chapitre_pool.size()]
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
	result.append(_build_verdict(answer))
	result.append_array(_build_choice_review(answer))
	result.append_array(_build_disaster_lines(answer))
	return result

# ── Verdict d'ouverture ───────────────────────────────────────────────────────
func _build_verdict(answer: Dictionary) -> Dictionary:
	var score: int = int(answer.get("score_earned", 0))
	if score >= 3:
		return {
			"expression": "hyper-good",
			"text": "Incroyable ! Tout est couvert au juste prix. Vous avez joué comme un véritable chef de clan.",
		}
	if score >= 2:
		return {
			"expression": "ok",
			"text": "Bien joué ! La majorité des risques est couverte. Reprenons vos choix ensemble.",
		}
	if score >= 1:
		return {
			"expression": "explain",
			"text": "Vous avez couvert une partie des risques, mais ce n'est pas optimal. Voyons ce qui était utile... et ce qui ne l'était pas.",
		}
	if _is_mostly_uncovered(answer):
		return {
			"expression": "wrong",
			"text": "Aïe... trop de risques ne sont pas couverts. Reprenons vos choix pour comprendre pourquoi.",
		}
	return {
		"expression": "wrong",
		"text": "C'est encore fragile : trop de contrats inutiles ou pas assez de couverture. On corrige ça ensemble.",
	}

# ── Revue des choix : valider / invalider chaque contrat sélectionné ───────────
# Distingue les bons choix, les contrats inutiles ici, et ceux qui manquaient.
func _build_choice_review(answer: Dictionary) -> Array:
	var lines: Array = []
	var chosen: Array = answer.get("chosen_contracts", [])
	var recommended: Array = answer.get("correct_contracts", [])
	var rec_set: Dictionary = {}
	for ct in recommended:
		rec_set[ct] = true
	var chosen_set: Dictionary = {}
	for ct in chosen:
		chosen_set[ct] = true

	var good: Array = []
	var useless: Array = []
	for ct in chosen:
		if rec_set.has(ct):
			good.append(ct)
		else:
			useless.append(ct)

	# Contrats pertinents bien choisis → regroupés en une ligne.
	if not good.is_empty():
		var tags: Array = []
		for ct in good:
			tags.append(_contract_tag(ct))
		lines.append({
			"expression": "ok",
			"text": "[color=#5dd66b]✅ Bons choix : %s.[/color] Ces contrats correspondent bien aux risques de ce chapitre." % ", ".join(tags),
		})

	# Contrats inutiles ici → une ligne chacun, avec un exemple de leur vraie utilité.
	for ct in useless:
		lines.append({
			"expression": "wrong",
			"text": "[color=#ff7373]❌ %s : inutile ici.[/color] %s Cocher un contrat de trop fait baisser votre score." % [
				_contract_tag(ct), _contract_usage_example(ct),
			],
		})

	# Contrats recommandés non cochés → ce qui restait à couvrir, et pourquoi.
	for ct in recommended:
		if not chosen_set.has(ct):
			lines.append({
				"expression": "explain",
				"text": "[color=#ff9b42]➕ Il manquait %s.[/color] %s" % [
					_contract_tag(ct), _contract_usage_example(ct),
				],
			})

	return lines

# ── Détail par sinistre survenu : pourquoi c'est couvert ou non + l'exemple ────
func _build_disaster_lines(answer: Dictionary) -> Array:
	var lines: Array = []
	var chosen_contracts: Array = answer.get("chosen_contracts", [])
	var disasters: Array = answer.get("disaster_hits", [])
	for hit: Dictionary in disasters:
		var narrative: String = str(hit.get("narrative", ""))
		var disaster_type: String = str(hit.get("type", ""))
		var was_covered: bool = bool(hit.get("was_covered", false))
		var dis: Dictionary = Globals.disasters.get_disaster(disaster_type)
		var covering_contracts: Array = dis.get("covering_contracts", [])
		var covering_set: Dictionary = {}
		for ct in covering_contracts:
			covering_set[ct] = true
		if was_covered:
			var player_contracts: Array = []
			for ct in chosen_contracts:
				if covering_set.has(ct):
					player_contracts.append(_contract_tag(ct))
			var contract_str: String = ", ".join(player_contracts) if not player_contracts.is_empty() else "?"
			lines.append({
				"expression": "explain",
				"text": "[b]✅ %s[/b]\n%s : les frais sont pris en charge." % [narrative, contract_str],
			})
		else:
			var contract_labels: Array = []
			for ct in covering_contracts:
				contract_labels.append(_contract_tag(ct))
			var contract_str: String = ", ".join(contract_labels) if not contract_labels.is_empty() else "?"
			lines.append({
				"expression": "wrong",
				"text": "[b]❌ %s[/b]\nNon couvert : il fallait %s. Sans lui, tout reste à votre charge." % [narrative, contract_str],
			})
	return lines

# ── Helpers ───────────────────────────────────────────────────────────────────
func _contract_tag(type: String) -> String:
	var c: Dictionary = Globals.contracts.get_by_type(type)
	return "%s %s" % [c.get("icon", ""), c.get("label", type)]

# Phrase courte décrivant l'utilité réelle d'un contrat, via les sinistres qu'il couvre.
func _contract_usage_example(type: String) -> String:
	var c: Dictionary = Globals.contracts.get_by_type(type)
	var covers: Array = c.get("covers", [])
	var labels: Array = []
	for d in covers:
		var dis: Dictionary = Globals.disasters.get_disaster(d)
		if dis.is_empty():
			continue
		labels.append("%s %s" % [dis.get("icon", ""), String(dis.get("label", d)).to_lower()])
	if labels.is_empty():
		return String(c.get("description", ""))
	return "Il protège surtout contre %s." % _join_natural(labels)

# Jointure naturelle : "a, b et c".
func _join_natural(items: Array) -> String:
	if items.is_empty():
		return ""
	if items.size() == 1:
		return String(items[0])
	var head: Array = items.slice(0, items.size() - 1)
	return "%s et %s" % [", ".join(head), String(items[items.size() - 1])]

func _on_story_complete() -> void:
	var has_next: bool = Globals.story_engine.next_chapitre()
	if has_next:
		get_tree().change_scene_to_file(NEXT_CHAPITRE_SCENE)
	else:
		get_tree().change_scene_to_file(ANALYSIS_SCENE)
