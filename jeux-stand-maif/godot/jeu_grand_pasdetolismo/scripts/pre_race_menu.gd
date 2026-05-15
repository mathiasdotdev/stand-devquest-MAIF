extends Control

const COLORS: Array = ["green", "orange", "red", "white"]
const COLOR_LABELS: Dictionary = {
	"green":  "Vert",
	"orange": "Orange",
	"red":    "Rouge",
	"white":  "Blanc",
}
const COLOR_RGB: Dictionary = {
	"green":  Color(0.34, 0.78, 0.41),
	"orange": Color(0.98, 0.55, 0.18),
	"red":    Color(0.87, 0.27, 0.27),
	"white":  Color(0.92, 0.92, 0.92),
}

const SCHEMES: Array = ["zqsd", "arrows", "pad"]
const SCHEME_LABELS: Dictionary = {
	"zqsd":   "ZQSD",
	"arrows": "Flèches",
	"pad":    "Manette",
}
const EXCLUSIVE_SCHEMES: Array = ["zqsd", "arrows"]

var mode: String = "solo"
var p1_color: String = ""
var p2_color: String = ""
var p1_contracts: Array = []
var p2_contracts: Array = []
var p1_scheme: String = "zqsd"
var p2_scheme: String = "arrows"

var _needs_pad_assignment: bool = false

@onready var btn_solo: Button = $Center/Panel/Margin/VBox/ModeRow/BtnSolo
@onready var btn_multi: Button = $Center/Panel/Margin/VBox/ModeRow/BtnMulti
@onready var player1_panel: VBoxContainer = $Center/Panel/Margin/VBox/PlayersRow/Player1
@onready var player2_panel: VBoxContainer = $Center/Panel/Margin/VBox/PlayersRow/Player2
@onready var btn_start: Button = $Center/Panel/Margin/VBox/Footer/ButtonsRow/BtnStart
@onready var btn_back: Button = $Center/Panel/Margin/VBox/Footer/ButtonsRow/BtnBack
@onready var hint_label: Label = $Center/Panel/Margin/VBox/Footer/Hint

func _ready() -> void:
	RaceSession.reset()
	btn_solo.pressed.connect(func(): _set_mode("solo"))
	btn_multi.pressed.connect(func(): _set_mode("multi"))
	btn_start.pressed.connect(_on_start_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	_build_player_panel(player1_panel, 1)
	_build_player_panel(player2_panel, 2)
	_set_mode("solo")

func _build_player_panel(panel: VBoxContainer, player_num: int) -> void:
	var title: Label = panel.get_node("Title")
	title.text = "Joueur %d" % player_num

	var color_row: HBoxContainer = panel.get_node("ColorRow")
	for color in COLORS:
		var b := Button.new()
		b.name = "Color_" + color
		b.text = COLOR_LABELS[color]
		b.custom_minimum_size = Vector2(78, 44)
		b.add_theme_color_override("font_color", Color(0.05, 0.05, 0.1))
		_set_button_color(b, color, false)
		b.pressed.connect(func(): _on_color_pressed(player_num, color))
		color_row.add_child(b)

	# Inject control-scheme row right under ColorRow
	var ctrl_label := Label.new()
	ctrl_label.name = "ControlLabel"
	ctrl_label.text = "Controles :"
	ctrl_label.add_theme_font_size_override("font_size", 14)
	ctrl_label.add_theme_color_override("font_color", Color(0.75, 0.85, 1, 1))
	var ctrl_row := HBoxContainer.new()
	ctrl_row.name = "ControlRow"
	ctrl_row.add_theme_constant_override("separation", 6)
	for s in SCHEMES:
		var sb := Button.new()
		sb.name = "Scheme_" + s
		sb.text = SCHEME_LABELS[s]
		sb.custom_minimum_size = Vector2(88, 36)
		sb.add_theme_font_size_override("font_size", 13)
		_set_button_scheme(sb, false)
		sb.pressed.connect(func(): _on_scheme_pressed(player_num, s))
		ctrl_row.add_child(sb)
	# Insert label and row just after ColorRow
	var color_row_idx: int = color_row.get_index()
	panel.add_child(ctrl_label)
	panel.move_child(ctrl_label, color_row_idx + 1)
	panel.add_child(ctrl_row)
	panel.move_child(ctrl_row, color_row_idx + 2)

	var contracts_box: VBoxContainer = panel.get_node("ContractsBox")
	for c in InsuranceContracts.CONTRACTS:
		var cb := Button.new()
		cb.name = "Contract_" + c["id"]
		cb.toggle_mode = true
		cb.text = "%s  %s  —  %d or  (-%d%% reparations)" % [c["icon"], c["label"], c["cost"], int(c["reduction"] * 100)]
		cb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		cb.custom_minimum_size = Vector2(0, 38)
		cb.add_theme_font_size_override("font_size", 15)
		_set_button_contract(cb, false)
		var cid: String = c["id"]
		cb.toggled.connect(func(on: bool):
			_on_contract_toggled(player_num, cid, on)
			_set_button_contract(cb, on)
		)
		contracts_box.add_child(cb)

func _set_button_color(b: Button, color: String, selected: bool) -> void:
	var base: Color = COLOR_RGB[color]
	if selected:
		b.modulate = Color(1, 1, 1, 1)
		b.add_theme_stylebox_override("normal", _solid_box(base))
		b.add_theme_stylebox_override("hover", _solid_box(base))
		b.add_theme_stylebox_override("pressed", _solid_box(base.darkened(0.15)))
	else:
		b.modulate = Color(1, 1, 1, 0.55)
		b.add_theme_stylebox_override("normal", _solid_box(base.darkened(0.4)))
		b.add_theme_stylebox_override("hover", _solid_box(base.darkened(0.25)))
		b.add_theme_stylebox_override("pressed", _solid_box(base.darkened(0.5)))

func _set_button_contract(b: Button, on: bool) -> void:
	var base: Color = Color(0.22, 0.55, 0.32) if on else Color(0.16, 0.20, 0.28)
	b.add_theme_stylebox_override("normal", _solid_box(base))
	b.add_theme_stylebox_override("hover", _solid_box(base.lightened(0.08)))
	b.add_theme_stylebox_override("pressed", _solid_box(base.darkened(0.12)))
	b.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	b.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	b.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))

