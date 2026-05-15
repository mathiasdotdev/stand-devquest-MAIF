class_name Vehicle extends Node3D

# Multiplayer / customization

@export var player_id: int = 0
@export var vehicle_color: String = "green"
@export var control_scheme: String = "zqsd"
@export var pad_device: int = -1
@export var starting_gold: int = 100

signal eliminated(pid: int)

var gold: int = 100
var distance: float = 0.0
var score: float = 0.0
var speed_multiplier: float = 1.0
var contracts: Array = []
var out: bool = false

var _last_impact_ms: int = -10_000

var stunned_until_ms: int = 0
var _last_pvp_ms: int = -10_000

const COLOR_TO_MODEL: Dictionary = {
	"green":  "res://jeu_grand_pasdetolismo/models/kenney/raceCarGreen.glb",
	"orange": "res://jeu_grand_pasdetolismo/models/kenney/raceCarOrange.glb",
	"red":    "res://jeu_grand_pasdetolismo/models/kenney/raceCarRed.glb",
	"white":  "res://jeu_grand_pasdetolismo/models/kenney/raceCarWhite.glb",
}

func _enter_tree() -> void:
	_swap_model_if_needed()

func _swap_model_if_needed() -> void:
	if vehicle_color == "green":
		return
	var path: String = COLOR_TO_MODEL.get(vehicle_color, "")
	if path == "":
		return
	var container: Node = get_node_or_null("Container")
	if container == null:
		return
	var old_model: Node = container.get_node_or_null("Model")
	if old_model == null:
		return
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return
	var new_model: Node = packed.instantiate()
	new_model.name = "Model"
	var idx: int = old_model.get_index()
	container.remove_child(old_model)
	old_model.queue_free()
	container.add_child(new_model)
	container.move_child(new_model, idx)

# Nodes

@onready var sphere: RigidBody3D = $Sphere
@onready var raycast: RayCast3D = $Ground

# Vehicle elements

@onready var vehicle_model = $Container
@onready var vehicle_body = get_node_or_null("Container/Model/body")

# (Optional) wheels

@onready var wheel_fl = get_node_or_null("Container/Model/wheel-front-left")
@onready var wheel_fr = get_node_or_null("Container/Model/wheel-front-right")
@onready var wheel_bl = get_node_or_null("Container/Model/wheel-back-left")
@onready var wheel_br = get_node_or_null("Container/Model/wheel-back-right")

# Effects

@onready var trail_left = get_node_or_null("Container/TrailLeft")
@onready var trail_right = get_node_or_null("Container/TrailRight")

var stun_fx: GPUParticles3D = null

# Sounds

@onready var screech_sound: AudioStreamPlayer3D = $Container/ScreechSound
@onready var engine_sound: AudioStreamPlayer3D = $Container/EngineSound
@onready var impact_sound: AudioStreamPlayer3D = $Container/ImpactSound

var input: Vector3
var normal: Vector3

var acceleration: float
var angular_speed: float
var linear_speed: float

var colliding: bool

var linear_velocity: Vector3
var prev_position: Vector3

var calculated_lean: float

# Public Functions

func get_vehicle_position() -> Vector3: return vehicle_model.global_position

# Functions

func _ready() -> void:
	gold = starting_gold
	# Make vehicles physically collide with each other (layer 8) in addition to ground (layer 1).
	if sphere != null:
		sphere.collision_mask = sphere.collision_mask | 8
	_setup_stun_fx()

func _setup_stun_fx() -> void:
	if vehicle_model == null:
		return
	stun_fx = GPUParticles3D.new()
	stun_fx.amount = 18
	stun_fx.lifetime = 0.6
	stun_fx.emitting = false
	stun_fx.position = Vector3(0.0, 0.8, 0.0)

	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 40.0
	pm.initial_velocity_min = 0.6
	pm.initial_velocity_max = 1.4
	pm.gravity = Vector3.ZERO
	pm.scale_min = 0.12
	pm.scale_max = 0.25
	pm.angle_min = 0.0
	pm.angle_max = 360.0
	pm.color = Color(1.0, 0.86, 0.25, 1.0)
	stun_fx.process_material = pm

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.35, 0.35)
	stun_fx.draw_pass_1 = mesh

	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.billboard_keep_scale = true
	mat.albedo_color = Color(1.0, 0.88, 0.3, 1.0)
	mat.albedo_texture = load("res://jeu_grand_pasdetolismo/sprites/smoke.png") as Texture2D
	stun_fx.material_override = mat

	vehicle_model.add_child(stun_fx)

