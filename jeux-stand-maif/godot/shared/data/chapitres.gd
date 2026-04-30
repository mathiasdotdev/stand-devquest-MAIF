extends Node

const CHAPITRES: Array = [
	# --- Chapitre 0 : Premier vehicule ---
	{
		"id": 0,
		"titre": "Premier vehicule",
		"emoji": "🚗",
		"contexte": "Vous venez d'obtenir votre permis et d'acheter votre premiere voiture. La liberte, enfin ! Mais la route peut reserver des surprises...",
		"gold_budget": 180,
		"intro": [
			{"text": "Bonjour ! Je suis votre conseiller MAIF. Bienvenue dans votre parcours assurantiel !", "expression": "souriant"},
			{"text": "Vous venez d'acheter votre premier vehicule. C'est une etape importante de la vie !", "expression": "souriant"},
			{"text": "Mais la route peut etre imprevisible... Un accident ou un vol peuvent couter tres cher.", "expression": "inquiet"},
			{"text": "Avant de prendre la route, gerez vos assurances. Choisissez le contrat le plus adapte !", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "accident_voiture",
				"probability": 0.85,
				"narrative": "En rentrant du travail, vous percutez un autre vehicule a un carrefour. Les degats sont importants."
			},
			{
				"type": "vol_vehicule",
				"probability": 0.45,
				"narrative": "Vous trouvez votre place de parking vide le matin. Votre voiture a ete volee dans la nuit."
			},
		],
		"prevention_tips": [
			{"tip": "Respectez les distances de securite", "emoji": "🚗"},
			{"tip": "Utilisez un antivol visible en plus du systeme de serie", "emoji": "⛓️"},
		],
		"recommended_contracts": ["auto"],
	},
	# --- Chapitre 1 : Nouvel appartement ---
	{
		"id": 1,
		"titre": "Nouvel appartement",
		"emoji": "🏠",
		"contexte": "Vous emmenagez dans votre premier appartement. Cartons, meubles IKEA et... risques en tous genres pour votre nouveau chez-vous.",
		"gold_budget": 200,
		"intro": [
			{"text": "Felicitations pour votre nouvel appartement ! C'est votre chez-vous desormais.", "expression": "souriant"},
			{"text": "Un logement, ca apporte aussi des responsabilites. Les sinistres domestiques sont tres frequents.", "expression": "normal"},
			{"text": "Degats des eaux, incendie, cambriolage... un locataire peut etre responsable des degats causes aux voisins !", "expression": "inquiet"},
			{"text": "Pensez a vous couvrir avant d'y dormir. Quel contrat choisiriez-vous ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "degats_des_eaux",
				"probability": 0.90,
				"narrative": "Un joint de robinet cede pendant votre sommeil. Le parquet est inonde et les voisins du dessous se plaignent."
			},
			{
				"type": "cambriolage",
				"probability": 0.50,
				"narrative": "Vous rentrez de vacances pour trouver votre appartement sens dessus dessous. Tout votre materiel electronique a disparu."
			},
			{
				"type": "incendie",
				"probability": 0.30,
				"narrative": "Une casserole oubliee sur le feu provoque un incendie dans la cuisine. Les pompiers interviennent."
			},
		],
		"prevention_tips": [
			{"tip": "Fermez bien les robinets avant de partir", "emoji": "🚿"},
			{"tip": "Installez un detecteur de fumee (obligation legale)", "emoji": "🔔"},
			{"tip": "Installez une serrure 3 points certifiee", "emoji": "🔐"},
		],
		"recommended_contracts": ["habitation"],
	},
	# --- Chapitre 2 : Hiver difficile ---
	{
		"id": 2,
		"titre": "Hiver difficile",
		"emoji": "🌧️",
		"contexte": "Cet hiver est particulierement rude. Tempetes, inondations et routes verglacees mettent votre quotidien a l'epreuve.",
		"gold_budget": 160,
		"intro": [
			{"text": "Cet hiver s'annonce difficile. Les meteorologues prevoir des tempetes repetees.", "expression": "inquiet"},
			{"text": "Les catastrophes naturelles comme les tempetes et inondations ne sont pas rares en France.", "expression": "normal"},
			{"text": "Et le verglas multiplie par 3 les risques d'accident de voiture...", "expression": "inquiet"},
			{"text": "Preparez-vous avant que la neige arrive. Quel est le risque principal a couvrir ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "tempete",
				"probability": 0.95,
				"narrative": "Une violente tempete arrache une partie de votre toiture et detruit la gouttiere. Les reparations sont urgentes."
			},
			{
				"type": "inondation",
				"probability": 0.60,
				"narrative": "Les pluies torrentielles font deborder la riviere voisine. Votre cave est inondee et plusieurs biens endommages."
			},
			{
				"type": "accident_voiture",
				"probability": 0.55,
				"narrative": "Le verglas fait deraper votre voiture. Vous emboutissez un poteau. Personne n'est blesse, mais le vehicule est cabose."
			},
		],
		"prevention_tips": [
			{"tip": "Elaguez les arbres proches de votre maison chaque automne", "emoji": "🌳"},
			{"tip": "Elevez vos appareils electriques en zone inondable", "emoji": "📦"},
			{"tip": "Evitez toute distraction au volant", "emoji": "📵"},
		],
		"recommended_contracts": ["catastrophe", "auto"],
	},
	# --- Chapitre 3 : Vie active ---
	{
		"id": 3,
		"titre": "Vie active",
		"emoji": "💼",
		"contexte": "Vous etes lance dans votre carriere. Sport regulier, longues journees, deplacements frequents... le rythme s'accelere.",
		"gold_budget": 220,
		"intro": [
			{"text": "Votre vie bat a plein regime ! Travail, sport, sorties... bravo pour cette energie.", "expression": "souriant"},
			{"text": "Mais avec un emploi du temps charge, les accidents du quotidien sont plus frequents.", "expression": "normal"},
			{"text": "Une entorse au sport, un vol de sac dans le metro, un accrochage en voiture...", "expression": "inquiet"},
			{"text": "Mieux vaut prevoir. Quel contrat serait le plus utile a votre rythme de vie ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "blessure",
				"probability": 0.75,
				"narrative": "Lors de votre match de football hebdomadaire, vous vous fracturez le poignet. Urgences, radio, platre..."
			},
			{
				"type": "vol_vehicule",
				"probability": 0.40,
				"narrative": "Votre voiture garee devant le bureau a ete forcee et votre ordinateur professionnel vole a l'interieur."
			},
			{
				"type": "accident_voiture",
				"probability": 0.50,
				"narrative": "Distrait par une notification sur votre telephone, vous grilles un feu rouge. Accrochage avec un scooter."
			},
		],
		"prevention_tips": [
			{"tip": "Portez des equipements de protection adaptes", "emoji": "⛑️"},
			{"tip": "Ne laissez jamais d'objets visibles a l'interieur du vehicule", "emoji": "👀"},
			{"tip": "Respectez les distances de securite", "emoji": "🚗"},
		],
		"recommended_contracts": ["sante", "auto", "vol"],
	},
	# --- Chapitre 4 : Ete a risque ---
	{
		"id": 4,
		"titre": "Ete a risque",
		"emoji": "🔥",
		"contexte": "Grande chaleur, maison laissee vide pour les vacances, feux de foret dans la region... cet ete met vos biens a l'epreuve.",
		"gold_budget": 190,
		"intro": [
			{"text": "L'ete est la ! Mais avec la chaleur arrivent aussi les risques...", "expression": "normal"},
			{"text": "Maison vide pendant les vacances = cible ideale pour les cambrioleurs.", "expression": "inquiet"},
			{"text": "Et la canicule augmente fortement les risques d'incendie, surtout dans le Midi.", "expression": "inquiet"},
			{"text": "Avant de partir en vacances, faites le point sur votre couverture prioritaire.", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "incendie",
				"probability": 0.80,
				"narrative": "Un feu de garrigue approche votre residence secondaire. Les flammes abiment la terrasse et le cabanon."
			},
			{
				"type": "cambriolage",
				"probability": 0.70,
				"narrative": "Pendant vos 3 semaines de vacances, des cambrioleurs visitent votre appartement. Bijoux et consoles disparaissent."
			},
			{
				"type": "degats_des_eaux",
				"probability": 0.35,
				"narrative": "Un tuyau d'arrosage automatique mal regle inonde votre terrasse et s'infiltre chez le voisin du dessous."
			},
		],
		"prevention_tips": [
			{"tip": "Gardez un extincteur accessible dans la cuisine", "emoji": "🧯"},
			{"tip": "Ne laissez jamais de cle cachee dehors", "emoji": "🗝️"},
			{"tip": "Fermez bien les robinets avant de partir", "emoji": "🚿"},
		],
		"recommended_contracts": ["habitation", "vol"],
	},
	# --- Chapitre 5 : L'annee noire ---
	{
		"id": 5,
		"titre": "L'annee noire",
		"emoji": "🌊",
		"contexte": "La loi des series frappe. Cette annee cumule les coups durs. C'est le grand test de votre couverture assurantielle.",
		"gold_budget": 250,
		"intro": [
			{"text": "Je dois etre franc avec vous : cette annee s'annonce difficile.", "expression": "inquiet"},
			{"text": "Plusieurs evenements graves peuvent survenir en peu de temps.", "expression": "inquiet"},
			{"text": "C'est exactement dans ces moments-la que l'assurance fait toute la difference.", "expression": "normal"},
			{"text": "Prenez le temps de bien choisir. Quel est le contrat le plus critique pour cette annee ?", "expression": "fier"},
		],
		"disasters": [
			{
				"type": "inondation",
				"probability": 1.0,
				"narrative": "Des pluies exceptionnelles causent des inondations historiques dans votre quartier. Le rez-de-chaussee est submerge."
			},
			{
				"type": "accident_voiture",
				"probability": 1.0,
				"narrative": "Sur l'autoroute, un pneu eclate. Votre voiture derape et heurte le rail de securite. La carrosserie est detruite."
			},
			{
				"type": "incendie",
				"probability": 0.70,
				"narrative": "Un court-circuit dans le tableau electrique declenche un incendie dans la nuit. Les pompiers sauvent l'essentiel."
			},
			{
				"type": "blessure",
				"probability": 0.60,
				"narrative": "En aidant les voisins a pomper l'eau de la cave, vous glissez et vous cassez la cheville."
			},
		],
		"prevention_tips": [
			{"tip": "Elevez vos appareils electriques en zone inondable", "emoji": "📦"},
			{"tip": "Verifiez vos pneus et freins regulierement", "emoji": "🔧"},
			{"tip": "Ne laissez jamais de bougies sans surveillance", "emoji": "🕯️"},
			{"tip": "Gardez une trousse de premiers secours chez vous", "emoji": "🏥"},
		],
		"recommended_contracts": ["auto", "habitation", "catastrophe", "sante"],
	},
]

func get_chapitre(id: int) -> Dictionary:
	if id < 0 or id >= CHAPITRES.size():
		return {}
	return CHAPITRES[id]

func count() -> int:
	return CHAPITRES.size()
