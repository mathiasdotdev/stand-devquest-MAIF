extends Node

const CONTRACTS: Array = [
	{
		"id": "basic",
		"label": "Bumper de base",
		"icon": "🛡️",
		"cost": 10,
		"reduction": 0.25,
		"description": "Reduit les reparations de 25%."
	},
	{
		"id": "premium",
		"label": "Tous risques",
		"icon": "💎",
		"cost": 25,
		"reduction": 0.60,
		"description": "Reduit les reparations de 60%."
	},
	{
		"id": "ram",
		"label": "Belier renforce",
		"icon": "🐂",
		"cost": 15,
		"reduction": 0.0,
		"rebound_boost": 0.5,
		"multi_only": true,
		"description": "Tes coups envoient l'adversaire 1.5x plus loin. (Multi)"
	},
]

func get_by_id(id: String) -> Dictionary:
	for c in CONTRACTS:
		if c["id"] == id:
			return c
	return {}

func total_reduction(contract_ids: Array) -> float:
	var sum := 0.0
	for cid in contract_ids:
		var c = get_by_id(cid)
		if c.has("reduction"):
			sum += float(c["reduction"])
	return clamp(sum, 0.0, 0.95)

func total_cost(contract_ids: Array) -> int:
	var sum := 0
	for cid in contract_ids:
		var c = get_by_id(cid)
		if c.has("cost"):
			sum += int(c["cost"])
	return sum

func total_rebound_boost(contract_ids: Array) -> float:
	var sum := 0.0
	for cid in contract_ids:
		var c = get_by_id(cid)
		if c.has("rebound_boost"):
			sum += float(c["rebound_boost"])
	return sum

func is_available_in_mode(contract: Dictionary, mode: String) -> bool:
	if contract.get("multi_only", false) and mode != "multi":
		return false
	return true
