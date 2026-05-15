extends Node3D

@export var boost_impulse: float = 4000.0

const COOLDOWN_MS: int = 1500

@onready var area: Area3D = $Area

var _recent_hits: Dictionary = {}

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	var p: Node = body.get_parent()
	if p == null or not (p is Vehicle):
		return
	var v: Vehicle = p as Vehicle
	if v.out:
		return
	var now: int = Time.get_ticks_msec()
	var vid: int = v.get_instance_id()
	if _recent_hits.has(vid) and now - int(_recent_hits[vid]) < COOLDOWN_MS:
		return
	_recent_hits[vid] = now
	var dir: Vector3 = v.vehicle_model.global_transform.basis.z
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	dir = dir.normalized()
	v.sphere.apply_central_impulse(dir * boost_impulse)
