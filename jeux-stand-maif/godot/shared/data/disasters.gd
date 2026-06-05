extends Node
class_name DisastersDB

const DISASTERS: Dictionary = {
	"accident_voiture": {
		"type": "accident_voiture",
		"label": "Accident de voiture",
		"icon": "💥",
		"description": "Accrochage ! Les reparations s'accumulent.",
		"base_damage": 80,
		"covering_contracts": ["auto"]
	},
	"degats_des_eaux": {
		"type": "degats_des_eaux",
		"label": "Degats des eaux",
		"icon": "💧",
		"description": "Fuite en appartement. Les degats se propagent.",
		"base_damage": 60,
		"covering_contracts": ["habitation"]
	},
	"incendie": {
		"type": "incendie",
		"label": "Incendie",
		"icon": "🔥",
		"description": "Le feu ravage tout sur son passage !",
		"base_damage": 100,
		"covering_contracts": ["habitation"]
	},
	"blessure": {
		"type": "blessure",
		"label": "Blessure",
		"icon": "🤕",
		"description": "Accident corporel. Frais medicaux eleves.",
		"base_damage": 55,
		"covering_contracts": ["sante"]
	},
	"cambriolage": {
		"type": "cambriolage",
		"label": "Cambriolage",
		"icon": "🦹",
		"description": "Des voleurs ont fracture la porte.",
		"base_damage": 70,
		"covering_contracts": ["habitation", "vol"]
	},
	"vol_vehicule": {
		"type": "vol_vehicule",
		"label": "Vol de vehicule",
		"icon": "🚨",
		"description": "Le vehicule a disparu dans la nuit.",
		"base_damage": 90,
		"covering_contracts": ["auto", "vol"]
	},
	"inondation": {
		"type": "inondation",
		"label": "Inondation",
		"icon": "🌊",
		"description": "La montee des eaux envahit tout.",
		"base_damage": 75,
		"covering_contracts": ["catastrophe"]
	},
	"tempete": {
		"type": "tempete",
		"label": "Tempete",
		"icon": "⛈️",
		"description": "La toiture emportee par le vent.",
		"base_damage": 65,
		"covering_contracts": ["catastrophe"]
	},
}

func get_disaster(type: String) -> Dictionary:
	return DISASTERS.get(type, {})
