# Kenney Racing Kit — Statut des assets

Source : https://kenney.nl/assets/racing-kit (CC0)
Importé le 2026-05-15 dans `models/kenney/`.

Légende :
- ✅ **Utilisé** dans une scène ou un script
- ⏳ **Réservé** pour un usage planifié (mais pas encore intégré)
- ⬜ **Non utilisé** — supprimable si le visuel final ne le requiert pas

## Véhicules (4)
- ✅ `raceCarGreen.glb` — Joueur (couleur Vert)
- ✅ `raceCarOrange.glb` — Joueur (couleur Orange)
- ✅ `raceCarRed.glb` — Joueur (couleur Rouge)
- ✅ `raceCarWhite.glb` — Joueur (couleur Blanc)

## Pistes (road) — utilisé pour la mécanique
- ✅ `roadStraightArrow.glb` — Zone de boost (remplace l'ancien rectangle vert)

## Pistes (road) — réservées pour la refonte de la piste GridMap
- ⏳ `roadStraight.glb`, `roadStraightLong.glb`, `roadStraightLongMid.glb`
- ⏳ `roadStraightLongBump.glb`, `roadStraightLongBumpRound.glb`
- ⏳ `roadStraightSkew.glb`, `roadStraightBridge.glb`, `roadStraightBridgeMid.glb`, `roadStraightBridgeStart.glb`
- ⏳ `roadCornerSmall.glb`, `roadCornerLarge.glb`, `roadCornerLarger.glb`
- ⏳ `roadCornerSmallBorder.glb`, `roadCornerLargeBorder.glb`, `roadCornerLargerBorder.glb`
- ⏳ `roadCornerSmallWall.glb`, `roadCornerLargeWall.glb`, `roadCornerLargerWall.glb`
- ⏳ `roadCornerSmallSand.glb`, `roadCornerLargeSand.glb`, `roadCornerLargerSand.glb`
- ⏳ `roadCornerLargeBorderInner.glb`, `roadCornerLargerBorderInner.glb`
- ⏳ `roadCornerLargeWallInner.glb`, `roadCornerLargerWallInner.glb`
- ⏳ `roadCornerLargeSandInner.glb`, `roadCornerLargerSandInner.glb`
- ⏳ `roadCornerSmallSquare.glb`
- ⏳ `roadCornerBridgeSmall.glb`, `roadCornerBridgeLarge.glb`, `roadCornerBridgeLarger.glb`
- ⏳ `roadCurved.glb`, `roadCurvedSplit.glb`
- ⏳ `roadCrossing.glb`
- ⏳ `roadSplit.glb`, `roadSplitLarge.glb`, `roadSplitLarger.glb`, `roadSplitSmall.glb`
- ⏳ `roadSplitRound.glb`, `roadSplitRoundLarge.glb`
- ⏳ `roadStart.glb`, `roadStartPositions.glb`, `roadEnd.glb`, `roadSide.glb`
- ⏳ `roadPitEntry.glb`, `roadPitStraight.glb`, `roadPitStraightLong.glb`, `roadPitGarage.glb`
- ⏳ `roadRamp.glb`, `roadRampLong.glb`, `roadRampLongCurved.glb`
- ⏳ `roadRampWall.glb`, `roadRampLongWall.glb`, `roadRampLongCurvedWall.glb`
- ⏳ `roadBump.glb`

## Décor de circuit — utilisé dans race.tscn
- ✅ `treeLarge.glb` — Arbres en bordure
- ✅ `treeSmall.glb` — Arbres en bordure
- ✅ `grandStand.glb` — Gradins basiques
- ✅ `grandStandCovered.glb` — Gradins couverts
- ✅ `overhead.glb` — Arche au-dessus de la ligne de départ
- ✅ `lightPostLarge.glb` — Lampadaires
- ✅ `billboard.glb` — Panneau publicitaire
- ✅ `flagCheckersSmall.glb` — Drapeaux à damier
- ✅ `barrierRed.glb` — Barrières rouges
- ✅ `barrierWhite.glb` — Barrières blanches

## Décor disponible (non utilisé actuellement)
- ⬜ `grandStandAwning.glb`, `grandStandRound.glb`, `grandStandCoveredRound.glb`
- ⬜ `bannerTowerGreen.glb`, `bannerTowerRed.glb`
- ⬜ `pitsGarage.glb`, `pitsGarageClosed.glb`, `pitsGarageCorner.glb`
- ⬜ `pitsOffice.glb`, `pitsOfficeCorner.glb`, `pitsOfficeRoof.glb`
- ⬜ `overheadLights.glb`, `overheadRound.glb`, `overheadRoundColored.glb`
- ⬜ `billboardLow.glb`, `billboardLower.glb`, `billboardDouble_exclusive.glb`
- ⬜ `flagCheckers.glb`, `flagGreen.glb`, `flagRed.glb`, `flagTankco.glb`
- ⬜ `barrierWall.glb`, `rail.glb`, `railDouble.glb`
- ⬜ `fenceCurved.glb`, `fenceStraight.glb`
- ⬜ `lightPostModern.glb`, `lightPost_exclusive.glb`, `lightColored.glb`, `lightRed.glb`, `lightRedDouble.glb`
- ⬜ `tent.glb`, `tentClosed.glb`, `tentClosedLong.glb`, `tentLong.glb`, `tentRoof.glb`, `tentRoofDouble.glb`
- ⬜ `grass.glb`, `pylon.glb`, `radarEquipment.glb`, `ramp.glb`
- ⬜ `camera_exclusive.glb`

## Nettoyage suggéré

Une fois la migration complète (piste refondue avec les road tiles Kenney), on peut supprimer dans `models/` :
- `vehicle-truck-yellow.glb`, `vehicle-truck-green.glb`, `vehicle-truck-purple.glb`, `vehicle-truck-red.glb`
- `vehicle-motorcycle.glb`
- `track-straight.glb`, `track-corner.glb`, `track-bump.glb`, `track-finish.glb`, `track-tents.glb`
- `decoration-empty.glb`, `decoration-forest.glb`, `decoration-tents.glb`
- `collision-track-straight.fbx`, `collision-track-corner.fbx`
- `Library/mesh-library.tres`, `Library/mesh-library.tscn`
- `Textures/colormap.png` (si plus utilisée)

Et les fichiers de scène/script qui les référencent (vehicle-motorcycle.gd/tscn).
