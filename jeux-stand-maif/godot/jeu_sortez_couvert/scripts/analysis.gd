extends Control

const MAIF_URL := "https://www.maif.fr/annexes/toutes-nos-solutions"
const QR_TEXTURE_PATH := "res://jeu_sortez_couvert/ui/assets/tous-nos-produits-maif.png"

const COLOR_GREEN := "#5dd66b"
const COLOR_RED := "#ff7373"
const COLOR_ORANGE := "#ff9b42"
const COLOR_GOLD := "#ffeb8c"
const COLOR_DIM := "#8a93a8"
const COLOR_LABEL_EXPERT := "#4cff80"
const COLOR_LABEL_BON := "#4ccfff"
const COLOR_LABEL_AMELIORER := "#ffb340"
const COLOR_LABEL_DEBUTANT := "#ff6666"

@onready var _chapter_info: RichTextLabel = $MarginContainer/VBoxContainer/ChapterNavRow/ChapterBubble/Margin/ChapterInfo
@onready var _btn_prev: Button = $MarginContainer/VBoxContainer/ChapterNavRow/BtnPrev
@onready var _btn_next_chap: Button = $MarginContainer/VBoxContainer/ChapterNavRow/BtnNextChap
@onready var _btn_discover: Button = $MarginContainer/VBoxContainer/DiscoverSection/BtnDiscover
@onready var _qr_code: TextureRect = $MarginContainer/VBoxContainer/DiscoverSection/QRCode
@onready var _menu_btn: Button = $MarginContainer/VBoxContainer/BtnMenu

var _analysis: Dictionary
var _view_idx: int = 0
# Section "top" (score + label) calculée 1× et placée en haut de chaque vue
var _top_section_bbcode: String = ""
# Section "bottom" (meilleur / à améliorer / cadeau) calculée 1× et appendée en bas
var _global_section_bbcode: String = ""

func _ready() -> void:
	_analysis = Globals.story_engine.get_analysis()

	_btn_prev.pressed.connect(_on_prev)
	_btn_next_chap.pressed.connect(_on_next_chap)
	_menu_btn.pressed.connect(_on_menu)
	_btn_discover.pressed.connect(_on_discover)
	_setup_qr_code()

	# Toutes les parties sont enregistrées. Le top N est filtré uniquement à l'affichage.
	save_score()
	_build_top_section()
	_build_global_section()
	_show_chapter_view(0)

# ---- Vue chapitre -----------------------------------------------------------

func _show_chapter_view(idx: int) -> void:
	var answers: Array = _analysis["answers"]
	if answers.is_empty():
		_chapter_info.text = "Aucune donnée"
		return

	_view_idx = clamp(idx, 0, answers.size() - 1)
	var a: Dictionary = answers[_view_idx]
	var chapitre: Dictionary = Globals.chapitres.get_chapitre(a["chapitre_id"])

	var chosen_labels: Array = []
	for ct: String in a["chosen_contracts"]:
		var c: Dictionary = Globals.contracts.get_by_type(ct)
		chosen_labels.append(c.get("label", ct))

	var recommended_labels: Array = []
	for ct: String in a["correct_contracts"]:
		var c: Dictionary = Globals.contracts.get_by_type(ct)
		recommended_labels.append(c.get("label", ct))

	var score_earned: int = int(a.get("score_earned", 0))
	var verdict_color: String = COLOR_GREEN if score_earned >= 2 else (COLOR_ORANGE if score_earned >= 1 else COLOR_RED)
	var verdict_icon: String = "✓" if a["is_correct"] else "✗"
	var verdict: String = "[color=%s]%s %d / 3 pts[/color]" % [verdict_color, verdict_icon, score_earned]

	var hints_used: int = int(a["hints_used"])
	var hint_note: String = ""
	if hints_used > 0:
		hint_note = "  [color=%s](%s, soit %s)[/color]" % [
			COLOR_ORANGE,
			_format_indice_count(hints_used),
			_format_point_value(-float(hints_used) * 0.5),
		]

	var title_line: String = "[color=%s][b]Chapitre %d — %s %s[/b][/color]" % [
		COLOR_GOLD,
		_view_idx + 1,
		chapitre.get("emoji", ""),
		chapitre.get("titre", ""),
	]
	var vous_str: String = ", ".join(chosen_labels) if not chosen_labels.is_empty() else "aucun contrat"
	var recommande_str: String = ", ".join(recommended_labels) if not recommended_labels.is_empty() else "—"

	_chapter_info.text = (
		"[center]"
		+ _top_section_bbcode
		+ _divider_bbcode()
		+ title_line + "\n\n"
		+ "[b]Vous avez choisi :[/b] " + vous_str + "\n"
		+ "[b]Recommandé :[/b] " + recommande_str + "\n\n"
		+ verdict + hint_note
		+ _divider_bbcode()
		+ _global_section_bbcode
		+ "[/center]"
	)

	_btn_prev.disabled = _view_idx <= 0
	_btn_next_chap.disabled = _view_idx >= answers.size() - 1

func _divider_bbcode() -> String:
	return "\n[color=%s]─────────────────────[/color]\n" % COLOR_DIM

