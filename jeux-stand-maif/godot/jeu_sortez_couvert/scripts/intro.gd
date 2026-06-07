extends "res://jeu_sortez_couvert/scripts/story_scene.gd"

const NEXT_SCENE := "res://jeu_sortez_couvert/scenes/chapitre_intro.tscn"

const INTRO_LINES: Array = [
	{"text": "Bienvenue chez MAIF ! Je suis Assurix le Barbu, votre conseiller, ici pour vous guider.", "expression": "souriant"},
	{"text": "Au cours de 6 chapitres, vous allez vivre des situations de la vraie vie, avec leurs sinistres possibles.", "expression": "normal"},
	{"text": "Votre mission : choisir le ou les contrats qui couvrent le mieux ces risques, au moindre coût.", "expression": "normal"},
	{"text": "Règle d'or : [color=#5dd66b]+1 point[/color] par bon contrat choisi. Mais [color=#ff7373]-1 point[/color] par contrat inutile sélectionné !", "expression": "normal"},
	{"text": "Si vous avez la moitié ou plus de mauvaises réponses, le chapitre tombe à [color=#ff9b42]0 point[/color] — pas de score négatif, rassurez-vous.", "expression": "souriant"},
	{"text": "Un doute ? Vous pouvez demander un indice... mais ça coûte [color=#ff9b42]-0.5 point[/color] par indice utilisé. À utiliser avec parcimonie !", "expression": "inquiet"},
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
	setup_story("Apprenez à vous protéger avec la MAIF", lines)

func _on_story_complete() -> void:
	get_tree().change_scene_to_file(NEXT_SCENE)
