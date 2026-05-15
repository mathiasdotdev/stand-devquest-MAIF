extends Camera3D

@export var target: Node3D
@export var distance: float = 5.5
@export var height: float = 2.6
@export var look_ahead: float = 1.5
@export var position_lerp: float = 6.0
@export var rotation_lerp: float = 8.0

var _initialized: bool = false

func _ready() -> void:
	fov = 65.0
	if target != null:
		_snap_to_target()

func _physics_process(delta: float) -> void:
	if target == null:
		return
	var body: Node3D = target.get_node_or_null("Container") as Node3D
	if body == null:
		body = target
	var basis: Basis = body.global_transform.basis
	var anchor: Vector3 = body.global_position
	var desired_pos: Vector3 = anchor + basis * Vector3(0.0, height, -distance)
	if not _initialized:
		global_position = desired_pos
		_initialized = true
	else:
		global_position = global_position.lerp(desired_pos, clamp(delta * position_lerp, 0.0, 1.0))
	var look_target: Vector3 = anchor + basis * Vector3(0.0, 0.5, look_ahead)
	look_at(look_target, Vector3.UP)

func _snap_to_target() -> void:
	var body: Node3D = target.get_node_or_null("Container") as Node3D
	if body == null:
		body = target
	var basis: Basis = body.global_transform.basis
	var anchor: Vector3 = body.global_position
	global_position = anchor + basis * Vector3(0.0, height, -distance)
	look_at(anchor + basis * Vector3(0.0, 0.5, look_ahead), Vector3.UP)
	_initialized = true
