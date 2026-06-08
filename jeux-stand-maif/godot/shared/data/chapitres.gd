extends Node
class_name ChapitresDB

const CHAPITRES: Array = [
	# --- Chapitre 0 : Premier véhicule ---
	{
		"id": 0,
		"titre": "Premier véhicule",
		"emoji": "🚗",
		"contexte": "Vous venez d'obtenir votre permis et d'acheter votre première voiture. La liberté, enfin ! Mais la route peut réserver des surprises...",
		"resume": "Vous venez d'avoir votre permis et acheté votre première voiture.",
		"gold_budget": 180,
		"intro": [
			{"text": "Bonjour ! Je suis votre conseiller MAIF. Bienvenue dans votre parcours assurantiel !", "expression": "souriant"},
			{"text": "Vous venez d'acheter votre premier véhicule. C'est une étape importante de la vie !", "expression": "souriant"},
			{"text": "Mais la route peut être imprévisible... Un accident ou un vol peuvent coûter très cher.", "expression": "inquiet"},
			{"text": "Avant de prendre la route, gérez vos assurances. Choisissez le contrat le plus adapté !", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "accident_voiture",
				"probability": 0.85,
				"narrative": "En rentrant du travail, vous percutez un autre véhicule à un carrefour. Les dégâts sont importants.",
			},
			{
				"type": "vol_vehicule",
				"probability": 0.45,
				"narrative": "Vous trouvez votre place de parking vide le matin. Votre voiture a été volée dans la nuit.",
			},
		],
		"prevention_tips": [
			{"tip": "Respectez les distances de sécurité", "emoji": "🚗"},
			{"tip": "Utilisez un antivol visible en plus du système de série", "emoji": "⛓️"},
		],
		"recommended_contracts": ["auto"],
	},
	# --- Chapitre 1 : Nouvel appartement ---
	{
		"id": 1,
		"titre": "Nouvel appartement",
		"emoji": "🏠",
		"contexte": "Vous emménagez dans votre premier appartement. Cartons, meubles IKEA et... risques en tous genres pour votre nouveau chez-vous.",
		"resume": "Vous emménagez dans votre premier appartement.",
		"gold_budget": 200,
		"intro": [
			{"text": "Félicitations pour votre nouvel appartement ! C'est votre chez-vous désormais.", "expression": "souriant"},
			{"text": "Un logement, ça apporte aussi des responsabilités. Les sinistres domestiques sont très fréquents.", "expression": "normal"},
			{"text": "Dégâts des eaux, incendie, cambriolage... un locataire peut être responsable des dégâts causés aux voisins !", "expression": "inquiet"},
			{"text": "Pensez à vous couvrir avant d'y dormir. Quel contrat choisiriez-vous ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "degats_des_eaux",
				"probability": 0.90,
				"narrative": "Un joint de robinet cède pendant votre sommeil. Le parquet est inondé et les voisins du dessous se plaignent.",
			},
			{
				"type": "cambriolage",
				"probability": 0.50,
				"narrative": "Vous rentrez de vacances pour trouver votre appartement sens dessus dessous. Tout votre matériel électronique a disparu.",
			},
			{
				"type": "incendie",
				"probability": 0.30,
				"narrative": "Une casserole oubliée sur le feu provoque un incendie dans la cuisine. Les pompiers interviennent.",
			},
		],
		"prevention_tips": [
			{"tip": "Fermez bien les robinets avant de partir", "emoji": "🚿"},
			{"tip": "Installez un détecteur de fumée (obligation légale)", "emoji": "🔔"},
			{"tip": "Installez une serrure 3 points certifiée", "emoji": "🔐"},
		],
		"recommended_contracts": ["habitation"],
	},
	# --- Chapitre 2 : Hiver difficile ---
	{
		"id": 2,
		"titre": "Hiver difficile",
		"emoji": "🌧️",
		"contexte": "Cet hiver est particulièrement rude. Tempêtes, inondations et routes verglacées mettent votre quotidien à l'épreuve.",
		"resume": "L'hiver arrive, et il s'annonce difficile.",
		"gold_budget": 160,
		"intro": [
			{"text": "Cet hiver s'annonce difficile. Les météorologues prévoient des tempêtes répétées.", "expression": "inquiet"},
			{"text": "Les catastrophes naturelles comme les tempêtes et inondations ne sont pas rares en France.", "expression": "normal"},
			{"text": "Et le verglas multiplie par 3 les risques d'accident de voiture...", "expression": "inquiet"},
			{"text": "Préparez-vous avant que la neige arrive. Quels sont les risques principaux à couvrir ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "tempete",
				"probability": 0.95,
				"narrative": "Une violente tempête arrache une partie de votre toiture et détruit la gouttière. Les réparations sont urgentes.",
			},
			{
				"type": "inondation",
				"probability": 0.60,
				"narrative": "Les pluies torrentielles font déborder la rivière voisine. Votre cave est inondée et plusieurs biens endommagés.",
			},
			{
				"type": "accident_voiture",
				"probability": 0.55,
				"narrative": "Le verglas fait déraper votre voiture. Vous emboutissez un poteau. Personne n'est blessé, mais le véhicule est cabossé.",
			},
		],
		"prevention_tips": [
			{"tip": "Élaguez les arbres proches de votre maison chaque automne", "emoji": "🌳"},
			{"tip": "Élevez vos appareils électriques en zone inondable", "emoji": "📦"},
			{"tip": "Évitez toute distraction au volant", "emoji": "📵"},
		],
		"recommended_contracts": ["catastrophe", "auto"],
	},
	# --- Chapitre 3 : Vie active ---
	{
		"id": 3,
		"titre": "Vie active",
		"emoji": "💼",
		"contexte": "Vous êtes lancé dans votre carrière. Sport régulier, longues journées, déplacements fréquents... le rythme s'accélère.",
		"resume": "Votre rythme de vie s'accélère : boulot, sport, sorties.",
		"gold_budget": 220,
		"intro": [
			{"text": "Votre vie bat à plein régime ! Travail, sport, sorties... bravo pour cette énergie.", "expression": "souriant"},
			{"text": "Mais avec un emploi du temps chargé, les accidents du quotidien sont plus fréquents.", "expression": "normal"},
			{"text": "Une entorse au sport, un vélo qui disparaît à la gare, un accrochage en voiture...", "expression": "inquiet"},
			{"text": "Mieux vaut prévoir. Quels contrats seraient les plus utiles à votre rythme de vie ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "blessure",
				"probability": 0.75,
				"narrative": "Lors de votre match de football hebdomadaire, vous vous fracturez le poignet. Urgences, radio, plâtre...",
			},
			{
				"type": "vol_velo",
				"probability": 0.55,
				"narrative": "Votre vélo, garé devant la gare, a disparu en fin de journée. L'antivol a été coupé.",
			},
			{
				"type": "accident_voiture",
				"probability": 0.50,
				"narrative": "Distrait par une notification sur votre téléphone, vous grillez un feu rouge. Accrochage avec un scooter.",
			},
		],
		"prevention_tips": [
			{"tip": "Portez des équipements de protection adaptés", "emoji": "⛑️"},
			{"tip": "Cadenassez votre vélo à un point fixe avec un antivol U", "emoji": "🔐"},
			{"tip": "Respectez les distances de sécurité", "emoji": "🚗"},
		],
		"recommended_contracts": ["accidents_vie", "auto", "velo"],
	},
	# --- Chapitre 4 : Été à risque ---
	{
		"id": 4,
		"titre": "Été à risque",
		"emoji": "🔥",
		"contexte": "Grande chaleur, maison laissée vide pour les vacances, feux de forêt dans la région... cet été met vos biens à l'épreuve.",
		"resume": "L'été commence. Vacances, chaleur, maison vide.",
		"gold_budget": 190,
		"intro": [
			{"text": "L'été est là ! Mais avec la chaleur arrivent aussi les risques...", "expression": "normal"},
			{"text": "Maison vide pendant les vacances = cible idéale pour les cambrioleurs.", "expression": "inquiet"},
			{"text": "Et la canicule augmente fortement les risques d'incendie, surtout dans le Midi.", "expression": "inquiet"},
			{"text": "Avant de partir en vacances, faites le point sur votre couverture prioritaire.", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "incendie",
				"probability": 0.80,
				"narrative": "Un feu de garrigue approche votre résidence secondaire. Les flammes abîment la terrasse et le cabanon.",
			},
			{
				"type": "cambriolage",
				"probability": 0.70,
				"narrative": "Pendant vos 3 semaines de vacances, des cambrioleurs visitent votre appartement. Bijoux et consoles disparaissent.",
			},
			{
				"type": "degats_des_eaux",
				"probability": 0.35,
				"narrative": "Un tuyau d'arrosage automatique mal réglé inonde votre terrasse et s'infiltre chez le voisin du dessous.",
			},
			{
				"type": "litige",
				"probability": 0.45,
				"narrative": "Le voisin du dessous, excédé par les dégâts, vous menace de poursuites pour préjudice.",
			},
		],
		"prevention_tips": [
			{"tip": "Gardez un extincteur accessible dans la cuisine", "emoji": "🧯"},
			{"tip": "Ne laissez jamais de clé cachée dehors", "emoji": "🗝️"},
			{"tip": "Fermez bien les robinets avant de partir", "emoji": "🚿"},
		],
		"recommended_contracts": ["habitation", "protection_juridique"],
	},
	# --- Chapitre 5 : L'année noire ---
	{
		"id": 5,
		"titre": "L'année noire",
		"emoji": "🌊",
		"contexte": "La loi des séries frappe. Cette année cumule les coups durs. C'est le grand test de votre couverture assurantielle.",
		"resume": "Une mauvaise année. Plusieurs coups durs peuvent s'enchaîner.",
		"gold_budget": 250,
		"intro": [
			{"text": "Je dois être franc avec vous : cette année s'annonce difficile.", "expression": "inquiet"},
			{"text": "Plusieurs événements graves peuvent survenir en peu de temps.", "expression": "inquiet"},
			{"text": "C'est exactement dans ces moments-là que l'assurance fait toute la différence.", "expression": "normal"},
			{"text": "Prenez le temps de bien choisir. Quels sont les contrats les plus critiques pour cette année ?", "expression": "fier"},
		],
		"disasters": [
			{
				"type": "inondation",
				"probability": 1.0,
				"narrative": "Des pluies exceptionnelles causent des inondations historiques dans votre quartier. Le rez-de-chaussée est submergé.",
			},
			{
				"type": "accident_voiture",
				"probability": 1.0,
				"narrative": "Sur l'autoroute, un pneu éclate. Votre voiture dérape et heurte le rail de sécurité. La carrosserie est détruite.",
			},
			{
				"type": "incendie",
				"probability": 0.70,
				"narrative": "Un court-circuit dans le tableau électrique déclenche un incendie dans la nuit. Les pompiers sauvent l'essentiel.",
			},
			{
				"type": "blessure",
				"probability": 0.60,
				"narrative": "En aidant les voisins à pomper l'eau de la cave, vous glissez et vous cassez la cheville.",
			},
		],
		"prevention_tips": [
			{"tip": "Élevez vos appareils électriques en zone inondable", "emoji": "📦"},
			{"tip": "Vérifiez vos pneus et freins régulièrement", "emoji": "🔧"},
			{"tip": "Ne laissez jamais de bougies sans surveillance", "emoji": "🕯️"},
			{"tip": "Gardez une trousse de premiers secours chez vous", "emoji": "🏥"},
		],
		"recommended_contracts": ["auto", "habitation", "catastrophe", "accidents_vie"],
	},
	# --- Chapitre 6 : Premier vélo neuf ---
	{
		"id": 6,
		"titre": "Premier vélo neuf",
		"emoji": "🚲",
		"contexte": "Vous venez d'acheter un vélo neuf pour vos trajets quotidiens. Liberté, écologie, et un peu de sport !",
		"resume": "Vous achetez un vélo neuf pour aller au travail.",
		"gold_budget": 80,
		"intro": [
			{"text": "Joli vélo ! Plus économique et écologique que la voiture pour les petits trajets.", "expression": "souriant"},
			{"text": "Mais en ville, le vol de vélo est un des sinistres les plus fréquents.", "expression": "inquiet"},
			{"text": "Un antivol seul ne suffit pas toujours — surtout devant la gare ou le bureau.", "expression": "normal"},
			{"text": "Pensez à le couvrir pour rouler tranquille.", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "vol_velo",
				"probability": 0.80,
				"narrative": "Vous retournez à votre vélo le soir : il n'est plus là. L'antivol a été sectionné.",
			},
		],
		"prevention_tips": [
			{"tip": "Utilisez un antivol U de qualité, fixé à un point fixe", "emoji": "🔐"},
			{"tip": "Gravez votre vélo pour faciliter sa restitution en cas de retrouvaille", "emoji": "🪪"},
		],
		"recommended_contracts": ["velo"],
	},
	# --- Chapitre 7 : Voisin difficile ---
	{
		"id": 7,
		"titre": "Voisin difficile",
		"emoji": "🏘️",
		"contexte": "Votre voisin du dessus enchaîne les fêtes et les travaux à des heures impossibles. La situation s'envenime...",
		"resume": "Un voisin perturbe votre quotidien.",
		"gold_budget": 100,
		"intro": [
			{"text": "Les conflits de voisinage sont parmi les premières sources de litige en France.", "expression": "normal"},
			{"text": "Nuisances sonores, désaccords sur les charges, dégâts mutuels...", "expression": "inquiet"},
			{"text": "Sans accompagnement juridique, ces affaires peuvent vite tourner au cauchemar.", "expression": "inquiet"},
			{"text": "Quel contrat vous aiderait à défendre vos droits ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "litige",
				"probability": 0.85,
				"narrative": "Le conflit dégénère : courriers d'huissier, médiation refusée. Vous devez aller en justice.",
			},
		],
		"prevention_tips": [
			{"tip": "Privilégiez le dialogue et la médiation avant toute action", "emoji": "🤝"},
			{"tip": "Gardez une trace écrite des nuisances (mails, lettres)", "emoji": "📝"},
		],
		"recommended_contracts": ["protection_juridique"],
	},
	# --- Chapitre 8 : Premier marathon ---
	{
		"id": 8,
		"titre": "Premier marathon",
		"emoji": "🏃",
		"contexte": "Vous vous lancez le défi de votre premier marathon. Entraînements intensifs et longues sorties au programme.",
		"resume": "Vous préparez votre premier marathon.",
		"gold_budget": 120,
		"intro": [
			{"text": "Bravo pour ce défi ! Le marathon, c'est 42 km de plaisir... et de risques.", "expression": "souriant"},
			{"text": "Tendinites, fractures de fatigue, chutes : le sport intensif est exigeant.", "expression": "inquiet"},
			{"text": "Une blessure peut vite entraîner des soins coûteux et des arrêts de travail.", "expression": "normal"},
			{"text": "Comment vous protéger sans freiner votre passion ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "blessure",
				"probability": 0.85,
				"narrative": "Lors d'une sortie longue, une mauvaise chute vous occasionne une fracture du poignet et trois mois d'arrêt.",
			},
		],
		"prevention_tips": [
			{"tip": "Adaptez progressivement votre charge d'entraînement", "emoji": "📈"},
			{"tip": "Hydratez-vous et étirez-vous systématiquement", "emoji": "💧"},
		],
		"recommended_contracts": ["accidents_vie"],
	},
	# --- Chapitre 9 : Route de nuit ---
	{
		"id": 9,
		"titre": "Route de nuit",
		"emoji": "🌙",
		"contexte": "Long trajet de nuit pour rejoindre votre famille. Fatigue, brouillard et animaux sauvages au programme.",
		"resume": "Vous prenez la route de nuit sur un long trajet.",
		"gold_budget": 180,
		"intro": [
			{"text": "Conduire de nuit, c'est doubler les risques d'accident.", "expression": "inquiet"},
			{"text": "Fatigue, visibilité réduite, sangliers traversant les routes...", "expression": "inquiet"},
			{"text": "Et en cas de choc, blessures et dommages au véhicule peuvent s'additionner.", "expression": "normal"},
			{"text": "Quelles couvertures privilégier pour ce trajet ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "accident_voiture",
				"probability": 0.75,
				"narrative": "Un sanglier surgit sur la voie. Vous freinez fort, partez en tête-à-queue et heurtez le rail. La voiture est sérieusement endommagée.",
			},
			{
				"type": "blessure",
				"probability": 0.55,
				"narrative": "Le choc vous laisse avec un coup du lapin et trois semaines d'arrêt de travail.",
			},
		],
		"prevention_tips": [
			{"tip": "Faites des pauses toutes les 2 heures", "emoji": "☕"},
			{"tip": "Évitez les routes connues pour le passage d'animaux la nuit", "emoji": "🦌"},
		],
		"recommended_contracts": ["auto", "accidents_vie"],
	},
	# --- Chapitre 10 : Orage soudain ---
	{
		"id": 10,
		"titre": "Orage soudain",
		"emoji": "⚡",
		"contexte": "Un orage violent s'abat sur votre région en pleine nuit. Pluies torrentielles et grêle au menu.",
		"resume": "Un orage violent éclate sur votre région.",
		"gold_budget": 160,
		"intro": [
			{"text": "Les orages violents peuvent causer des dégâts considérables en quelques minutes.", "expression": "inquiet"},
			{"text": "Toitures arrachées, infiltrations, grêle qui démolit les volets...", "expression": "inquiet"},
			{"text": "Et après la tempête, les fuites internes qui empirent les choses.", "expression": "normal"},
			{"text": "Quels contrats couvrent ces deux fronts ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "tempete",
				"probability": 0.90,
				"narrative": "Les vents violents arrachent des tuiles et endommagent la cheminée. La pluie s'engouffre dans les combles.",
			},
			{
				"type": "degats_des_eaux",
				"probability": 0.65,
				"narrative": "L'eau infiltrée à travers le toit endommage le plafond du salon et le parquet en dessous.",
			},
		],
		"prevention_tips": [
			{"tip": "Faites vérifier votre toiture tous les 5 ans", "emoji": "🏠"},
			{"tip": "Sécurisez le mobilier de jardin avant l'orage", "emoji": "🪑"},
		],
		"recommended_contracts": ["catastrophe", "habitation"],
	},
	# --- Chapitre 11 : Cambriolage et procès ---
	{
		"id": 11,
		"titre": "Cambriolage et procès",
		"emoji": "🚓",
		"contexte": "Votre appartement est cambriolé. Les voleurs sont identifiés par la police, mais le procès s'annonce long.",
		"resume": "Cambriolage suivi d'un long procès.",
		"gold_budget": 190,
		"intro": [
			{"text": "Quand un cambriolage tourne en affaire judiciaire, les coûts explosent.", "expression": "inquiet"},
			{"text": "D'abord les biens volés à remplacer, puis les frais de justice à avancer.", "expression": "normal"},
			{"text": "Sans accompagnement, défendre vos intérêts au tribunal devient un parcours du combattant.", "expression": "inquiet"},
			{"text": "Quels contrats permettent de tout encaisser ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "cambriolage",
				"probability": 0.95,
				"narrative": "Le cambriolage emporte ordinateur, montres, bijoux. Les serrures et la porte sont à remplacer.",
			},
			{
				"type": "litige",
				"probability": 0.70,
				"narrative": "Le procès traîne. Avocats, expertises, recours : la facture juridique s'accumule.",
			},
		],
		"prevention_tips": [
			{"tip": "Photographiez vos objets de valeur (preuve d'achat utile)", "emoji": "📸"},
			{"tip": "Installez une alarme reliée à un centre de télésurveillance", "emoji": "🚨"},
		],
		"recommended_contracts": ["habitation", "protection_juridique"],
	},
	# --- Chapitre 12 : Road-trip d'été ---
	{
		"id": 12,
		"titre": "Road-trip d'été",
		"emoji": "🗺️",
		"contexte": "Trois semaines de road-trip à travers la France. Hôtels, restaurants, randonnées, et beaucoup de route au compteur.",
		"resume": "Vous partez en road-trip de 3 semaines.",
		"gold_budget": 220,
		"intro": [
			{"text": "Un road-trip, c'est l'aventure ! Mais aussi une exposition prolongée à de multiples risques.", "expression": "normal"},
			{"text": "Routes inconnues, hôtels surbookés, restaurants douteux, randonnées techniques...", "expression": "normal"},
			{"text": "Un seul incident peut faire dérailler tout le voyage.", "expression": "inquiet"},
			{"text": "Comment vous couvrir sur tous les fronts ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "accident_voiture",
				"probability": 0.65,
				"narrative": "Sur une route de montagne, vous évitez de justesse un véhicule en sens inverse. L'aile est froissée contre la paroi.",
			},
			{
				"type": "blessure",
				"probability": 0.55,
				"narrative": "Lors d'une randonnée, une glissade vous occasionne une entorse sévère. Évacuation et urgences.",
			},
			{
				"type": "litige",
				"probability": 0.40,
				"narrative": "Un hôtelier refuse de rembourser une réservation annulée alors que la chambre était insalubre.",
			},
		],
		"prevention_tips": [
			{"tip": "Vérifiez l'état de votre voiture avant un long trajet", "emoji": "🔧"},
			{"tip": "Portez des chaussures adaptées en randonnée", "emoji": "🥾"},
			{"tip": "Conservez tous vos justificatifs de réservation", "emoji": "📄"},
		],
		"recommended_contracts": ["auto", "accidents_vie", "protection_juridique"],
	},
	# --- Chapitre 13 : Vie en colocation ---
	{
		"id": 13,
		"titre": "Vie en colocation",
		"emoji": "👥",
		"contexte": "Vous emménagez en colocation pour vos études. Trois colocs, un appartement... et beaucoup de désordre potentiel.",
		"resume": "Vous emménagez en colocation à 3.",
		"gold_budget": 140,
		"intro": [
			{"text": "La colocation, c'est génial — mais juridiquement et matériellement compliqué.", "expression": "normal"},
			{"text": "Dégâts des eaux causés par un coloc, vol par un visiteur, désaccord sur le ménage...", "expression": "inquiet"},
			{"text": "Et qui paie quoi quand quelque chose se casse ?", "expression": "normal"},
			{"text": "Quels contrats sécurisent cette vie en groupe ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "degats_des_eaux",
				"probability": 0.75,
				"narrative": "Une fuite de la machine à laver inonde la cuisine et s'infiltre chez le voisin du dessous.",
			},
			{
				"type": "litige",
				"probability": 0.55,
				"narrative": "L'un des colocs part sans payer sa part. Vous vous retrouvez à devoir avancer plusieurs centaines d'euros.",
			},
		],
		"prevention_tips": [
			{"tip": "Établissez un contrat de colocation clair avec répartition des charges", "emoji": "📝"},
			{"tip": "Faites un état des lieux d'entrée précis", "emoji": "📋"},
		],
		"recommended_contracts": ["habitation", "protection_juridique"],
	},
	# --- Chapitre 14 : Sortie vélo en groupe ---
	{
		"id": 14,
		"titre": "Sortie vélo en groupe",
		"emoji": "🚴",
		"contexte": "Une sortie vélo de 100 km avec un groupe d'amis. Cols, descentes rapides, et une pause au restaurant en fin de parcours.",
		"resume": "Sortie vélo longue distance entre amis.",
		"gold_budget": 200,
		"intro": [
			{"text": "Une grosse sortie vélo, c'est l'occasion de cumuler les risques.", "expression": "normal"},
			{"text": "Chute en descente, vélo volé pendant la pause déjeuner, désaccord sur l'addition...", "expression": "inquiet"},
			{"text": "Plus le groupe est grand, plus la coordination devient compliquée.", "expression": "inquiet"},
			{"text": "Quels contrats vous protègent vraiment ?", "expression": "normal"},
		],
		"disasters": [
			{
				"type": "blessure",
				"probability": 0.65,
				"narrative": "Dans une descente technique, une chute vous expédie aux urgences avec une fracture de la clavicule.",
			},
			{
				"type": "vol_velo",
				"probability": 0.50,
				"narrative": "Pendant la pause au restaurant, votre vélo disparaît malgré l'antivol attaché à la table.",
			},
			{
				"type": "litige",
				"probability": 0.30,
				"narrative": "Un coureur du groupe vous accuse d'avoir causé sa chute. Sa famille engage des poursuites.",
			},
		],
		"prevention_tips": [
			{"tip": "Portez systématiquement un casque homologué", "emoji": "⛑️"},
			{"tip": "Ne quittez jamais votre vélo des yeux dans les zones touristiques", "emoji": "👁️"},
		],
		"recommended_contracts": ["velo", "accidents_vie", "protection_juridique"],
	},
]

func get_chapitre(id: int) -> Dictionary:
	if id < 0 or id >= CHAPITRES.size():
		return {}
	return CHAPITRES[id]

func count() -> int:
	return CHAPITRES.size()
