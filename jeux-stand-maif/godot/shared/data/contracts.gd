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
		"description": "Couvre les dommages liés à l'usage de la voiture : accident, vol, responsabilité civile.",
	},
	{
		"type": "habitation",
		"label": "Assurance Habitation",
		"icon": "🏠",
		"covers": ["degats_des_eaux", "incendie", "cambriolage"],
		"premium_basique": 11,
		"premium_premium": 19,
		"description": "Logement, biens, responsabilité civile : incendie, dégâts des eaux, vol, événements climatiques.",
	},
	{
		"type": "accidents_vie",
		"label": "Accidents de la vie",
		"icon": "🤕",
		"covers": ["blessure"],
		"premium_basique": 9,
		"premium_premium": 16,
		"description": "Couvre les accidents du quotidien : à la maison, en loisir, au sport.",
	},
	{
		"type": "catastrophe",
		"label": "Catastrophes naturelles",
		"icon": "🌊",
		"covers": ["inondation", "tempete"],
		"premium_basique": 6,
		"premium_premium": 11,
		"description": "Couvre les inondations, tempêtes et autres événements climatiques majeurs.",
	},
	{
		"type": "protection_juridique",
		"label": "Protection juridique",
		"icon": "⚖️",
		"covers": ["litige"],
		"premium_basique": 5,
		"premium_premium": 9,
		"description": "Aide en cas de litige du quotidien : voisinage, artisans, achats.",
	},
	{
		"type": "velo",
		"label": "Assurance Vélo",
		"icon": "🚲",
		"covers": ["vol_velo"],
		"premium_basique": 4,
		"premium_premium": 7,
		"description": "Protège contre le vol et les dommages liés au vélo.",
	},
]

func get_by_type(type: String) -> Dictionary:
	for c in CONTRACTS:
		if c["type"] == type:
			return c
	return {}
