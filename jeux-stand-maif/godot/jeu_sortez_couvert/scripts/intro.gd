extends "res://jeu_sortez_couvert/scripts/story_scene.gd"

const NEXT_SCENE := "res://jeu_sortez_couvert/scenes/chapitre_intro.tscn"

const INTRO_LINES: Array = [
	{"text": "Bienvenue chez MAIF ! Je suis Assurix le Barbu, votre conseiller, ici pour vous guider.", "expression": "souriant"},
	{"text": "Au cours de 6 chapitres, vous allez vivre des situations de la vraie vie.", "expression": "normal"},
	{"text": "Chaque chapitre vous présente des risques du quotidien.", "expression": "normal"},
	{"text": "Votre mission : choisir les contrats d'assurance les plus adaptés avant que le sinistre survienne !", "expression": "souriant"},
	{"text": "Prêt à devenir un expert MAIF ? Allons-y !", "expression": "fier"},
]

func _ready() -> void:
	super._ready()
	var lines: Array = INTRO_LINES.duplicate(true)
	if Globals.story_engine.player_name.strip_edges() != "":
		lines[0]["text"] = (
			"Bienvenue chez MAIF, " + Globals.story_engine.player_name
			+ " ! Je suis Assurix le Barbu, votre conseiller, ici pour vous guider."
		)
	setup_story("Apprenez à vous protéger avec les assurances MAIF", lines)

func _on_story_complete() -> void:
	get_tree().change_scene_to_file(NEXT_SCENE)
