import type { Chapitre } from "../models/Chapitre";
import { PREVENTION_TIPS } from "./preventionConfig";

export const CHAPITRES: Chapitre[] = [
  {
    id: 0,
    titre: "Premier véhicule",
    emoji: "🚗",
    contexte: "Vous venez d'obtenir votre permis et d'acheter votre première voiture. La liberté, enfin ! Mais la route peut réserver des surprises...",
    goldBudget: 180,
    intro: [
      { text: "Bonjour ! Je suis votre conseiller MAIF. Bienvenue dans votre parcours assurantiel !", expression: "souriant" },
      { text: "Vous venez d'acheter votre premier véhicule. C'est une étape importante de la vie !", expression: "souriant" },
      { text: "Mais la route peut être imprévisible... Un accident ou un vol peuvent coûter très cher.", expression: "inquiet" },
      { text: "Avant de prendre la route, gérez vos assurances. Choisissez le contrat le plus adapté !", expression: "normal" },
    ],
    disasters: [
      {
        type: "accident_voiture",
        probability: 0.85,
        narrative: "En rentrant du travail, vous percutez un autre véhicule à un carrefour. Les dégâts sont importants.",
      },
      {
        type: "vol_vehicule",
        probability: 0.45,
        narrative: "Vous trouvez votre place de parking vide le matin. Votre voiture a été volée dans la nuit.",
      },
    ],
    preventionTips: [
      PREVENTION_TIPS.accident_voiture[0],
      PREVENTION_TIPS.vol_vehicule[0],
    ],
    recommendedContracts: ["auto"],
  },
  {
    id: 1,
    titre: "Nouvel appartement",
    emoji: "🏠",
    contexte: "Vous emménagez dans votre premier appartement. Cartons, meubles IKEA et... risques en tous genres pour votre nouveau chez-vous.",
    goldBudget: 200,
    intro: [
      { text: "Félicitations pour votre nouvel appartement ! C'est votre chez-vous désormais.", expression: "souriant" },
      { text: "Un logement, ça apporte aussi des responsabilités. Les sinistres domestiques sont très fréquents.", expression: "normal" },
      { text: "Dégâts des eaux, incendie, cambriolage... un locataire peut être responsable des dégâts causés aux voisins !", expression: "inquiet" },
      { text: "Pensez à vous couvrir avant d'y dormir. Quel contrat choisiriez-vous ?", expression: "normal" },
    ],
    disasters: [
      {
        type: "degats_des_eaux",
        probability: 0.90,
        narrative: "Un joint de robinet cède pendant votre sommeil. Le parquet est inondé et les voisins du dessous se plaignent.",
      },
      {
        type: "cambriolage",
        probability: 0.50,
        narrative: "Vous rentrez de vacances pour trouver votre appartement sens dessus dessous. Tout votre matériel électronique a disparu.",
      },
      {
        type: "incendie",
        probability: 0.30,
        narrative: "Une casserole oubliée sur le feu provoque un incendie dans la cuisine. Les pompiers interviennent.",
      },
    ],
    preventionTips: [
      PREVENTION_TIPS.degats_des_eaux[0],
      PREVENTION_TIPS.incendie[0],
      PREVENTION_TIPS.cambriolage[0],
    ],
    recommendedContracts: ["habitation"],
  },
  {
    id: 2,
    titre: "Hiver difficile",
    emoji: "🌧️",
    contexte: "Cet hiver est particulièrement rude. Tempêtes, inondations et routes verglacées mettent votre quotidien à l'épreuve.",
    goldBudget: 160,
    intro: [
      { text: "Cet hiver s'annonce difficile. Les météorologues prévoient des tempêtes répétées.", expression: "inquiet" },
      { text: "Les catastrophes naturelles comme les tempêtes et inondations ne sont pas rares en France.", expression: "normal" },
      { text: "Et le verglas multiplie par 3 les risques d'accident de voiture...", expression: "inquiet" },
      { text: "Préparez-vous avant que la neige arrive. Quel est le risque principal à couvrir ?", expression: "normal" },
    ],
    disasters: [
      {
        type: "tempete",
        probability: 0.95,
        narrative: "Une violente tempête arrache une partie de votre toiture et détruit la gouttière. Les réparations sont urgentes.",
      },
      {
        type: "inondation",
        probability: 0.60,
        narrative: "Les pluies torrentielles font déborder la rivière voisine. Votre cave est inondée et plusieurs biens endommagés.",
      },
      {
        type: "accident_voiture",
        probability: 0.55,
        narrative: "Le verglas fait déraper votre voiture. Vous emboutissez un poteau. Personne n'est blessé, mais le véhicule est cabossé.",
      },
    ],
    preventionTips: [
      PREVENTION_TIPS.tempete[0],
      PREVENTION_TIPS.inondation[0],
      PREVENTION_TIPS.accident_voiture[2],
    ],
    recommendedContracts: ["catastrophe", "auto"],
  },
  {
    id: 3,
    titre: "Vie active",
    emoji: "💼",
    contexte: "Vous êtes lancé dans votre carrière. Sport régulier, longues journées, déplacements fréquents... le rythme s'accélère.",
    goldBudget: 220,
    intro: [
      { text: "Votre vie bat à plein régime ! Travail, sport, sorties... bravo pour cette énergie.", expression: "souriant" },
      { text: "Mais avec un emploi du temps chargé, les accidents du quotidien sont plus fréquents.", expression: "normal" },
      { text: "Une entorse au sport, un vol de sac dans le métro, un accrochage en voiture...", expression: "inquiet" },
      { text: "Mieux vaut prévoir. Quel contrat serait le plus utile à votre rythme de vie ?", expression: "normal" },
    ],
    disasters: [
      {
        type: "blessure",
        probability: 0.75,
        narrative: "Lors de votre match de football hebdomadaire, vous vous fracturez le poignet. Urgences, radio, plâtre...",
      },
      {
        type: "vol_vehicule",
        probability: 0.40,
        narrative: "Votre voiture garée devant le bureau a été forcée et votre ordinateur professionnel volé à l'intérieur.",
      },
      {
        type: "accident_voiture",
        probability: 0.50,
        narrative: "Distrait par une notification sur votre téléphone, vous grillé un feu rouge. Accrochage avec un scooter.",
      },
    ],
    preventionTips: [
      PREVENTION_TIPS.blessure[0],
      PREVENTION_TIPS.vol_vehicule[2],
      PREVENTION_TIPS.accident_voiture[0],
    ],
    recommendedContracts: ["sante", "auto", "vol"],
  },
  {
    id: 4,
    titre: "Été à risque",
    emoji: "🔥",
    contexte: "Grande chaleur, maison laissée vide pour les vacances, feux de forêt dans la région... cet été met vos biens à l'épreuve.",
    goldBudget: 190,
    intro: [
      { text: "L'été est là ! Mais avec la chaleur arrivent aussi les risques...", expression: "normal" },
      { text: "Maison vide pendant les vacances = cible idéale pour les cambrioleurs.", expression: "inquiet" },
      { text: "Et la canicule augmente fortement les risques d'incendie, surtout dans le Midi.", expression: "inquiet" },
      { text: "Avant de partir en vacances, faites le point sur votre couverture prioritaire.", expression: "normal" },
    ],
    disasters: [
      {
        type: "incendie",
        probability: 0.80,
        narrative: "Un feu de garrigue approche votre résidence secondaire. Les flammes abîment la terrasse et le cabanon.",
      },
      {
        type: "cambriolage",
        probability: 0.70,
        narrative: "Pendant vos 3 semaines de vacances, des cambrioleurs visitent votre appartement. Bijoux et consoles disparaissent.",
      },
      {
        type: "degats_des_eaux",
        probability: 0.35,
        narrative: "Un tuyau d'arrosage automatique mal réglé inonde votre terrasse et s'infiltre chez le voisin du dessous.",
      },
    ],
    preventionTips: [
      PREVENTION_TIPS.incendie[1],
      PREVENTION_TIPS.cambriolage[1],
      PREVENTION_TIPS.degats_des_eaux[0],
    ],
    recommendedContracts: ["habitation", "vol"],
  },
  {
    id: 5,
    titre: "L'année noire",
    emoji: "🌊",
    contexte: "La loi des séries frappe. Cette année cumule les coups durs. C'est le grand test de votre couverture assurantielle.",
    goldBudget: 250,
    intro: [
      { text: "Je dois être franc avec vous : cette année s'annonce difficile.", expression: "inquiet" },
      { text: "Plusieurs événements graves peuvent survenir en peu de temps.", expression: "inquiet" },
      { text: "C'est exactement dans ces moments-là que l'assurance fait toute la différence.", expression: "normal" },
      { text: "Prenez le temps de bien choisir. Quel est le contrat le plus critique pour cette année ?", expression: "fier" },
    ],
    disasters: [
      {
        type: "inondation",
        probability: 1.0,
        narrative: "Des pluies exceptionnelles causent des inondations historiques dans votre quartier. Le rez-de-chaussée est submergé.",
      },
      {
        type: "accident_voiture",
        probability: 1.0,
        narrative: "Sur l'autoroute, un pneu éclate. Votre voiture dérape et heurte le rail de sécurité. La carrosserie est détruite.",
      },
      {
        type: "incendie",
        probability: 0.70,
        narrative: "Un court-circuit dans le tableau électrique déclenche un incendie dans la nuit. Les pompiers sauvent l'essentiel.",
      },
      {
        type: "blessure",
        probability: 0.60,
        narrative: "En aidant les voisins à pomper l'eau de la cave, vous glissez et vous cassez la cheville.",
      },
    ],
    preventionTips: [
      PREVENTION_TIPS.inondation[0],
      PREVENTION_TIPS.accident_voiture[1],
      PREVENTION_TIPS.incendie[2],
      PREVENTION_TIPS.blessure[1],
    ],
    recommendedContracts: ["auto", "habitation", "catastrophe", "sante"],
  },
];
