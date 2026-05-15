extends Node3D

const VEHICLE_SCENE: PackedScene = preload("res://jeu_grand_pasdetolismo/scenes/vehicle.tscn")
const HUD_SCENE: PackedScene = preload("res://jeu_grand_pasdetolismo/scenes/hud_player.tscn")
const BOOST_ZONE_SCENE: PackedScene = preload("res://jeu_grand_pasdetolismo/scenes/boost_zone.tscn")
const CAMERA_FOLLOW_SCRIPT: Script = preload("res://jeu_grand_pasdetolismo/scripts/camera_follow.gd")

const SPAWN_POSITIONS: Array = [
	Vector3(5.5, 0.0, 5.0),
	Vector3(3.5, 0.0, 5.0),
]

const BOOST_POSITIONS: Array = [
	Vector3(-10.0, 0.0, 5.0),
	Vector3(5.0, 0.0, -10.0),
]

@onready var vehicles_root: Node3D = $Vehicles
@onready var ui: CanvasLayer = $UI

var vehicles: Array = []
var huds: Array = []
var _time_remaining: float = 90.0
var _finished: bool = false
var _audio_listener: AudioListener3D = null

func _ready() -> void:
	if RaceSession.players.is_empty():
		RaceSession.configure_solo("yellow", [])
	_time_remaining = GameBalance.race_duration
	if RaceSession.mode == "solo":
		_setup_solo()
	else:
		_setup_multi()
	_spawn_boost_zones()

func _spawn_boost_zones() -> void:
	for pos in BOOST_POSITIONS:
		var b: Node3D = BOOST_ZONE_SCENE.instantiate()
		add_child(b)
		b.global_position = pos

func _process(delta: float) -> void:
	if _finished:
		return
	_time_remaining = max(0.0, _time_remaining - delta)
	_update_audio_listener()
	if _time_remaining <= 0.0:
		_finish_race()
		return
	# Si tous les joueurs sont morts, on termine immediatement
	var alive: int = 0
	for v in vehicles:
		if v is Vehicle and not v.out:
			alive += 1
	if alive == 0:
		_finish_race()

func _update_audio_listener() -> void:
	if _audio_listener == null or vehicles.is_empty():
		return
	var sum: Vector3 = Vector3.ZERO
	var count: int = 0
	for v in vehicles:
		if v is Vehicle and v.vehicle_model != null:
			sum += v.vehicle_model.global_position
			count += 1
	if count > 0:
		_audio_listener.global_position = (sum / count) + Vector3(0, 3, 0)

func get_time_remaining() -> float:
	return _time_remaining

func _spawn_vehicle(player_id: int, color: String, scheme: String, pad_device: int, spawn_pos: Vector3, gold_start: int, contracts: Array) -> Vehicle:
	var v: Vehicle = VEHICLE_SCENE.instantiate() as Vehicle
	v.player_id = player_id
	v.vehicle_color = color
	v.control_scheme = scheme
	v.pad_device = pad_device
	v.starting_gold = gold_start
	v.contracts = contracts.duplicate()
	v.transform = Transform3D(Basis.IDENTITY, spawn_pos)
	v.eliminated.connect(_on_player_eliminated)
	vehicles_root.add_child(v)
	return v

func _make_camera(target: Vehicle) -> Camera3D:
	var cam: Camera3D = Camera3D.new()
	cam.set_script(CAMERA_FOLLOW_SCRIPT)
	cam.set("target", target)
	return cam

func _make_hud(target: Vehicle) -> Control:
	var hud: Control = HUD_SCENE.instantiate() as Control
	hud.setup(target, self)
	return hud

func _setup_solo() -> void:
	var p: Dictionary = RaceSession.players[0]
	var v: Vehicle = _spawn_vehicle(
		0,
		p["color"],
		p.get("control_scheme", "zqsd"),
		int(p.get("pad_device", -1)),
		SPAWN_POSITIONS[0],
		int(p.get("gold_start", 100)),
		p.get("contracts", []),
	)
	vehicles.append(v)
	var cam: Camera3D = _make_camera(v)
	cam.current = true
	vehicles_root.add_child(cam)
	var hud: Control = _make_hud(v)
	ui.add_child(hud)
	huds.append(hud)

func _setup_audio_listener() -> void:
	# En multi, les Camera3D vivent dans les SubViewports, donc le main viewport
	# n'a aucun listener 3D actif → silence. On en place un dans le World partage.
	_audio_listener = AudioListener3D.new()
	add_child(_audio_listener)
	_audio_listener.make_current()

func _setup_multi() -> void:
	_setup_audio_listener()
	var p1: Dictionary = RaceSession.players[0]
	var p2: Dictionary = RaceSession.players[1]
	var v1: Vehicle = _spawn_vehicle(
		0, p1["color"], p1.get("control_scheme", "zqsd"), int(p1.get("pad_device", -1)),
		SPAWN_POSITIONS[0], int(p1.get("gold_start", 100)), p1.get("contracts", []),
	)
	var v2: Vehicle = _spawn_vehicle(
		1, p2["color"], p2.get("control_scheme", "arrows"), int(p2.get("pad_device", -1)),
		SPAWN_POSITIONS[1], int(p2.get("gold_start", 100)), p2.get("contracts", []),
	)
	vehicles.append(v1)
	vehicles.append(v2)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 2)
	ui.add_child(hbox)

	var svc1: SubViewportContainer = _build_split_viewport(v1)
	var svc2: SubViewportContainer = _build_split_viewport(v2)
	hbox.add_child(svc1)
	hbox.add_child(svc2)

func _build_split_viewport(target: Vehicle) -> SubViewportContainer:
	var svc: SubViewportContainer = SubViewportContainer.new()
	svc.stretch = true
	svc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	svc.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var sv: SubViewport = SubViewport.new()
	sv.size = Vector2i(640, 720)
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sv.world_3d = get_viewport().world_3d
	sv.handle_input_locally = false
	svc.add_child(sv)

	var cam: Camera3D = _make_camera(target)
	cam.current = true
	sv.add_child(cam)

	# HUD overlay specific to this viewport (rendered inside the SubViewport)
	var hud_layer: CanvasLayer = CanvasLayer.new()
	sv.add_child(hud_layer)
	var hud: Control = _make_hud(target)
	hud_layer.add_child(hud)
	huds.append(hud)

	return svc

func _on_player_eliminated(pid: int) -> void:
	# La fin de partie sera detectee dans _process si tous morts.
	# Pour l'instant on log juste l'evenement; le HUD du joueur affiche son overlay "hors-service".
	pass

func _finish_race() -> void:
	if _finished:
		return
	_finished = true
	RaceSession.last_results.clear()
	for v in vehicles:
		if v is Vehicle:
			RaceSession.record_result(v.player_id, v.distance, v.score, v.gold, not v.out)
	get_tree().change_scene_to_file("res://jeu_grand_pasdetolismo/scenes/game_over.tscn")
