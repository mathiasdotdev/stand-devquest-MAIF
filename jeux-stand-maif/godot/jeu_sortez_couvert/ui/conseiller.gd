extends Control

const EXPRESSIONS: Dictionary = {
	"normal": "😐",
	"souriant": "😊",
	"inquiet": "😟",
	"fier": "😄",
}

@onready var expression_label: Label = $ExpressionLabel
@onready var name_label: Label = $NameLabel

func _ready() -> void:
	set_expression("normal")
	_start_breathing()

func set_expression(expr: String) -> void:
	expression_label.text = EXPRESSIONS.get(expr, "😐")

func _start_breathing() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.02, 1.02), 0.9).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.9).set_trans(Tween.TRANS_SINE)