func _set_button_scheme(b: Button, selected: bool) -> void:
	var base: Color = Color(0.25, 0.42, 0.78) if selected else Color(0.18, 0.22, 0.32)
	b.modulate = Color(1, 1, 1, 1) if selected else Color(1, 1, 1, 0.7)
	b.add_theme_stylebox_override("normal", _solid_box(base))
	b.add_theme_stylebox_override("hover", _solid_box(base.lightened(0.08)))
	b.add_theme_stylebox_override("pressed", _solid_box(base.darkened(0.15)))
	b.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func _solid_box(c: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 6
	s.corner_radius_bottom_right = 6
	return s

func _set_mode(new_mode: String) -> void:
	mode = new_mode
	btn_solo.button_pressed = (mode == "solo")
	btn_multi.button_pressed = (mode == "multi")
	player2_panel.visible = (mode == "multi")
	if mode == "solo":
		p2_color = ""
		p2_contracts = []
	else:
		# Garde-fou : si J1 et J2 ont le meme scheme EXCLUSIF, on bascule J2.
		if p1_scheme == p2_scheme and p1_scheme in EXCLUSIVE_SCHEMES:
			for s in SCHEMES:
				if s != p1_scheme:
					p2_scheme = s
					break
	_refresh_all_buttons()
	_refresh_contracts_availability()
	_refresh_gold_labels()
	_refresh_start_button()

func _refresh_contracts_availability() -> void:
	for player_num in [1, 2]:
		var panel: VBoxContainer = player1_panel if player_num == 1 else player2_panel
		var contracts_box: VBoxContainer = panel.get_node("ContractsBox")
		for c in InsuranceContracts.CONTRACTS:
			var btn: Button = contracts_box.get_node_or_null("Contract_" + c["id"]) as Button
			if btn == null:
				continue
			var available: bool = InsuranceContracts.is_available_in_mode(c, mode)
			btn.visible = available
			if not available and btn.button_pressed:
				btn.set_pressed_no_signal(false)
				_set_button_contract(btn, false)
				if player_num == 1:
					p1_contracts.erase(c["id"])
				else:
					p2_contracts.erase(c["id"])

func _on_color_pressed(player_num: int, color: String) -> void:
	if player_num == 1:
		if mode == "multi" and p2_color == color:
			return
		p1_color = color
	else:
		if p1_color == color:
			return
		p2_color = color
	_refresh_all_buttons()
	_refresh_start_button()

func _on_scheme_pressed(player_num: int, scheme: String) -> void:
	# Les schemas clavier (ZQSD, Fleches) sont exclusifs entre les 2 joueurs.
	# "pad" peut etre choisi par les deux (chaque manette = un device distinct).
	var is_exclusive: bool = scheme in EXCLUSIVE_SCHEMES
	if player_num == 1:
		if mode == "multi" and is_exclusive and p2_scheme == scheme:
			return
		p1_scheme = scheme
	else:
		if is_exclusive and p1_scheme == scheme:
			return
		p2_scheme = scheme
	_refresh_all_buttons()

func _refresh_all_buttons() -> void:
	_refresh_player_buttons(player1_panel, 1)
	if mode == "multi":
		_refresh_player_buttons(player2_panel, 2)

func _refresh_player_buttons(panel: VBoxContainer, player_num: int) -> void:
	var color_row: HBoxContainer = panel.get_node("ColorRow")
	var my_color: String = p1_color if player_num == 1 else p2_color
	var other_color: String = p2_color if player_num == 1 else p1_color
	for color in COLORS:
		var b: Button = color_row.get_node("Color_" + color)
		var taken_by_other: bool = (mode == "multi" and color == other_color and other_color != "")
		b.disabled = taken_by_other
		_set_button_color(b, color, color == my_color)
		if taken_by_other:
			b.modulate = Color(0.4, 0.4, 0.4, 0.4)

	var ctrl_row: HBoxContainer = panel.get_node("ControlRow")
	var my_scheme: String = p1_scheme if player_num == 1 else p2_scheme
	var other_scheme: String = p2_scheme if player_num == 1 else p1_scheme
	for s in SCHEMES:
		var sb: Button = ctrl_row.get_node("Scheme_" + s)
		var is_exclusive: bool = s in EXCLUSIVE_SCHEMES
		var taken: bool = (mode == "multi" and s == other_scheme and is_exclusive)
		sb.disabled = taken
		_set_button_scheme(sb, s == my_scheme)
		if taken:
			sb.modulate = Color(0.4, 0.4, 0.4, 0.4)

func _on_contract_toggled(player_num: int, contract_id: String, on: bool) -> void:
	var target_array: Array = p1_contracts if player_num == 1 else p2_contracts
	if on:
		if contract_id not in target_array:
			target_array.append(contract_id)
	else:
		target_array.erase(contract_id)
	if player_num == 1:
		p1_contracts = target_array
	else:
		p2_contracts = target_array
	_refresh_gold_labels()

func _refresh_gold_labels() -> void:
	var p1_gold: int = GameBalance.starting_gold - InsuranceContracts.total_cost(p1_contracts)
	(player1_panel.get_node("GoldLabel") as Label).text = "Or de depart : %d" % p1_gold
	if mode == "multi":
		var p2_gold: int = GameBalance.starting_gold - InsuranceContracts.total_cost(p2_contracts)
		(player2_panel.get_node("GoldLabel") as Label).text = "Or de depart : %d" % p2_gold

func _refresh_start_button() -> void:
	var ok: bool = p1_color != ""
	if mode == "multi":
		ok = ok and p2_color != "" and p1_color != p2_color
	btn_start.disabled = not ok
	if not ok:
		hint_label.text = "Choisis une couleur pour chaque joueur."
	else:
		hint_label.text = ""

func _on_start_pressed() -> void:
	if mode == "solo":
		RaceSession.configure_solo(p1_color, p1_contracts, p1_scheme)
	else:
		RaceSession.configure_multi(p1_color, p1_contracts, p1_scheme, p2_color, p2_contracts, p2_scheme)
	var needs_pad: bool = false
	for p in RaceSession.players:
		if String(p.get("control_scheme", "")) == "pad":
			needs_pad = true
			break
	if needs_pad:
		get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/pad_assignment.tscn")
	else:
		get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/race.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
