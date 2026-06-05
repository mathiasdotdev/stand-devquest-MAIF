extends Node
class_name LeaderboardStore

# ---------------------------------------------------------------------------
# Persistence du classement.
#
# Stocke TOUTES les entrées (pas seulement le top N). Le fichier JSON contient
# l'historique complet, accessible à des fins de stats/admin/export.
# L'UI continue d'afficher seulement les `DISPLAY_TOP_N` meilleures via
# `get_entries(mode, DISPLAY_TOP_N)`.
# ---------------------------------------------------------------------------

# En éditeur : sauvegarde dans le projet (pratique pour debug + versioning)
# En build exporté : sauvegarde dans user:// (res:// est read-only une fois packé)
const PROJECT_SAVE_PATH := "res://shared/persistence/leaderboard.json"
const USER_SAVE_PATH := "user://leaderboard.json"

# Nombre d'entrées affichées par défaut dans l'UI / utilisé pour `is_top_ten`.
const DISPLAY_TOP_N := 10

# { "story": [...], "racing": [...] }  → toutes les entrées, triées meilleur en tête
var _data: Dictionary = {"story": [], "racing": []}

func _ready() -> void:
	_load()

# ---- API publique -----------------------------------------------------------

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
	_data[mode].append(entry)
	_data[mode].sort_custom(_compare_entries)
	# PAS de resize : on garde tout l'historique
	_save()
	for i in _data[mode].size():
		var e: Dictionary = _data[mode][i]
		if int(e.get("timestamp", 0)) == int(entry["timestamp"]) and String(e.get("name", "")) == player_name and String(e.get("email", "")) == email:
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

# ---- Comparaison / scoring --------------------------------------------------

func _effective_score(score: int, hints_used: int) -> float:
	return float(score) - float(hints_used) * 0.5

func _is_entry_better(a: Dictionary, b: Dictionary) -> bool:
	var a_eff: float = float(a.get("effective_score", _effective_score(int(a.get("score", 0)), int(a.get("hints_used", 0)))))
	var b_eff: float = float(b.get("effective_score", _effective_score(int(b.get("score", 0)), int(b.get("hints_used", 0)))))
	if a_eff != b_eff:
		return a_eff > b_eff
	var a_score: int = int(a.get("score", 0))
	var b_score: int = int(b.get("score", 0))
	if a_score != b_score:
		return a_score > b_score
	var a_hints: int = int(a.get("hints_used", 0))
	var b_hints: int = int(b.get("hints_used", 0))
	if a_hints != b_hints:
		return a_hints < b_hints
	return int(a.get("timestamp", 0)) < int(b.get("timestamp", 0))

func _compare_entries(a: Dictionary, b: Dictionary) -> bool:
	return _is_entry_better(a, b)

# ---- I/O --------------------------------------------------------------------

# Renvoie le path JSON à utiliser :
# - res:// en éditeur (le fichier vit dans le projet, debuggable / versionnable)
# - user:// en build exporté (res:// devient read-only une fois packé)
func _save_path() -> String:
	if OS.has_feature("editor"):
		return PROJECT_SAVE_PATH
	return USER_SAVE_PATH

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
	elif path == PROJECT_SAVE_PATH and FileAccess.file_exists(USER_SAVE_PATH):
		# On était en build exporté, maintenant en éditeur : récupérer le json user
		_load_json(USER_SAVE_PATH)
		_save()
		print("[Leaderboard] Import depuis user://leaderboard.json vers res://shared/persistence/leaderboard.json")

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

func _normalize_entry(raw: Dictionary) -> Dictionary:
	var score: int = int(raw.get("score", 0))
	var hints_used: int = max(0, int(raw.get("hints_used", 0)))
	var effective: float = _effective_score(score, hints_used)
	if raw.get("effective_score", null) != null:
		effective = float(raw.get("effective_score"))
	return {
		"name": String(raw.get("name", "???")),
		"email": String(raw.get("email", "")),
		"score": score,
		"hints_used": hints_used,
		"effective_score": effective,
		"timestamp": int(raw.get("timestamp", 0)),
	}
