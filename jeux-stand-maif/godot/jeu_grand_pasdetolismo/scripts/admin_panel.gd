extends Control

const PARAMS: Array = [
	{"section": "Economie",  "key": "starting_gold",        "label": "Or de depart",            "type": "int",   "min": 100.0,  "max": 1000.0,  "step": 5.0,    "suffix": "or"},
	{"section": "Economie",  "key": "race_duration",        "label": "Duree d'une course",      "type": "float", "min": 60.0,   "max": 600.0,   "step": 5.0,    "suffix": "s"},
	{"section": "Vitesse",   "key": "speed_top",            "label": "Vitesse pour bonus max",  "type": "float", "min": 5.0,    "max": 60.0,    "step": 1.0,    "suffix": ""},
	{"section": "Vitesse",   "key": "speed_multiplier_max", "label": "Multiplicateur de score max", "type": "float", "min": 1.0, "max": 10.0,    "step": 0.1,    "suffix": "x"},
	{"section": "Impacts",   "key": "impact_cost_factor",   "label": "Coût d'impact par vitesse","type": "float", "min": 0.5,    "max": 20.0,    "step": 0.5,    "suffix": ""},
	{"section": "Impacts",   "key": "impact_cost_min",      "label": "Coût minimum par impact", "type": "float", "min": 0.0,    "max": 100.0,   "step": 1.0,    "suffix": "or"},
	{"section": "Impacts",   "key": "impact_cost_max",      "label": "Coût maximum par impact", "type": "float", "min": 5.0,    "max": 200.0,   "step": 1.0,    "suffix": "or"},
	{"section": "Impacts",   "key": "impact_cooldown_ms",   "label": "Délai mini entre impacts","type": "int",   "min": 50.0,   "max": 2000.0,  "step": 50.0,   "suffix": "ms"},
	{"section": "PvP",       "key": "stun_duration_ms",     "label": "Durée d'étourdissement",  "type": "int",   "min": 100.0,  "max": 5000.0,  "step": 100.0,  "suffix": "ms"},
	{"section": "PvP",       "key": "pvp_rebound_force",    "label": "Force du rebond",         "type": "float", "min": 500.0,  "max": 30000.0, "step": 500.0,  "suffix": ""},
	{"section": "PvP",       "key": "pvp_side_threshold",   "label": "Tolérance angle PvP",     "type": "float", "min": 0.05,   "max": 2.0,     "step": 0.05,   "suffix": ""},
	{"section": "PvP",       "key": "pvp_cooldown_ms",      "label": "Délai mini entre coups PvP","type": "int", "min": 50.0,   "max": 2000.0,  "step": 50.0,   "suffix": "ms"},
	{"section": "Glisse",    "key": "drift_threshold",      "label": "Sensibilité du drift",    "type": "float", "min": 0.0,    "max": 2.0,     "step": 0.05,   "suffix": ""},
	{"section": "Snipe à pleine vitesse", "key": "no_stun_speed_ratio",   "label": "Vitesse mini (% du top)", "type": "float", "min": 0.3,    "max": 1.0,     "step": 0.05,   "suffix": ""},
	{"section": "Snipe à pleine vitesse", "key": "no_stun_gold_reward",   "label": "Bonus or par snipe",       "type": "int",   "min": 0.0,    "max": 50.0,    "step": 1.0,    "suffix": "or"},
	{"section": "Snipe à pleine vitesse", "key": "no_stun_speed_penalty", "label": "Vitesse gardée (0-1)",     "type": "float", "min": 0.1,    "max": 1.0,     "step": 0.05,   "suffix": ""},
]

var _spinboxes: Dictionary = {}

@onready var sections_container: VBoxContainer = $Center/Panel/Margin/VBox/Scroll/Sections
@onready var btn_apply: Button = $Center/Panel/Margin/VBox/Footer/BtnApply
@onready var btn_reset: Button = $Center/Panel/Margin/VBox/Footer/BtnReset
@onready var btn_cancel: Button = $Center/Panel/Margin/VBox/Footer/BtnCancel
@onready var status_label: Label = $Center/Panel/Margin/VBox/Footer/Status

func _ready() -> void:
	btn_apply.pressed.connect(_on_apply)
	btn_reset.pressed.connect(_on_reset)
	btn_cancel.pressed.connect(_on_cancel)
	_build_ui()

func _build_ui() -> void:
	for child in sections_container.get_children():
		child.queue_free()
	_spinboxes.clear()
	var current_section: String = ""
	for p in PARAMS:
		var section_name: String = String(p["section"])
		if section_name != current_section:
			current_section = section_name
			sections_container.add_child(_section_header(section_name))
		sections_container.add_child(_param_row(p))

func _section_header(section_name: String) -> Control:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	var l := Label.new()
	l.text = section_name.to_upper()
	l.add_theme_font_size_override("font_size", 18)
	l.add_theme_color_override("font_color", Color(0.62, 0.78, 1, 1))
	v.add_child(l)
	var sep := HSeparator.new()
	v.add_child(sep)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	v.add_child(spacer)
	return v

func _param_row(p: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var label := Label.new()
	label.text = String(p["label"])
	label.custom_minimum_size = Vector2(320, 0)
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0))
	row.add_child(label)

	var spin := SpinBox.new()
	spin.min_value = float(p["min"])
	spin.max_value = float(p["max"])
	spin.step = float(p["step"])
	spin.custom_minimum_size = Vector2(160, 36)
	spin.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if String(p["type"]) == "int":
		spin.rounded = true
	spin.value = float(GameBalance.get(p["key"]))
	row.add_child(spin)
	_spinboxes[p["key"]] = spin

	var suffix: String = String(p.get("suffix", ""))
	if suffix != "":
		var sfx := Label.new()
		sfx.text = suffix
		sfx.custom_minimum_size = Vector2(40, 0)
		sfx.add_theme_color_override("font_color", Color(0.62, 0.72, 0.88))
		row.add_child(sfx)

	return row

func _on_apply() -> void:
	for p in PARAMS:
		var key: String = String(p["key"])
		var sb: SpinBox = _spinboxes[key]
		if String(p["type"]) == "int":
			GameBalance.set(key, int(sb.value))
		else:
			GameBalance.set(key, float(sb.value))
	GameBalance.save_to_file()
	status_label.text = "✅ Enregistré"
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func _on_reset() -> void:
	GameBalance.reset_to_defaults()
	for p in PARAMS:
		var key: String = String(p["key"])
		var sb: SpinBox = _spinboxes[key]
		sb.value = float(GameBalance.get(key))
	status_label.text = "↺ Valeurs par defaut chargees (pas encore enregistre)"

func _on_cancel() -> void:
	GameBalance.reset_to_defaults()
	GameBalance.load_from_file()
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
