import type { DisasterType } from "../../shared/models/Disaster";
import type { PreventionTip } from "../models/Chapitre";

export const PREVENTION_TIPS: Record<DisasterType, PreventionTip[]> = {
  accident_voiture: [
    { disasterType: "accident_voiture", tip: "Respectez les distances de sécurité", emoji: "🚗" },
    { disasterType: "accident_voiture", tip: "Vérifiez vos pneus et freins régulièrement", emoji: "🔧" },
    { disasterType: "accident_voiture", tip: "Évitez toute distraction au volant", emoji: "📵" },
  ],
  degats_des_eaux: [
    { disasterType: "degats_des_eaux", tip: "Fermez bien les robinets avant de partir", emoji: "🚿" },
    { disasterType: "degats_des_eaux", tip: "Installez un détecteur de fuite d'eau", emoji: "💧" },
    { disasterType: "degats_des_eaux", tip: "Faites inspecter vos canalisations chaque année", emoji: "🔍" },
  ],
  incendie: [
    { disasterType: "incendie", tip: "Installez un détecteur de fumée (obligation légale)", emoji: "🔔" },
    { disasterType: "incendie", tip: "Gardez un extincteur accessible dans la cuisine", emoji: "🧯" },
    { disasterType: "incendie", tip: "Ne laissez jamais de bougies sans surveillance", emoji: "🕯️" },
  ],
  blessure: [
    { disasterType: "blessure", tip: "Portez des équipements de protection adaptés", emoji: "⛑️" },
    { disasterType: "blessure", tip: "Gardez une trousse de premiers secours chez vous", emoji: "🏥" },
    { disasterType: "blessure", tip: "Pratiquez le sport progressivement et en sécurité", emoji: "🏃" },
  ],
  cambriolage: [
    { disasterType: "cambriolage", tip: "Installez une serrure 3 points certifiée", emoji: "🔐" },
    { disasterType: "cambriolage", tip: "Ne laissez jamais de clé cachée dehors", emoji: "🗝️" },
    { disasterType: "cambriolage", tip: "Équipez-vous d'une alarme ou d'un simulateur de présence", emoji: "🚨" },
  ],
  vol_vehicule: [
    { disasterType: "vol_vehicule", tip: "Utilisez un antivol visible en plus du système de série", emoji: "⛓️" },
    { disasterType: "vol_vehicule", tip: "Garez-vous dans des zones éclairées et surveillées", emoji: "💡" },
    { disasterType: "vol_vehicule", tip: "Ne laissez jamais d'objets visibles à l'intérieur", emoji: "👀" },
  ],
  inondation: [
    { disasterType: "inondation", tip: "Élevez vos appareils électriques en zone inondable", emoji: "📦" },
    { disasterType: "inondation", tip: "Installez un clapet anti-retour sur les canalisations", emoji: "🔩" },
    { disasterType: "inondation", tip: "Consultez la carte des zones inondables avant d'acheter", emoji: "🗺️" },
  ],
  tempete: [
    { disasterType: "tempete", tip: "Élaguez les arbres proches de votre maison chaque automne", emoji: "🌳" },
    { disasterType: "tempete", tip: "Vérifiez l'état de votre toiture et des gouttières", emoji: "🏠" },
    { disasterType: "tempete", tip: "Rentrez ou fixez les objets extérieurs avant une tempête", emoji: "⚠️" },
  ],
};
