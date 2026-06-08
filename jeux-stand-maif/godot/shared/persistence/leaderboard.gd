extends Node
class_name LeaderboardStore

# ---------------------------------------------------------------------------
# Persistence du classement.
#
# Stocke TOUTES les entrées (pas seulement le top N). Le fichier JSON contient
# l'historique complet, accessible à des fins de stats/admin/export.
# L'UI continue d'afficher seulement les `DISPLAY_TOP_N` meilleures via
# `get_entries(mode, DISPLAY_TOP_N)`.
#
# Deux formats d'entrée cohabitent :
# - Format "flat" (legacy + racing) : { name, email, score:int, hints_used, effective_score, timestamp }
# - Format "chapitres" (story récent) : { name, email, effective_score,
#       score: { total, timestamp, chapter_1: {id, title, score:"X/3", hint_used}, ... } }
# Les helpers _get_score_total() / _get_hints_total() lisent les deux.
# ---------------------------------------------------------------------------

# En éditeur : sauvegarde dans le projet (pratique pour debug + versioning)
# En build exporté : sauvegarde à côté du .exe (portable, USB-friendly, visible)
# L'utilisateur peut overrider via set_custom_save_path() (configurable via modale F10).
const PROJECT_SAVE_PATH := "res://shared/persistence/leaderboard.json"
const USER_SAVE_PATH := "user://leaderboard.json"
const PATH_CONFIG_FILE := "user://leaderboard_path.cfg"

# Nombre d'entrées affichées par défaut dans l'UI / utilisé pour `is_top_ten`.
const DISPLAY_TOP_N := 10

# { "story": [...], "racing": [...] }  → toutes les entrées, triées meilleur en tête
var _data: Dictionary = {"story": [], "racing": []}

func _ready() -> void:
	_load()

# ---- API publique -----------------------------------------------------------

# Mode "racing" (et autres modes simples) : score scalaire, format flat.
func add_entry(mode: String, player_name: String, score: int, email: String = "", hints_used: int = 0) -> int:
	if not _data.has(mode):
		_data[mode] = []
	var ts := Time.get_unix_time_from_system()
	var safe_hints: int = max(0, hints_used)
	var entry := {
		"name": player_name,
		"email": email,
		"score": score,
		"hints_used": safe_hints,
		"effective_score": _effective_score(score, safe_hints),
		"timestamp": ts,
	}
	return _insert(mode, entry)

# Mode "story" : enregistre le détail par chapitre.
# `chapter_breakdown` : Array de { id:int, title:String, score_earned:int,
#                                   score_max:int, hints_used:int }
# L'ordre du tableau = ordre joué dans la partie (chapter_1 = premier chapitre).
func add_story_entry(player_name: String, email: String, chapter_breakdown: Array) -> int:
	var ts: int = int(Time.get_unix_time_from_system())
	var score_obj: Dictionary = {}
	var total: int = 0
	var hints_total: int = 0
	for i in chapter_breakdown.size():
		var c: Dictionary = chapter_breakdown[i]
		var earned: int = int(c.get("score_earned", 0))
		var max_pts: int = int(c.get("score_max", 3))
		var hints: int = max(0, int(c.get("hints_used", 0)))
		total += earned
		hints_total += hints
		score_obj["chapter_%d" % (i + 1)] = {
			"id": int(c.get("id", 0)),
			"title": String(c.get("title", "")),
			"hint_used": hints,
			"score": "%d/%d" % [earned, max_pts],
		}
	score_obj["total"] = total
	score_obj["timestamp"] = ts
	var entry := {
		"name": player_name,
		"email": email,
		"effective_score": _effective_score(total, hints_total),
		"score": score_obj,
	}
	return _insert("story", entry)

func _insert(mode: String, entry: Dictionary) -> int:
	_data[mode].append(entry)
	_data[mode].sort_custom(_compare_entries)
	# PAS de resize : on garde tout l'historique
	_save()
	# Renvoie l'index post-tri (utile pour scroller dessus côté UI)
	for i in _data[mode].size():
		if _data[mode][i] == entry:
			return i
	return -1

