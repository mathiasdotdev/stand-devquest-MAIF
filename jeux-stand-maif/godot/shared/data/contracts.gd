extends Node
class_name ContractsDB

const CONTRACTS: Array = [
	{
		"type": "auto",
		"label": "Assurance Auto",
		"icon": "🚗",
		"covers": ["accident_voiture", "vol_vehicule"],
		"premium_basique": 14,
		"premium_premium": 24,
		"description": "Couvre accident et vol de vehicule."
	},
	{
		"type": "habitation",
		"label": "Assurance Habitation",
		"icon": "🏠",
		"covers": ["degats_des_eaux", "incendie", "cambriolage"],
		"premium_basique": 11,
		"premium_premium": 19,
		"description": "Couvre degats des eaux, incendie, cambriolage."
	},
	{
		"type": "sante",
		"label": "Assurance Sante",
		"icon": "🏥",
		"covers": ["blessure"],
		"premium_basique": 9,
		"premium_premium": 16,
		"description": "Couvre les blessures et frais medicaux."
	},
	{
		"type": "vol",
		"label": "Assurance Vol",
		"icon": "🔒",
		"covers": ["cambriolage", "vol_vehicule"],
		"premium_basique": 7,
		"premium_premium": 13,
		"description": "Couvre cambriolage et vol de vehicule."
	},
	{
		"type": "catastrophe",
		"label": "Catastrophe Naturelle",
		"icon": "🌊",
		"covers": ["inondation", "tempete"],
		"premium_basique": 6,
		"premium_premium": 11,
		"description": "Couvre inondation et tempete."
	},
]

func get_by_type(type: String) -> Dictionary:
	for c in CONTRACTS:
		if c["type"] == type:
			return c
	return {}
