extends Control

const LEGACY_TO_STATE: Dictionary = {
	"normal": "explain",
	"souriant": "ok",
	"inquiet": "wrong",
	"fier": "hyper-good",
}

const STATE_FRAMES: Dictionary = {
	"ok": 1,
	"hyper-good": 1,
	"wrong": 1,
	"question": 2,
	"explain": 4,
}

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	set_expression("question")

func set_expression(expr: String) -> void:
	var state: String = _normalize_state(expr)
	if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(state):
		_sprite.animation = state
		var frame_count: int = int(STATE_FRAMES.get(state, 1))
		if frame_count > 1:
			_sprite.frame = (_sprite.frame + 1) % frame_count
		else:
			_sprite.frame = 0
		_sprite.stop()
	else:
		_sprite.animation = "question"
		_sprite.frame = 0
		_sprite.stop()

func _normalize_state(expr: String) -> String:
	if LEGACY_TO_STATE.has(expr):
		return LEGACY_TO_STATE[expr]

	match expr:
		"ok", "hyper-good", "wrong", "question", "explain":
			return expr
		_:
			return "question"
