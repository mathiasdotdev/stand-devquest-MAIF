extends Node

var mode: String = "solo"
var players: Array = []

var last_results: Array = []

func reset() -> void:
	mode = "solo"
	players = []
	last_results = []

func configure_solo(color: String, contract_ids: Array, scheme: String = "zqsd") -> void:
	mode = "solo"
	players = [_make_player(0, color, contract_ids, scheme)]

func configure_multi(p1_color: String, p1_contracts: Array, p1_scheme: String, p2_color: String, p2_contracts: Array, p2_scheme: String) -> void:
	mode = "multi"
	players = [
		_make_player(0, p1_color, p1_contracts, p1_scheme),
		_make_player(1, p2_color, p2_contracts, p2_scheme),
	]

func _make_player(player_id: int, color: String, contract_ids: Array, scheme: String) -> Dictionary:
	var premium_total: int = 0
	for cid in contract_ids:
		var c = InsuranceContracts.get_by_id(cid)
		if c.has("cost"):
			premium_total += int(c["cost"])
	return {
		"player_id": player_id,
		"color": color,
		"control_scheme": scheme,
		"pad_device": -1,
		"contracts": contract_ids,
		"gold_start": GameBalance.starting_gold - premium_total,
	}

func record_result(player_id: int, distance: float, score: float, gold_remaining: int, alive: bool) -> void:
	last_results.append({
		"player_id": player_id,
		"distance": distance,
		"score": score,
		"gold_remaining": gold_remaining,
		"alive": alive,
	})