# `limit` : nombre max d'entrées à renvoyer (-1 = pas de limite, renvoie tout)
func get_entries(mode: String, limit: int = -1) -> Array:
	var all: Array = _data.get(mode, [])
	if limit > 0 and all.size() > limit:
		return all.slice(0, limit)
	return all

func get_best_entry(mode: String) -> Dictionary:
	var entries: Array = get_entries(mode, 1)
	if entries.is_empty():
		return {}
	return entries[0]

func is_top_ten(mode: String, score: int, hints_used: int = 0) -> bool:
	var top: Array = get_entries(mode, DISPLAY_TOP_N)
	if top.size() < DISPLAY_TOP_N:
		return true
	var safe_hints: int = max(0, hints_used)
	var candidate := {
		"score": score,
		"hints_used": safe_hints,
		"effective_score": _effective_score(score, safe_hints),
		"timestamp": Time.get_unix_time_from_system(),
	}
	return _is_entry_better(candidate, top[top.size() - 1])

func remove_entry(mode: String, idx: int) -> bool:
	if not _data.has(mode):
		return false
	if idx < 0 or idx >= _data[mode].size():
		return false
	_data[mode].remove_at(idx)
	_save()
	return true

func clear_mode(mode: String) -> void:
	if not _data.has(mode):
		return
	_data[mode] = []
	_save()

func clear_all() -> void:
	for mode in _data.keys():
		_data[mode] = []
	_save()

# ---- Helpers de lecture (gèrent les deux formats) ---------------------------

# Score brut (somme des points par chapitre, sans pénalité d'indice).
static func get_score_total(entry: Dictionary) -> int:
	var s: Variant = entry.get("score", 0)
	if s is Dictionary:
		return int(s.get("total", 0))
	return int(s)

# Nombre total d'indices utilisés sur toute la partie.
static func get_hints_total(entry: Dictionary) -> int:
	# Format flat : champ direct
	if entry.has("hints_used"):
		return max(0, int(entry.get("hints_used", 0)))
	# Format chapitres : somme sur chaque chapitre
	var s: Variant = entry.get("score", null)
	if not (s is Dictionary):
		return 0
	var total: int = 0
	for k in s.keys():
		if not String(k).begins_with("chapter_"):
			continue
		var ch: Variant = s[k]
		if ch is Dictionary:
			total += max(0, int(ch.get("hint_used", 0)))
	return total

# Timestamp unix (cherche aussi dans score.timestamp pour le format chapitres).
static func get_timestamp(entry: Dictionary) -> int:
	if entry.has("timestamp"):
		return int(entry.get("timestamp", 0))
	var s: Variant = entry.get("score", null)
	if s is Dictionary:
		return int(s.get("timestamp", 0))
	return 0

# Renvoie les chapitres du format orienté-chapitres, triés par index (chapter_1 → N).
# Tableau vide si l'entrée est au format flat (legacy/racing).
static func get_chapter_breakdown(entry: Dictionary) -> Array:
	var s: Variant = entry.get("score", null)
	if not (s is Dictionary):
		return []
	var chapters: Array = []
	for k in s.keys():
		var key: String = String(k)
		if not key.begins_with("chapter_"):
			continue
		var ch: Variant = s[k]
		if ch is Dictionary:
			var idx: int = int(key.substr(8))
			chapters.append({"index": idx, "data": ch})
	chapters.sort_custom(func(a, b): return int(a["index"]) < int(b["index"]))
	return chapters

# ---- Comparaison / scoring --------------------------------------------------

func _effective_score(score: int, hints_used: int) -> float:
	return float(score) - float(hints_used) * 0.5

func _is_entry_better(a: Dictionary, b: Dictionary) -> bool:
	var a_eff: float = float(a.get("effective_score", _effective_score(get_score_total(a), get_hints_total(a))))
	var b_eff: float = float(b.get("effective_score", _effective_score(get_score_total(b), get_hints_total(b))))
	if a_eff != b_eff:
		return a_eff > b_eff
	var a_score: int = get_score_total(a)
	var b_score: int = get_score_total(b)
	if a_score != b_score:
		return a_score > b_score
	var a_hints: int = get_hints_total(a)
	var b_hints: int = get_hints_total(b)
	if a_hints != b_hints:
		return a_hints < b_hints
	return get_timestamp(a) < get_timestamp(b)

