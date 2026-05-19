# Centralise le layout des scènes story (marges, tailles, etc.)
extends Node

class_name StorySceneLayout

# Étend un Sprite2D pour couvrir tout le viewport (effet "cover" CSS).
# Utilisé sur les Background des scènes story.
# `offset` décale le centrage en pixels viewport (clamp pour ne jamais exposer du vide).
# `zoom` (>= 1.0) zoome au-delà du cover, ce qui permet des offsets plus larges sans trou.
static func cover_viewport(sprite: Sprite2D, offset: Vector2 = Vector2.ZERO, zoom: float = 1.0) -> void:
	if not sprite or not sprite.texture:
		return
	var screen_size: Vector2 = sprite.get_viewport_rect().size
	var tex_size: Vector2 = Vector2(sprite.texture.get_width(), sprite.texture.get_height())
	var scale_factor: float = max(screen_size.x / tex_size.x, screen_size.y / tex_size.y) * maxf(zoom, 1.0)
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.centered = true
	var scaled_size: Vector2 = tex_size * scale_factor
	var max_offset: Vector2 = Vector2(
		maxf(0.0, (scaled_size.x - screen_size.x) / 2.0),
		maxf(0.0, (scaled_size.y - screen_size.y) / 2.0)
	)
	var clamped: Vector2 = offset.clamp(-max_offset, max_offset)
	sprite.position = screen_size / 2 + clamped

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
			"margin_left": 60, "margin_right": 60, "margin_top": 24, "margin_bottom": 24,
			"separation": 10,
			"conseiller_min": Vector2(0, 140), "conseiller_flags": 3,
			"dialogue_min": Vector2(0, 130)
		},
		"result": {
			"margin_left": 60, "margin_right": 60, "margin_top": 24, "margin_bottom": 24,
			"separation": 10,
			"conseiller_min": Vector2(0, 140), "conseiller_flags": 3,
			"dialogue_min": Vector2(0, 130)
		},
		"intro": {
			"margin_left": 60, "margin_right": 60, "margin_top": 30, "margin_bottom": 30,
			"separation": 16,
			"conseiller_min": Vector2(0, 150), "conseiller_flags": 3,
			"dialogue_min": Vector2(0, 130)
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

	# Styles centralisés pour les nodes communs
	var style_defs: Dictionary[Variant, Variant] = {
		"HeaderLabel": {"font_size": 46, "font_color": Color(1, 1, 1, 1), "align": 1, "outline_size": 6, "outline_color": Color(0, 0, 0, 0.85)},
		"SubtitleLabel": {"font_size": 18, "font_color": Color(0.95, 0.97, 1, 1), "align": 1, "outline_size": 3, "outline_color": Color(0, 0, 0, 0.8)},
		"ScoreLabel": {"font_size": 26, "align": 2},
		"VerdictLabel": {"font_size": 18, "font_color": Color(0.9, 0.9, 0.9, 1), "align": 1},
		"ChapitreNumLabel": {"font_size": 13, "font_color": Color(0.5, 0.65, 0.85, 1)},
		"TitreLabel": {"font_size": 30, "font_color": Color(0.27, 0.67, 1, 1)},
		"ContexteLabel": {"font_size": 15, "font_color": Color(0.75, 0.82, 0.92, 1)},
	}
	if vbox:
		for node_name in style_defs.keys():
			var n: Node = vbox.find_child(String(node_name), true, false)
			if n:
				var def = style_defs[node_name]
				if def.has("font_size"):
					n.add_theme_font_size_override("font_size", def["font_size"])
				if def.has("font_color"):
					n.add_theme_color_override("font_color", def["font_color"])
				if def.has("outline_color"):
					n.add_theme_color_override("font_outline_color", def["outline_color"])
				if def.has("outline_size"):
					n.add_theme_constant_override("outline_size", def["outline_size"])
				if def.has("align") and n.has_method("set_horizontal_alignment"):
					n.set_horizontal_alignment(def["align"])
