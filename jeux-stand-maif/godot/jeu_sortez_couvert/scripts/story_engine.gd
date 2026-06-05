extends Node
class_name StoryEngineCore

# Cache des autoloads (StoryEngine est lui-même un autoload, donc il ne peut
# pas passer par Globals — il faut un cache local pour éviter les get_node répétés).
@onready var _chapitres: ChapitresDB = get_node("/root/Chapitres")
@onready var _disasters: DisastersDB = get_node("/root/Disasters")
@onready var _contracts: ContractsDB = get_node("/root/Contracts")

# ─── State ────────────────────────────────────────────────────────────────────

var current_chapitre: int = 0
var total_score: int = 0
var answers: Array = []
var hints_used_this_chapitre: int = 0
var selected_contracts: Array = []
var is_complete: bool = false
var player_name: String = ""
var player_email: String = ""

# ─── Reset ────────────────────────────────────────────────────────────────────

func reset() -> void:
	current_chapitre = 0
	total_score = 0
	answers = []
	hints_used_this_chapitre = 0
	selected_contracts = []
	is_complete = false

# ─── Quiz actions ─────────────────────────────────────────────────────────────

## Toggle un contrat. Retourne true si ajouté, false si retiré.
func toggle_contract(type: String) -> bool:
	var idx := selected_contracts.find(type)
	if idx == -1:
		selected_contracts.append(type)
		return true
	else:
		selected_contracts.remove_at(idx)
		return false

func is_selected(type: String) -> bool:
	return selected_contracts.has(type)

## Utilise un indice (max 2 par chapitre). Retourne le niveau (1 ou 2).
func use_hint() -> int:
	if hints_used_this_chapitre < 2:
		hints_used_this_chapitre += 1
	return hints_used_this_chapitre

## Retourne tous les indices déjà débloqués (cumulés, séparés par retour ligne).
func get_hint_text() -> String:
	var chapitre: Dictionary = _chapitres.get_chapitre(current_chapitre)
	var lines: Array = []

	if hints_used_this_chapitre >= 1:
		var names: Array = []
		for d: Dictionary in chapitre["disasters"]:
			var dis: Dictionary = _disasters.get_disaster(d["type"])
			names.append(dis["icon"] + " " + dis["label"])
		lines.append("Risques de ce chapitre : " + ", ".join(names))

	if hints_used_this_chapitre >= 2:
		var contract_set: Dictionary = {}
		for d: Dictionary in chapitre["disasters"]:
			var dis: Dictionary = _disasters.get_disaster(d["type"])
			for ct: String in dis["covering_contracts"]:
				contract_set[ct] = true
		var labels: Array = []
		for ct: String in contract_set.keys():
			var c: Dictionary = _contracts.get_by_type(ct)
			labels.append(c["icon"] + " " + c["label"])
		lines.append("Contrats utiles : " + ", ".join(labels))

	return "\n".join(lines)

# ─── Résolution du chapitre ───────────────────────────────────────────────────

## Port direct de StoryEngine.ts:resolveCurrentChapitre()
## Formule : baseScore = max(0, round(correctCount * 3 / totalNeeded) - wrongCount)
##           scoreEarned = max(0, baseScore - hintsUsed)
func resolve_current_chapitre() -> Dictionary:
	var chapitre: Dictionary = _chapitres.get_chapitre(current_chapitre)
	var chosen: Array = selected_contracts.duplicate()
	var correct_contracts: Array = chapitre["recommended_contracts"]
	var total_needed: int = correct_contracts.size()

	var correct_count: int = 0
	for c: String in chosen:
		if correct_contracts.has(c):
			correct_count += 1

	var wrong_count: int = 0
	for c: String in chosen:
		if not correct_contracts.has(c):
			wrong_count += 1

	var base_score: int = max(0, roundi(float(correct_count) * 3.0 / float(total_needed)) - wrong_count)
	var score_earned: int = max(0, base_score - hints_used_this_chapitre)
	var is_correct: bool = score_earned > 0

	var disaster_hits: Array = []
	for chap_disaster: Dictionary in chapitre["disasters"]:
		if randf() > chap_disaster["probability"]:
			continue
		var dis: Dictionary = _disasters.get_disaster(chap_disaster["type"])
		var was_covered: bool = false
		for ct: String in chosen:
			if dis["covering_contracts"].has(ct):
				was_covered = true
				break
		disaster_hits.append({
			"type": chap_disaster["type"],
			"was_covered": was_covered,
			"narrative": chap_disaster["narrative"],
		})

	var answer: Dictionary = {
		"chapitre_id": current_chapitre,
		"chosen_contracts": chosen,
		"correct_contracts": correct_contracts,
		"correct_count": correct_count,
		"wrong_count": wrong_count,
		"is_correct": is_correct,
		"hints_used": hints_used_this_chapitre,
		"score_earned": score_earned,
		"disaster_hits": disaster_hits,
	}

	answers.append(answer)
	total_score += score_earned
	return answer

func next_chapitre() -> bool:
	var next_id: int = current_chapitre + 1
	if next_id >= _chapitres.count():
		is_complete = true
		return false
	current_chapitre = next_id
	hints_used_this_chapitre = 0
	selected_contracts = []
	return true

# ─── Analyse finale ───────────────────────────────────────────────────────────

## Port direct de StoryEngine.ts:getAnalysis()
## Seuils : ≥85% Expert MAIF, ≥65% Bon élève, ≥40% À améliorer, <40% Débutant
func get_analysis() -> Dictionary:
	var max_score: int = _chapitres.count() * 3
	var pct: float = float(total_score) / float(max_score)

	var label: String
	if pct >= 0.85:
		label = "Expert MAIF"
	elif pct >= 0.65:
		label = "Bon eleve"
	elif pct >= 0.4:
		label = "A ameliorer"
	else:
		label = "Debutant"

	var best_answer: Dictionary = {}
	var worst_answer: Dictionary = {}
	for a: Dictionary in answers:
		if best_answer.is_empty() and a["is_correct"] and a["hints_used"] == 0 and a["wrong_count"] == 0:
			best_answer = a
		if worst_answer.is_empty() and not a["is_correct"]:
			worst_answer = a

	var best_choice: String
	if not best_answer.is_empty():
		var labels: Array = []
		for ct: String in best_answer["chosen_contracts"]:
			var c: Dictionary = _contracts.get_by_type(ct)
			labels.append(c.get("label", ct))
		best_choice = "Ch. " + str(best_answer["chapitre_id"] + 1) + " — " + ", ".join(labels)
	else:
		best_choice = "Vous avez toujours eu besoin d'indices !"

	var worst_choice: String
	if not worst_answer.is_empty():
		var ct: String = worst_answer["correct_contracts"][0]
		var c: Dictionary = _contracts.get_by_type(ct)
		worst_choice = "Ch. " + str(worst_answer["chapitre_id"] + 1) + " — le bon contrat etait " + c.get("label", ct)
	else:
		worst_choice = "Aucune erreur ! Gestion parfaite."

	return {
		"total_score": total_score,
		"max_score": max_score,
		"label": label,
		"answers": answers,
		"best_choice": best_choice,
		"worst_choice": worst_choice,
	}