func _compare_entries(a: Dictionary, b: Dictionary) -> bool:
	return _is_entry_better(a, b)

# ---- I/O --------------------------------------------------------------------

# Renvoie le path JSON par défaut :
# - res:// en éditeur (le fichier vit dans le projet, debuggable / versionnable)
# - à côté du .exe en build exporté (portable, USB-friendly, visible facilement)
func get_default_save_path() -> String:
	if OS.has_feature("editor"):
		return PROJECT_SAVE_PATH
	return OS.get_executable_path().get_base_dir() + "/leaderboard.json"

# Renvoie le path custom configuré par l'utilisateur via la modale F10
# (string vide si aucun override n'est défini).
func get_custom_save_path() -> String:
	if not FileAccess.file_exists(PATH_CONFIG_FILE):
		return ""
	var cfg := ConfigFile.new()
	if cfg.load(PATH_CONFIG_FILE) != OK:
		return ""
	return String(cfg.get_value("leaderboard", "path", ""))

# Renvoie le path effectivement utilisé (custom > défaut).
func get_current_save_path() -> String:
	var custom: String = get_custom_save_path()
	if not custom.is_empty():
		return custom
	return get_default_save_path()

# Sauvegarde un path custom. Vide = reset au défaut.
# Le leaderboard est ré-écrit immédiatement vers le nouveau path.
func set_custom_save_path(path: String) -> void:
	if path.is_empty():
		# Reset au défaut : supprime le fichier de config
		var d := DirAccess.open("user://")
		if d and d.file_exists("leaderboard_path.cfg"):
			d.remove("leaderboard_path.cfg")
	else:
		var cfg := ConfigFile.new()
		cfg.set_value("leaderboard", "path", path)
		cfg.save(PATH_CONFIG_FILE)
	_save()

func _save_path() -> String:
	return get_current_save_path()

func _save() -> void:
	var path := _save_path()
	var json_text := JSON.stringify(_data, "\t")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Leaderboard: failed to open %s for write (err=%d)" % [path, FileAccess.get_open_error()])
		return
	file.store_string(json_text)
	file.close()

func _load() -> void:
	var path := _save_path()
	if FileAccess.file_exists(path):
		_load_json(path)
		return
	# Fallbacks de migration : on tente les anciens emplacements et on ré-écrit
	# vers le path courant si on trouve quelque chose.
	var fallbacks: Array = [USER_SAVE_PATH, PROJECT_SAVE_PATH]
	for fallback: String in fallbacks:
		if fallback != path and FileAccess.file_exists(fallback):
			_load_json(fallback)
			_save()
			print("[Leaderboard] Migration : import depuis %s vers %s" % [fallback, path])
			return

func _load_json(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Leaderboard: failed to open %s for read (err=%d)" % [path, FileAccess.get_open_error()])
		return
	var raw := file.get_as_text()
	file.close()
	if raw.is_empty():
		return
	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Dictionary):
		push_warning("Leaderboard: JSON malformé, on réinitialise.")
		return
	for mode in ["story", "racing"]:
		var arr: Variant = parsed.get(mode, [])
		if not (arr is Array):
			continue
		_data[mode] = []
		for raw_entry in arr:
			if raw_entry is Dictionary:
				_data[mode].append(_normalize_entry(raw_entry))
		_data[mode].sort_custom(_compare_entries)

# Normalise une entrée chargée du JSON.
# On préserve le format d'origine (flat ou chapitres) pour la sérialisation,
# on s'assure juste que `effective_score` est présent (recalculé si manquant).
func _normalize_entry(raw: Dictionary) -> Dictionary:
	var entry: Dictionary = raw.duplicate(true)
	if not entry.has("effective_score"):
		entry["effective_score"] = _effective_score(get_score_total(entry), get_hints_total(entry))
	return entry
