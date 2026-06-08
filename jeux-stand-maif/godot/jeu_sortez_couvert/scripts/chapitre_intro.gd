extends "res://jeu_sortez_couvert/scripts/story_scene.gd"

const NEXT_SCENE := "res://jeu_sortez_couvert/scenes/contract_selection.tscn"

func _ready() -> void:
	super._ready()
	var chapitre: Dictionary = Globals.chapitres.get_chapitre(Globals.story_engine.current_chapitre)
	var titre := "Chapitre %d / %d — %s  %s" % [
		Globals.story_engine.pool_index + 1,
		Globals.story_engine.chapitre_pool.size(),
		chapitre.get("emoji", ""),
		chapitre.get("titre", ""),
	]
	var lines: Array = []
	var contexte: String = String(chapitre.get("contexte", "")).strip_edges()
	if not contexte.is_empty():
		lines.append({"text": contexte, "expression": "explain"})
	for line: Dictionary in chapitre.get("intro", []):
		lines.append(line)
	setup_story(titre.strip_edges(), lines)

func _on_story_complete() -> void:
	get_tree().change_scene_to_file(NEXT_SCENE)