# ---- Sections fixes ---------------------------------------------------------

func _build_top_section() -> void:
	var raw_label: String = String(_analysis.get("label", ""))
	var readable_label: String = _readable_label(raw_label)
	var label_color: String = _label_color(raw_label)
	_top_section_bbcode = (
		"[font_size=22][b]Score total : %d / %d[/b][/font_size]  "
		+ "[color=%s][font_size=18]%s[/font_size][/color]"
	) % [
		int(_analysis.get("total_score", 0)),
		int(_analysis.get("max_score", 18)),
		label_color,
		readable_label,
	]

func _build_global_section() -> void:
	# Meilleur / À améliorer retirés : l'utilisateur peut naviguer entre chapitres
	# pour voir ses résultats. On garde seulement le cadeau global.
	_global_section_bbcode = _build_prize_bbcode()

func _build_prize_bbcode() -> String:
	var best_entry: Dictionary = Globals.leaderboard.get_best_entry("story")
	if best_entry.is_empty():
		return "[color=%s]🎁 [b]Cadeau meilleur score :[/b] aucun score enregistré pour l'instant.[/color]" % COLOR_GOLD
	var best_name: String = String(best_entry.get("name", "Anonyme"))
	var best_score: int = LeaderboardStore.get_score_total(best_entry)
	var best_hints: int = LeaderboardStore.get_hints_total(best_entry)
	var best_effective: float = float(best_entry.get("effective_score", best_score))
	var max_total: int = int(_analysis.get("max_score", Globals.chapitres.count() * 3))
	return "[color=%s]🎁 [b]Cadeau meilleur score :[/b] %s mène avec %d/%d (%0.1f après pénalité), %s.[/color]" % [
		COLOR_GOLD, best_name, best_score, max_total, best_effective, _format_indice_count(best_hints),
	]

# ---- Helpers format ---------------------------------------------------------

func _readable_label(raw: String) -> String:
	# Le storyengine renvoie des labels sans accents. On les ré-accentue ici.
	match raw:
		"Expert MAIF": return "Expert MAIF"
		"Bon eleve": return "Bon élève"
		"A ameliorer": return "À améliorer"
		"Debutant": return "Débutant"
		_: return raw

func _label_color(raw: String) -> String:
	match raw:
		"Expert MAIF": return COLOR_LABEL_EXPERT
		"Bon eleve": return COLOR_LABEL_BON
		"A ameliorer": return COLOR_LABEL_AMELIORER
		"Debutant": return COLOR_LABEL_DEBUTANT
		_: return "#ffffff"

# "1 indice" / "2 indices" / "0 indice" — singulier si < 2.
func _format_indice_count(n: int) -> String:
	var word: String = "indice" if n < 2 else "indices"
	return "%d %s" % [n, word]

# Format propre des points : -0.5 → "-0.5 point", -1 → "-1 point", -1.5 → "-1.5 points".
# Pluriel à partir de |x| >= 2.
func _format_point_value(value: float) -> String:
	var abs_v: float = abs(value)
	var word: String = "point" if abs_v < 2.0 else "points"
	# Affichage avec 1 décimale si pas entier, entier sinon.
	if abs(value - round(value)) < 0.001:
		return "%d %s" % [int(round(value)), word]
	return "%0.1f %s" % [value, word]

# ---- Navigation -------------------------------------------------------------

func _on_prev() -> void:
	_show_chapter_view(_view_idx - 1)

func _on_next_chap() -> void:
	_show_chapter_view(_view_idx + 1)

# ---- Leaderboard ------------------------------------------------------------

func save_score() -> void:
	if Globals.story_engine.player_name.is_empty():
		Globals.story_engine.player_name = "Anonyme"
	Globals.leaderboard.add_story_entry(
		Globals.story_engine.player_name,
		Globals.story_engine.player_email,
		_build_chapter_breakdown(),
	)

# Construit le tableau de breakdown attendu par add_story_entry :
# un dict par chapitre joué, dans l'ordre du pool.
func _build_chapter_breakdown() -> Array:
	var breakdown: Array = []
	for a: Dictionary in _analysis.get("answers", []):
		var chapitre_id: int = int(a.get("chapitre_id", 0))
		var chap: Dictionary = Globals.chapitres.get_chapitre(chapitre_id)
		breakdown.append({
			"id": chapitre_id,
			"title": String(chap.get("titre", "")),
			"score_earned": int(a.get("score_earned", 0)),
			"score_max": 3, # cf. story_engine.resolve_current_chapitre()
			"hints_used": int(a.get("hints_used", 0)),
		})
	return breakdown

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

# ---- Section "Découvrir MAIF" -----------------------------------------------

func _on_discover() -> void:
	OS.shell_open(MAIF_URL)

func _setup_qr_code() -> void:
	if not ResourceLoader.exists(QR_TEXTURE_PATH):
		_qr_code.visible = false
		return
	var tex: Texture2D = load(QR_TEXTURE_PATH)
	if tex == null:
		_qr_code.visible = false
		return
	_qr_code.texture = tex
