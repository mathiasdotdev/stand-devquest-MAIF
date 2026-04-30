# Plan — Migration Godot : "Sortez Couvert" + "Grand Pasdetôlismo"

## Context

Le projet actuel `jeu-sortez-couvert` est en **Phaser 3 + TypeScript**. Le Mode Histoire fonctionne (6 chapitres validés, équilibrage simulé), mais le Mode Infini (runner) ne plaît plus. Le besoin :

1. Remplacer le Mode Infini par un **jeu de course** thématique MAIF ("Grand Pasdetôlismo") où le but est de **dépenser le moins** (réparations) plutôt que d'arriver premier.
2. Migrer le Mode Histoire ("Sortez Couvert") **de zéro** vers Godot, en s'inspirant du contenu/logique existants.
3. Réunir les 2 jeux dans **un seul projet Godot** avec un menu principal.
4. Cible : **événement médiéval/fantasy les 11-12 juin 2026** (≈ 6 semaines de dev à partir du 2026-04-29).

**Pourquoi Godot 4.6 + GDScript ?** Le user veut partir du [Kenney Starter-Kit-Racing](https://github.com/KenneyNL/Starter-Kit-Racing) (Godot 4.6, GDScript, voiture arcade prête). Phaser est jugé trop complexe pour l'animation. Godot apporte aussi : 3D out-of-the-box, scene tree intuitive, export Windows natif pour le PC du stand.

**Risque principal** : 6 semaines pour apprendre Godot + porter SC + bâtir Pasdetôlismo. Le plan compense via des **sprints d'1 semaine** terminant chacun par un build jouable. Si retard, on coupe du contenu, jamais des fondations.

---

## Tech & Project Structure

### Stack cible

- **Godot 4.6** (engine + IDE)
- **GDScript** (langage principal)
- **Kenney Starter-Kit-Racing** comme base de Pasdetôlismo
- **Git** : nouveau dossier `godot/` à la racine du repo. Le code Phaser actuel est **archivé** via tag `v1-phaser` puis supprimé du working tree à la fin du Sprint 2 (quand SC tourne en Godot).

### Arborescence

```
stand-devquest-MAIF/
├── README.md                 # mis à jour pour décrire les 2 jeux Godot
├── godot/                    # ⭐ projet Godot principal
│   ├── project.godot
│   ├── icon.svg
│   ├── main_menu/
│   │   ├── main_menu.tscn    # menu racine : 2 boutons + Quit
│   │   ├── main_menu.gd
│   │   └── theme.tres        # thème UI commun MAIF
│   ├── jeu_sortez_couvert/
│   │   ├── scenes/
│   │   │   ├── intro.tscn
│   │   │   ├── chapitre_intro.tscn
│   │   │   ├── contract_selection.tscn
│   │   │   ├── disaster_reveal.tscn
│   │   │   ├── chapitre_result.tscn
│   │   │   └── analysis.tscn
│   │   ├── scripts/
│   │   │   ├── story_engine.gd       # logique pure, port de StoryEngine.ts
│   │   │   └── (1 .gd par scène ci-dessus)
│   │   ├── ui/
│   │   │   ├── dialogue_box.tscn/.gd # typewriter
│   │   │   ├── contract_card.tscn/.gd
│   │   │   └── conseiller.tscn/.gd   # avatar 4 expressions
│   │   └── assets/
│   │       └── (icônes SVG, sprites conseiller)
│   ├── jeu_grand_pasdetolismo/
│   │   ├── scenes/
│   │   │   ├── pre_race.tscn          # sélection contrats + budget
│   │   │   ├── race.tscn              # circuit (basé sur Kenney)
│   │   │   ├── repair_stand.tscn      # popup au passage du stand
│   │   │   └── post_race.tscn         # score + leaderboard
│   │   ├── scripts/
│   │   │   ├── race_state.gd          # budget, dégâts, tours
│   │   │   ├── damage_system.gd
│   │   │   ├── obstacle.gd            # types : cone, branche, flaque, etc.
│   │   │   └── repair_stand.gd
│   │   ├── tracks/
│   │   │   ├── track_01.tscn          # GridMap dérivé du kit
│   │   │   └── track_02.tscn          # 2e map (S5 si temps)
│   │   └── assets/                    # depuis Kenney (CC0)
│   ├── shared/
│   │   ├── data/
│   │   │   ├── contracts.gd           # autoload : 5 contrats (CC0)
│   │   │   ├── disasters.gd           # autoload : 8 sinistres
│   │   │   └── chapitres.gd           # autoload : 6 chapitres
│   │   ├── persistence/
│   │   │   └── leaderboard.gd         # autoload : user://leaderboard.cfg
│   │   └── ui/
│   │       └── (boutons, fonts, palettes communs)
│   └── exports/                       # builds Windows (gitignore)
└── legacy-phaser/                     # AVANT suppression S2 — référence
```

### Autoloads (singletons) à déclarer dans `project.godot`

- `Contracts` → `shared/data/contracts.gd`
- `Disasters` → `shared/data/disasters.gd`
- `Chapitres` → `shared/data/chapitres.gd`
- `Leaderboard` → `shared/persistence/leaderboard.gd`

---

## Sortez Couvert — port en Godot

### Modèles de données (GDScript dictionaries dans autoloads)

**`shared/data/contracts.gd`** — 5 contrats (port direct de `contractsConfig.ts`) :

```gdscript
extends Node
const CONTRACTS = [
  { "type": "auto", "label": "Assurance Auto", "icon": "🚗",
    "covers": ["accident_voiture", "vol_vehicule"], "premium_basique": 14, "premium_premium": 24 },
  { "type": "habitation", "label": "Assurance Habitation", "icon": "🏠",
    "covers": ["degats_des_eaux", "incendie", "cambriolage"], "premium_basique": 11, "premium_premium": 19 },
  { "type": "sante", "label": "Assurance Santé", "icon": "🏥",
    "covers": ["blessure"], "premium_basique": 9, "premium_premium": 16 },
  { "type": "vol", "label": "Assurance Vol", "icon": "🔒",
    "covers": ["cambriolage", "vol_vehicule"], "premium_basique": 7, "premium_premium": 13 },
  { "type": "catastrophe", "label": "Catastrophe Naturelle", "icon": "🌊",
    "covers": ["inondation", "tempete"], "premium_basique": 6, "premium_premium": 11 },
]
func get_by_type(type: String) -> Dictionary: ...
```

**`shared/data/disasters.gd`** — 8 sinistres avec `base_damage` (port de `disastersConfig.ts`) : accident_voiture (80), degats_des_eaux (60), incendie (100), blessure (55), cambriolage (70), vol_vehicule (90), inondation (75), tempete (65).

**`shared/data/chapitres.gd`** — 6 chapitres (copie verbatim des textes français de `chapitresConfig.ts`, lignes 4-221). Chaque chapitre conserve : `id, titre, emoji, contexte, gold_budget, intro (lines + expression), disasters (type+probability+narrative), prevention_tips, recommended_contracts`.

### `story_engine.gd` — logique pure portée de `StoryEngine.ts`

Pas de couplage scene/UI. API :

- `toggle_contract(type) -> bool`
- `is_selected(type) -> bool`
- `use_hint() -> int` (max 2)
- `get_hint_text() -> String` (révèle sinistres niveau 1, contrats niveau 2)
- `resolve_current_chapitre() -> Dictionary` (= QuizAnswer)
- `next_chapitre() -> bool`
- `get_analysis() -> Dictionary`

**Formule de score** (à porter strictement, cf. `StoryEngine.ts:120-131`) :

```
correct_count = chosen ∩ recommended
wrong_count = chosen − recommended
total_needed = recommended.size()
base_score = max(0, round(correct_count * 3 / total_needed) - wrong_count)
score_earned = max(0, base_score - hints_used)
```

**Labels d'analyse** (cf. `StoryEngine.ts:178-200`) :

- ≥ 85% → "Expert MAIF"
- ≥ 65% → "Bon élève"
- ≥ 40% → "À améliorer"
- < 40% → "Débutant"

### Scènes (6, port direct du flow Phaser)

| #   | Scene                     | Rôle                                                                 | Inputs                              | Outputs / next                                                      |
| --- | ------------------------- | -------------------------------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------- |
| 1   | `intro.tscn`              | Présentation conseiller MAIF, 5 lignes de dialogue                   | clic / espace = next line           | → `chapitre_intro.tscn` (chapitre 0)                                |
| 2   | `chapitre_intro.tscn`     | Titre + contexte chapitre, dialogue intro                            | clic = skip, "Continuer"            | → `contract_selection.tscn`                                         |
| 3   | `contract_selection.tscn` | 5 cartes contrats togglables, 2 boutons "Indice", bouton "Confirmer" | toggle, hint, confirm               | → `disaster_reveal.tscn` (avec `engine.resolve_current_chapitre()`) |
| 4   | `disaster_reveal.tscn`    | Anime chaque sinistre tiré, badge vert/rouge                         | auto-advance après anims            | → `chapitre_result.tscn`                                            |
| 5   | `chapitre_result.tscn`    | Score chapitre, verdict, explication pédagogique                     | "Chapitre suivant" / "Voir analyse" | → étape suivante via `engine.next_chapitre()`                       |
| 6   | `analysis.tscn`           | Score total /18, label, navigation des 6 réponses                    | flèches ←/→, "Menu principal"       | → `main_menu.tscn`                                                  |

### UI components à recréer

- **`dialogue_box.tscn`** : RichTextLabel + Tween pour effet typewriter (Godot a `visible_ratio` qui simplifie). Input "skip" qui complète instantanément.
- **`contract_card.tscn`** : PanelContainer avec icône + label + état sélection (highlight bordure verte). Émet signal `toggled(type)`.
- **`conseiller.tscn`** : Sprite2D avec 4 textures (souriant / inquiet / normal / fier). Méthode `set_expression(name)`.

### Persistance

- **Pas de session save** au S2 (le user joue 1 fois sur le stand, on reset à chaque retour menu).
- Score final → `Leaderboard` autoload (mode "story") s'il dépasse top-10.

---

## Grand Pasdetôlismo — depuis le kit Kenney

### Ce qu'apporte le kit (à conserver tel quel)

- `car.tscn` (voiture arcade jouable, contrôles ZQSD/flèches)
- Modèles 3D : voiture, moto, camion
- GridMap pour construire des circuits
- Effets de fumée
- Audio CC0 (moteur, ambiance)

### Ce qu'on **ajoute** au kit

#### 1. Système de dégâts (`scripts/damage_system.gd`)

```gdscript
class_name DamageSystem
signal damaged(type: String, amount: int)
signal destroyed()

var hp: int = 100
var damage_costs: Dictionary  # { "accident_voiture": 80, ... } (depuis Disasters autoload)

func take_damage(disaster_type: String) -> int:
    var raw = Disasters.get(disaster_type).base_damage
    var paid = RaceState.apply_contract_coverage(disaster_type, raw)
    hp -= raw
    damaged.emit(disaster_type, paid)
    if hp <= 0: destroyed.emit()
    return paid
```

#### 2. Obstacles (`scripts/obstacle.gd`)

`Area3D` avec `disaster_type` exporté. À l'entrée du collider voiture :

- Joue son + particles
- Appelle `damage_system.take_damage(disaster_type)`
- Se détruit (ou se reset au prochain tour)

**Mapping obstacles → sinistres** (gameplay → MAIF) :
| Obstacle 3D | Sinistre | Damage |
|---|---|---|
| Cône / autre voiture | accident_voiture | 80 |
| Flaque profonde | degats_des_eaux | 60 |
| Voiture en feu sur le bas-côté | incendie | 100 |
| Trou (saut raté) | blessure | 55 |
| Zone "ville" (penalty random) | cambriolage / vol_vehicule | 70/90 |
| Zone tempête (vent latéral) | tempete | 65 |
| Section inondée | inondation | 75 |

#### 3. Pré-course : sélection de contrats (`scenes/pre_race.tscn`)

Réutilise `contract_card.tscn` de SC. Budget départ : **1500 €** (à équilibrer S5).

- Chaque contrat a un coût fixe affiché (ex: auto = 200€, hab = 150€, sante = 120€, vol = 80€, cata = 130€).
- Coverage = -50% sur réparations du sinistre couvert.
- Bouton "Démarrer la course" → `race.tscn` avec `RaceState.contracts = selected`.

#### 4. RaceState autoload (`scripts/race_state.gd`)

```gdscript
extends Node
var budget: int
var contracts: Array[String]
var laps_done: int = 0
var total_laps: int = 3
var damage_log: Array = []  # [{ disaster, raw_cost, paid_cost }]
var time_elapsed: float = 0.0

func apply_contract_coverage(disaster: String, raw: int) -> int:
    var covered = false
    for c in contracts:
        if disaster in Contracts.get_by_type(c).covers:
            covered = true; break
    var paid = int(raw * 0.5) if covered else raw
    budget -= paid
    damage_log.append({ "disaster": disaster, "raw": raw, "paid": paid, "covered": covered })
    return paid

func compute_score() -> int:
    # Plus de budget restant + bonus vitesse
    var time_bonus = max(0, 200 - int(time_elapsed))
    return budget + time_bonus * 5
```

#### 5. Stand de réparation (`scenes/repair_stand.tscn`)

`Area3D` placée sur le circuit. À l'entrée : pause race + popup "Tu es au stand. HP: 60/100. Réparation = 200€. [Réparer] [Continuer]". Réparation restaure HP à 100, déduit du budget.

#### 6. HUD course

Top-left : Budget restant, Tours (1/3), Temps écoulé, HP.
Top-right : Mini-timeline des dégâts subis (les 3 derniers).

#### 7. Post-course

Affiche : budget final, temps, score, classement (top-10 mode "racing"). Bouton "Rejouer" + "Menu".

### Tracks

- **S3** : 1 tour rapide (~45s), modifie le sample track du kit en y plaçant 5-6 obstacles.
- **S5** : 2e track avec sections thématiques (forêt = catastrophe, ville = vol, autoroute = accident).

---

## Sprint plan (6 × 1 semaine)

Chaque sprint = un build jouable. Si retard, on coupe le contenu suivant, jamais le contenu déjà acquis.

### Sprint 1 — Setup & menu (S+0 → S+7)

**Goal** : projet Godot bootstrapé, kit Kenney intégré, menu fonctionnel.

- [ ] Installer Godot 4.6
- [ ] Cloner Kenney kit dans `godot/grand_pasdetolismo/` (préserver structure)
- [ ] Créer arborescence `main_menu/`, `sortez_couvert/`, `shared/`
- [ ] `main_menu.tscn` : 2 boutons + Quit + thème MAIF basique
- [ ] Boutons : "Sortez Couvert" → placeholder scene, "Grand Pasdetôlismo" → `race.tscn` du kit (tel quel)
- [ ] Tag git `v1-phaser` sur l'état actuel
- [ ] Commit initial du projet Godot

**Livrable** : on lance Godot, on voit le menu, on clique sur Pasdetôlismo, on conduit la voiture du kit.

### Sprint 2 — Sortez Couvert MVP (S+7 → S+14)

**Goal** : quiz 6 chapitres jouable end-to-end.

- [ ] Implémenter les 3 autoloads (Contracts, Disasters, Chapitres) avec données portées
- [ ] Implémenter `story_engine.gd` (toggle, useHint, resolve, nextChapitre, getAnalysis) + tests manuels
- [ ] Construire les 6 scènes UI (UI brute, pas d'animation)
- [ ] Implémenter `contract_card.tscn` togglable
- [ ] `dialogue_box.tscn` avec typewriter (`visible_ratio`)
- [ ] Conseiller en placeholder (carré coloré → vrai sprite en S5)
- [ ] Score affiché à la fin
- [ ] **Supprimer `legacy-phaser/`** une fois validé

**Livrable** : on joue 1 partie complète des 6 chapitres et on voit le score final.

### Sprint 3 — Pasdetôlismo MVP course (S+14 → S+21)

**Goal** : course 1 tour avec dégâts et budget.

- [ ] `race_state.gd` autoload avec budget = 1500
- [ ] `damage_system.gd` attaché à la voiture
- [ ] 3 types d'obstacles (cone, flaque, voiture en feu) avec `Area3D` + `disaster_type`
- [ ] Modifier le track Kenney : poser 5 obstacles
- [ ] HUD : budget, HP, temps
- [ ] `repair_stand.tscn` à mi-circuit (popup Yes/No)
- [ ] Fin de course = post-race screen avec score brut

**Livrable** : on roule, on touche un cône, on voit -80€, on passe au stand, on répare pour 200€, on finit la course avec un score.

### Sprint 4 — Pasdetôlismo contrats + multi-tours (S+21 → S+28)

**Goal** : pré-course stratégique + 3 tours + score complet.

- [ ] `pre_race.tscn` : 5 cartes contrats + budget affiché en temps réel
- [ ] Coût des contrats équilibré (auto 200, hab 150, sante 120, vol 80, cata 130)
- [ ] `apply_contract_coverage()` testé sur tous les sinistres
- [ ] 3 tours de circuit (`laps_done`, ligne d'arrivée détecte tour)
- [ ] Obstacles régénérés à chaque tour (ou fixes selon design)
- [ ] Formule de score finale (budget restant + bonus temps)
- [ ] Leaderboard local (top-10) sauvé dans `user://leaderboard.cfg`

**Livrable** : on choisit ses contrats, on fait 3 tours, on voit son score sur le leaderboard.

### Sprint 5 — Polish contenu (S+28 → S+35)

**Goal** : les 2 jeux passent de "fonctionnel" à "agréable".

- [ ] **SC** : sprite conseiller avec 4 expressions (PNG simples ou Aseprite)
- [ ] **SC** : animations de révélation des sinistres (Tween sur les badges)
- [ ] **SC** : sons (clic, validation, success/fail)
- [ ] **Course** : 2e track (forêt + ville)
- [ ] **Course** : sons (collision, klaxon, ambiance)
- [ ] **Course** : effets visuels (étincelles à l'impact, fumée si HP bas)
- [ ] Thème MAIF unifié (couleurs, fonts) sur les 2 jeux
- [ ] Equilibrage contrats : viser **gain attendu nul si yolo**, **+30% si optimal**

**Livrable** : on a envie d'y rejouer.

### Sprint 6 — Stand prep (S+35 → S+42, deadline 11/06)

**Goal** : robustesse événementielle.

- [ ] Tester sur le matériel exact du stand (résolution, manettes ?)
- [ ] Mode plein écran par défaut
- [ ] Auto-retour menu après 30s d'inactivité sur game over
- [ ] Saisie pseudo pour leaderboard (clavier virtuel si tactile)
- [ ] Export Windows `.exe` packagé
- [ ] Bug bash sur 5-10 parties test
- [ ] Branding MAIF final (logos, couleurs, splash)
- [ ] README.md mis à jour

**Livrable** : `.exe` clé en main pour le stand 11-12 juin.

---

## Critical files to create/modify

| Path                                                                   | Sprint  | Action                                                                       |
| ---------------------------------------------------------------------- | ------- | ---------------------------------------------------------------------------- |
| `godot/project.godot`                                                  | S1      | Créer                                                                        |
| `godot/main_menu/main_menu.tscn` + `.gd`                               | S1      | Créer                                                                        |
| `godot/shared/data/contracts.gd`                                       | S2      | Créer (port de `src/core/shared/config/contractsConfig.ts`)                  |
| `godot/shared/data/disasters.gd`                                       | S2      | Créer (port de `src/core/shared/config/disastersConfig.ts`)                  |
| `godot/shared/data/chapitres.gd`                                       | S2      | Créer (port verbatim de `src/core/histoire/config/chapitresConfig.ts:4-221`) |
| `godot/sortez_couvert/scripts/story_engine.gd`                         | S2      | Créer (port logique de `src/core/histoire/services/StoryEngine.ts`)          |
| `godot/sortez_couvert/scenes/*.tscn` (×6) + `.gd`                      | S2      | Créer                                                                        |
| `godot/sortez_couvert/ui/{dialogue_box,contract_card,conseiller}.tscn` | S2 / S5 | Créer                                                                        |
| `godot/grand_pasdetolismo/`                                            | S1      | Cloner kit Kenney                                                            |
| `godot/grand_pasdetolismo/scripts/race_state.gd`                       | S3      | Créer                                                                        |
| `godot/grand_pasdetolismo/scripts/damage_system.gd`                    | S3      | Créer                                                                        |
| `godot/grand_pasdetolismo/scripts/obstacle.gd`                         | S3      | Créer                                                                        |
| `godot/grand_pasdetolismo/scenes/repair_stand.tscn`                    | S3      | Créer                                                                        |
| `godot/grand_pasdetolismo/scenes/pre_race.tscn` + `post_race.tscn`     | S4      | Créer                                                                        |
| `godot/shared/persistence/leaderboard.gd`                              | S4      | Créer (1 fichier autoload, top-10 par mode, ConfigFile sur `user://`)        |
| `legacy-phaser/`                                                       | fin S2  | **Supprimer** après validation SC                                            |
| `README.md`                                                            | S6      | Réécrire                                                                     |

## Reuse — contenus à récupérer du legacy

- **Verbatim** : 6 chapitres (textes/dialogues/disasters), 5 contrats, 8 sinistres, 8×3 prevention tips → ce sont **les seuls actifs intellectuels** à récupérer du Phaser.
- **Logique** : formule de score (cf. `StoryEngine.ts:129-130`), seuils labels (`:184-187`), résolution sinistres (`:135-145`).
- **Pas réutilisable** : tout le code Phaser (scenes, entities, UI) — on repart de zéro avec les nodes Godot.

---

## Risks & mitigations

| Risque                                            | Probabilité | Mitigation                                                                                           |
| ------------------------------------------------- | ----------- | ---------------------------------------------------------------------------------------------------- |
| Apprentissage Godot trop lent                     | Moyenne     | S1 = découverte sur le kit (déjà fait, tu pédales pas dans le vide). Tutos officiels Godot 2-3h max. |
| 3D physics frustrante à tuner                     | Élevée      | Garder la voiture du kit telle quelle. Ne **PAS** custom les contrôles avant S6.                     |
| Scope creep (envie d'ajouter IA, multi, etc.)     | Élevée      | Plan strict S1-S6. Toute idée nouvelle → backlog post-event.                                         |
| Equilibrage course (yolo trop fort / trop faible) | Moyenne     | S5 dédié. Coûts contrats ajustables en 1 fichier (`pre_race.gd`).                                    |
| Bug sur PC stand                                  | Moyenne     | S6 dédié. Export Windows tôt (S4 idéalement) pour repérer les surprises.                             |
| Perte du contenu Phaser pendant migration         | Faible      | Tag git `v1-phaser` immuable + `legacy-phaser/` jusqu'à fin S2.                                      |

---

## Verification (à chaque fin de sprint)

**S1** : lancer `.exe` (ou éditeur Godot), menu s'affiche, 2 boutons cliquables, voiture du kit jouable.

**S2** : jouer les 6 chapitres en sélectionnant des contrats variés. Vérifier que :

- score 18/18 si on choisit toujours les `recommended_contracts` sans indice
- score 0 si on choisit toujours des contrats faux
- les sinistres tirés respectent les `probability` (faire 5 runs et observer la distribution sur le chapitre 5 — proba 1.0 doit toujours tomber)

**S3** : faire 1 tour, taper 1 cône volontairement, vérifier que budget passe 1500 → 1420. Aller au stand, accepter, vérifier 1420 → 1220 et HP 100. Finir la course → score affiché.

**S4** : faire 3 runs : (a) sans contrats, (b) auto seul, (c) auto + cata. Vérifier que le coût total varie selon coverage. Score sauvé dans le leaderboard.

**S5** : show off à 2-3 personnes externes pour feedback fun/clarté. Ajuster.

**S6** : 5 parties complètes sur le PC du stand sans crash. Auto-retour menu testé. Pseudo + leaderboard testés.

---

## Décisions à confirmer avant exécution

Aucune — toutes les décisions tech sont prises (Godot 4.6, kit Kenney, structure fichiers, formule de score portée à l'identique).
