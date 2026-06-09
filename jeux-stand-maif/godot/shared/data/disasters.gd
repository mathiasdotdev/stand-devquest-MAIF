extends Node
class_name DisastersDB

const DISASTERS: Dictionary = {
	"accident_voiture": {
		"type": "accident_voiture",
		"label": "Accident de voiture",
		"icon": "💥",
		"description": "Accrochage ! Les réparations s'accumulent.",
		"base_damage": 80,
		"covering_contracts": ["auto"],
	},
	"degats_des_eaux": {
		"type": "degats_des_eaux",
		"label": "Dégâts des eaux",
		"icon": "💧",
		"description": "Fuite en appartement. Les dégâts se propagent.",
		"base_damage": 60,
		"covering_contracts": ["habitation"],
	},
	"incendie": {
		"type": "incendie",
		"label": "Incendie",
		"icon": "🔥",
		"description": "Le feu ravage tout sur son passage !",
		"base_damage": 100,
		"covering_contracts": ["habitation"],
	},
	"blessure": {
		"type": "blessure",
		"label": "Blessure",
		"icon": "🤕",
		"description": "Accident corporel. Frais médicaux élevés.",
		"base_damage": 55,
		"covering_contracts": ["accidents_vie"],
	},
	"cambriolage": {
		"type": "cambriolage",
		"label": "Cambriolage",
		"icon": "🦹",
		"description": "Des voleurs ont fracturé la porte.",
		"base_damage": 70,
		"covering_contracts": ["habitation"],
	},
	"vol_vehicule": {
		"type": "vol_vehicule",
		"label": "Vol de véhicule",
		"icon": "🚨",
		"description": "Le véhicule a disparu dans la nuit.",
		"base_damage": 90,
		"covering_contracts": ["auto"],
	},
	"inondation": {
		"type": "inondation",
		"label": "Inondation",
		"icon": "🌊",
		"description": "La montée des eaux envahit tout.",
		"base_damage": 75,
		"covering_contracts": ["catastrophe"],
	},
	"tempete": {
		"type": "tempete",
		"label": "Tempête",
		"icon": "⛈️",
		"description": "La toiture emportée par le vent.",
		"base_damage": 65,
		"covering_contracts": ["catastrophe"],
	},
	"litige": {
		"type": "litige",
		"label": "Litige",
		"icon": "⚖️",
		"description": "Conflit du quotidien : voisinage, artisan ou achat.",
		"base_damage": 50,
		"covering_contracts": ["protection_juridique"],
	},
	"vol_velo": {
		"type": "vol_velo",
		"label": "Vol de vélo",
		"icon": "🚲",
		"description": "Le vélo a disparu de la rue.",
		"base_damage": 45,
		"covering_contracts": ["velo"],
	},
}

func get_disaster(type: String) -> Dictionary:
	return DISASTERS.get(type, {})