func _physics_process(delta):

	if out:
		return

	handle_input(delta)

	var direction = sign(linear_speed)
	if direction == 0: direction = sign(input.z) if abs(input.z) > 0.1 else 1

	var steering_grip = clamp(abs(linear_speed), 0.2, 1.0)

	var target_angular = -input.x * steering_grip * 4 * direction
	angular_speed = lerp(angular_speed, target_angular, delta * 4)

	vehicle_model.rotate_y(angular_speed * delta)

	# Ground alignment

	if raycast.is_colliding():
		if !colliding:
			if vehicle_body != null: vehicle_body.position = Vector3(0, 0.1, 0) # Bounce
			input.z = 0

		normal = raycast.get_collision_normal()

		# Orient model to colliding normal

		if normal.dot(vehicle_model.global_basis.y) > 0.5:
			var xform = align_with_y(vehicle_model.global_transform, normal)
			vehicle_model.global_transform = vehicle_model.global_transform.interpolate_with(xform, 0.2).orthonormalized()

	colliding = raycast.is_colliding()

	var target_speed = input.z
	if is_stunned():
		target_speed = 0.0

	if (target_speed < 0 and linear_speed > 0.01):
		linear_speed = lerp(linear_speed, 0.0, delta * 8)
	else:
		if (target_speed < 0):
			linear_speed = lerp(linear_speed, target_speed / 2, delta * 2)
		else:
			linear_speed = lerp(linear_speed, target_speed, delta * 6)

	if is_stunned():
		linear_speed = lerp(linear_speed, 0.0, delta * 15)

	acceleration = lerpf(acceleration, linear_speed + (abs(sphere.angular_velocity.length() * linear_speed) / 100), delta * 1)

	# Match vehicle model to physics sphere

	vehicle_model.position = sphere.position - Vector3(0, 0.65, 0)
	raycast.position = sphere.position

	# Calculate vehicle model linear velocity

	linear_velocity = (vehicle_model.position - prev_position) / delta
	prev_position = vehicle_model.position

	# Distance & score

	var step: float = linear_velocity.length() * delta
	distance += step
	var speed_norm: float = clamp(linear_velocity.length() / GameBalance.speed_top, 0.0, 1.0)
	speed_multiplier = 1.0 + speed_norm * (GameBalance.speed_multiplier_max - 1.0)
	score += step * speed_multiplier

	# Visual and audio effects

	effect_engine(delta)
	effect_body(delta)
	effect_wheels(delta)
	effect_trails()
	if stun_fx != null:
		stun_fx.emitting = is_stunned()

# Handle input when vehicle is colliding with ground

func handle_input(delta):

	var ix: float = 0.0
	var iz: float = 0.0

	match control_scheme:
		"zqsd":
			ix = _kbd_axis(KEY_A, KEY_D)
			iz = _kbd_axis(KEY_S, KEY_W)
		"arrows":
			ix = _kbd_axis(KEY_LEFT, KEY_RIGHT)
			iz = _kbd_axis(KEY_DOWN, KEY_UP)
		"pad":
			if pad_device >= 0:
				ix = Input.get_joy_axis(pad_device, JOY_AXIS_LEFT_X)
				var rt: float = maxf(Input.get_joy_axis(pad_device, JOY_AXIS_TRIGGER_RIGHT), 0.0)
				var lt: float = maxf(Input.get_joy_axis(pad_device, JOY_AXIS_TRIGGER_LEFT), 0.0)
				iz = rt - lt
				if absf(ix) < 0.15:
					ix = 0.0
				if absf(iz) < 0.15:
					iz = 0.0

	if raycast.is_colliding():
		input.x = ix
		input.z = iz

	sphere.angular_velocity += vehicle_model.get_global_transform().basis.x * (linear_speed * 100) * delta

