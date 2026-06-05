# Centralise le layout des scènes story (marges, tailles, etc.)
# et applique le style fantasy (Nordvik sur titres, couleurs dorées) aux labels nommés.
extends Node

class_name StorySceneLayout

const FONT_TITLE: FontFile = preload("res://jeu_sortez_couvert/ui/theme/fonts/Nordvik.ttf")

const COLOR_GOLD := Color(1, 0.92, 0.55, 1)
const COLOR_LIGHT_BLUE := Color(0.78, 0.86, 1, 1)
const COLOR_WHITE := Color(0.95, 0.95, 0.97, 1)
const COLOR_OUTLINE := Color(0, 0, 0, 0.85)

static func _on_pause_resume():
	pass

static func _storyscene_pause_input(scene: Node, pause_menu: Node, event):
	if event.is_action_pressed("ui_cancel"):
		pause_menu.show_pause()
		scene.get_viewport().set_input_as_handled()

static func apply(scene: Node, profile: String = "") -> void:
	if profile == "" or profile == null:
		# Détection automatique du profil selon le nom du script ou du noeud racine
		var script_path: String = ""
		if scene.get_script() and scene.get_script().has_method("resource_path"):
			script_path = scene.get_script().resource_path
		var node_name := scene.get_name().to_lower()
		if script_path.find("result") != -1 or node_name.find("result") != -1:
			profile = "result"
		elif script_path.find("intro") != -1 or node_name.find("intro") != -1:
			profile = "intro"
		else:
			profile = "default"

	var margin: Node = scene.get_node_or_null("MarginContainer")
	var vbox: Node = null
	if margin:
		vbox = margin.get_node_or_null("VBoxContainer")
	var conseiller_area: Node = null
	if vbox:
		conseiller_area = vbox.get_node_or_null("ConseillerArea")
	var dialogue_area: Node = null
	if vbox:
		dialogue_area = vbox.get_node_or_null("DialogueArea")

	var profiles: Dictionary = {
		"default": {
			"margin_left": 48, "margin_right": 48, "margin_top": 28, "margin_bottom": 28,
			"separation": 12,
			"conseiller_min": Vector2(0, 160), "conseiller_flags": 3,
			"dialogue_min": Vector2(0, 140)
		},
		"result": {
			"margin_left": 48, "margin_right": 48, "margin_top": 28, "margin_bottom": 28,
			"separation": 12,
			"conseiller_min": Vector2(0, 160), "conseiller_flags": 3,
			"dialogue_min": Vector2(0, 140)
		},
		"intro": {
			"margin_left": 48, "margin_right": 48, "margin_top": 32, "margin_bottom": 16,
			"separation": 12,
			"conseiller_min": Vector2(0, 180), "conseiller_flags": 3,
			"dialogue_min": Vector2(0, 140)
		}
	}
	var p = profiles.get(profile, profiles["default"])
	if margin:
		margin.add_theme_constant_override("margin_left", p["margin_left"])
		margin.add_theme_constant_override("margin_right", p["margin_right"])
		margin.add_theme_constant_override("margin_top", p["margin_top"])
		margin.add_theme_constant_override("margin_bottom", p["margin_bottom"])
	if vbox:
		vbox.add_theme_constant_override("separation", p["separation"])
	if conseiller_area:
		conseiller_area.custom_minimum_size = p["conseiller_min"]
		conseiller_area.size_flags_vertical = p["conseiller_flags"]
	if dialogue_area:
		dialogue_area.custom_minimum_size = p["dialogue_min"]

	# Styles centralisés (fantasy theme) pour les nodes communs nommés.
	# Nordvik + doré + outline sur les titres ; corps en couleur claire / dorée selon le rôle.
	var style_defs: Dictionary[Variant, Variant] = {
		"HeaderLabel": {
			"font": FONT_TITLE, "font_size": 56,
			"font_color": COLOR_GOLD, "outline": true,
			"align": 1
		},
		"SubtitleLabel": {
			"font_size": 22, "font_color": COLOR_LIGHT_BLUE, "align": 1
		},
		"ScoreLabel": {
			"font_size": 36, "font_color": COLOR_GOLD, "outline": true, "align": 2
		},
		"VerdictLabel": {
			"font_size": 24, "font_color": COLOR_WHITE, "align": 1
		},
		"ChapitreNumLabel": {
			"font_size": 18, "font_color": COLOR_LIGHT_BLUE
		},
		"TitreLabel": {
			"font": FONT_TITLE, "font_size": 40,
			"font_color": COLOR_GOLD, "outline": true
		},
		"ContexteLabel": {
			"font_size": 22, "font_color": COLOR_LIGHT_BLUE
		},
	}
	if vbox:
		for node_name in style_defs.keys():
			var n: Node = vbox.find_child(String(node_name), true, false)
			if n:
				var def = style_defs[node_name]
				if def.has("font"):
					n.add_theme_font_override("font", def["font"])
				if def.has("font_size"):
					n.add_theme_font_size_override("font_size", def["font_size"])
				if def.has("font_color"):
					n.add_theme_color_override("font_color", def["font_color"])
				if def.get("outline", false):
					n.add_theme_color_override("font_outline_color", COLOR_OUTLINE)
					n.add_theme_constant_override("outline_size", 4)
				if def.has("align") and n.has_method("set_horizontal_alignment"):
					n.set_horizontal_alignment(def["align"])
