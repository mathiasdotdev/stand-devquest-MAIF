extends Control

var target: Vehicle
var race_ref: Node

const COLOR_LABELS: Dictionary = {
	"green":  "Vert",
	"orange": "Orange",
	"red":    "Rouge",
	"white":  "Blanc",
}

@onready var name_label: Label = $TopLeft/PlayerName
@onready var gold_label: Label = $TopLeft/GoldLabel
@onready var contracts_row: HBoxContainer = $TopLeft/ContractsRow
@onready var time_label: Label = $TopCenter/TimeLabel
@onready var score_label: Label = $TopRight/ScoreLabel
@onready var distance_label: Label = $TopRight/DistanceLabel
@onready var mult_label: Label = $TopRight/MultLabel
@onready var dead_overlay: Control = $DeadOverlay
@onready var stun_overlay: Control = $StunOverlay

func setup(vehicle: Vehicle, race: Node) -> void:
	target = vehicle
	race_ref = race

func _ready() -> void:
	_populate_static()

func _populate_static() -> void:
	if target == null:
		return
	var color_label: String = COLOR_LABELS.get(target.vehicle_color, target.vehicle_color)
	name_label.text = "Joueur %d  (%s)" % [target.player_id + 1, color_label]
	for child in contracts_row.get_children():
		child.queue_free()
	for cid in target.contracts:
		var c = InsuranceContracts.get_by_id(cid)
		if c.is_empty():
			continue
		var lbl := Label.new()
		lbl.text = "%s %s" % [c.get("icon", ""), c.get("label", cid)]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.78, 0.86, 1.0, 1.0))
		contracts_row.add_child(lbl)

func _process(_delta: float) -> void:
	if target == null:
		return
	# Gold
	gold_label.text = "💰 %d or" % target.gold
	var ratio: float = float(target.gold) / float(maxi(target.starting_gold, 1))
	if ratio < 0.2:
		gold_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	elif ratio < 0.5:
		gold_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35))
	else:
		gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.35))

	# Score, distance, multiplier
	score_label.text = "🎯 %d" % int(target.score)
	distance_label.text = "📏 %d m" % int(target.distance)
	mult_label.text = "⚡ x%.2f" % target.speed_multiplier
	var mult_norm: float = clamp((target.speed_multiplier - 1.0) / 2.0, 0.0, 1.0)
	mult_label.add_theme_color_override("font_color", Color(1.0, 1.0 - mult_norm * 0.6, 0.3))

	# Time
	if race_ref != null and race_ref.has_method("get_time_remaining"):
		var t: float = race_ref.get_time_remaining()
		var mins: int = int(t / 60.0)
		var secs: int = int(t) % 60
		time_label.text = "⏱ %d:%02d" % [mins, secs]

	# Dead / Stun overlays
	dead_overlay.visible = target.out
	stun_overlay.visible = not target.out and target.is_stunned()