func _kbd_axis(neg_key: int, pos_key: int) -> float:
	var v: float = 0.0
	if Input.is_physical_key_pressed(pos_key):
		v += 1.0
	if Input.is_physical_key_pressed(neg_key):
		v -= 1.0
	return v

func effect_body(delta):
	
	calculated_lean = lerp_angle(calculated_lean, -input.x / 5 * linear_speed, delta * 5)
	
	# Slightly tilt (and move) body based on acceleration and steering
	
	if vehicle_body != null:
		
		vehicle_body.rotation.x = lerp_angle(vehicle_body.rotation.x, -(linear_speed - acceleration) / 6, delta * 10)
		vehicle_body.rotation.z = calculated_lean
		
		vehicle_body.position = vehicle_body.position.lerp(Vector3(0, 0.2, 0), delta * 5)
	
func effect_wheels(delta):

	# Rotate wheels based on acceleration

	for wheel in [wheel_fl, wheel_fr, wheel_bl, wheel_br]:
		if wheel != null:
			wheel.rotation.x += acceleration

	# Rotate front wheels based on steering direction

	if wheel_fl != null: wheel_fl.rotation.y = lerp_angle(wheel_fl.rotation.y, -input.x / 1.5, delta * 10)
	if wheel_fr != null: wheel_fr.rotation.y = lerp_angle(wheel_fr.rotation.y, -input.x / 1.5, delta * 10)

# Engine sounds

func effect_engine(delta):

	var speed_factor = clamp(abs(linear_speed), 0.0, 1.0)
	var throttle_factor = clamp(abs(input.z), 0.0, 1.0)

	var target_volume = remap(speed_factor + (throttle_factor * 0.5), 0.0, 1.5, -15.0, -5.0)
	engine_sound.volume_db = lerp(engine_sound.volume_db, target_volume, delta * 5.0)

	var target_pitch = remap(speed_factor, 0.0, 1.0, 0.5, 3)
	if throttle_factor > 0.1: target_pitch += 0.2

	engine_sound.pitch_scale = lerp(engine_sound.pitch_scale, target_pitch, delta * 2.0)

# Show trails (and play skid sound)

func effect_trails():

	var drift_intensity = abs(linear_speed - acceleration) + (abs(calculated_lean) * 2.0)
	var should_emit = drift_intensity > GameBalance.drift_threshold

	if trail_left != null: trail_left.emitting = should_emit
	if trail_right != null: trail_right.emitting = should_emit

	var target_volume = -80.0
	if should_emit: target_volume = remap(clamp(drift_intensity, 0.25, 2.0), 0.25, 2.0, -10.0, 0.0)

	screech_sound.pitch_scale = lerp(screech_sound.pitch_scale, clamp(abs(linear_speed), 1.0, 3.0), 0.1)
	screech_sound.volume_db = lerp(screech_sound.volume_db, target_volume, 10.0 * get_physics_process_delta_time())

# Align vehicle with normal

func align_with_y(xform, new_y):

	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

# Detect collisions and play impact sound

func _on_sphere_body_entered(body: Node) -> void:

	if vehicle_body == null or out:
		return

	var now: int = Time.get_ticks_msec()
	if now - _last_impact_ms < GameBalance.impact_cooldown_ms:
		return
	_last_impact_ms = now

	var impact_velocity: float = absf(linear_velocity.dot(vehicle_body.global_basis.z))
	if not impact_sound.playing:
		impact_sound.volume_db = clampf(remap(impact_velocity, 0.0, 6.0, -20.0, 0.0), -20.0, 0.0)
		impact_sound.play()

	var other: Vehicle = _resolve_other_vehicle(body)
	if other != null:
		if other.out:
			return
		if now - _last_pvp_ms < GameBalance.pvp_cooldown_ms:
			return
		_last_pvp_ms = now
		other._last_pvp_ms = now
		_handle_pvp_collision(other)
		return

	# Décor / monde : coût d'or comme avant
	var raw_cost: float = clamp(impact_velocity * GameBalance.impact_cost_factor, GameBalance.impact_cost_min, GameBalance.impact_cost_max)
	var reduction: float = InsuranceContracts.total_reduction(contracts)
	var final_cost: int = roundi(raw_cost * (1.0 - reduction))
	if final_cost < 1:
		final_cost = 1
	gold = max(0, gold - final_cost)
	if gold == 0:
		_eliminate()

func _resolve_other_vehicle(body: Node) -> Vehicle:
	if body == null:
		return null
	var p: Node = body.get_parent()
	if p != null and p != self and p is Vehicle:
		return p as Vehicle
	return null

func _handle_pvp_collision(other: Vehicle) -> void:
	if vehicle_model == null or other.vehicle_model == null:
		return
	var my_inv: Transform3D = vehicle_model.global_transform.affine_inverse()
	var other_inv: Transform3D = other.vehicle_model.global_transform.affine_inverse()
	# Convention truck GLB : +Z local = avant, -Z local = arriere.
	# "Impact le plus en arriere sur son vehicule" = lp.z le plus negatif.
	var me_z: float = (my_inv * other.vehicle_model.global_position).z
	var other_z: float = (other_inv * vehicle_model.global_position).z

	var threshold: float = GameBalance.pvp_side_threshold
	var full_speed: float = GameBalance.speed_top * GameBalance.no_stun_speed_ratio
	if me_z < other_z - threshold:
		# Mon impact est plus en arriere → je suis la victime, l'autre est fautif
		var boost: float = InsuranceContracts.total_rebound_boost(other.contracts)
		_apply_rebound_from(other, 1.0 + boost)
		if other.linear_velocity.length() >= full_speed:
			other.linear_speed *= GameBalance.no_stun_speed_penalty
			other.gold += GameBalance.no_stun_gold_reward
		else:
			other.apply_stun(GameBalance.stun_duration_ms)
	elif other_z < me_z - threshold:
		# L'autre a l'impact plus en arriere → c'est lui la victime
		var boost: float = InsuranceContracts.total_rebound_boost(contracts)
		other._apply_rebound_from(self, 1.0 + boost)
		if linear_velocity.length() >= full_speed:
			linear_speed *= GameBalance.no_stun_speed_penalty
			gold += GameBalance.no_stun_gold_reward
		else:
			apply_stun(GameBalance.stun_duration_ms)
	else:
		# Cote-a-cote : rebond mutuel leger, pas de stun
		_apply_rebound_from(other, 0.4)
		other._apply_rebound_from(self, 0.4)

func _apply_rebound_from(attacker: Vehicle, scale: float = 1.0) -> void:
	if sphere == null or attacker == null or attacker.vehicle_model == null:
		return
	var dir: Vector3 = vehicle_model.global_position - attacker.vehicle_model.global_position
	dir.y = 0.0
	if dir.length() < 0.01:
		return
	dir = dir.normalized()
	sphere.apply_central_impulse(dir * GameBalance.pvp_rebound_force * scale)

func apply_stun(duration_ms: int) -> void:
	var now: int = Time.get_ticks_msec()
	stunned_until_ms = maxi(stunned_until_ms, now + duration_ms)

func is_stunned() -> bool:
	return Time.get_ticks_msec() < stunned_until_ms

func _eliminate() -> void:
	if out:
		return
	out = true
	if sphere != null:
		sphere.freeze = true
	if vehicle_model != null:
		vehicle_model.visible = false
	if trail_left != null:
		trail_left.emitting = false
	if trail_right != null:
		trail_right.emitting = false
	if engine_sound != null:
		engine_sound.stop()
	if screech_sound != null:
		screech_sound.stop()
	eliminated.emit(player_id)
