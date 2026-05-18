extends Node

const SAVE_PATH := "user://leaderboard.cfg"
const MAX_ENTRIES := 10

# { "story": [...], "racing": [...] }
var _data: Dictionary = {"story": [], "racing": []}

func _ready() -> void:
	_load()

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
	if _data[mode].size() > MAX_ENTRIES:
		_data[mode].resize(MAX_ENTRIES)
	_save()
	for i in _data[mode].size():
		if _data[mode][i]["timestamp"] == entry["timestamp"] and _data[mode][i]["name"] == player_name and _data[mode][i]["email"] == email:
			return i
	return -1

func get_entries(mode: String) -> Array:
	return _data.get(mode, [])

func get_best_entry(mode: String) -> Dictionary:
	var entries: Array = get_entries(mode)
	if entries.is_empty():
		return {}
	return entries[0]

func is_top_ten(mode: String, score: int, hints_used: int = 0) -> bool:
	var entries := get_entries(mode)
	if entries.size() < MAX_ENTRIES:
		return true
	var safe_hints: int = max(0, hints_used)
	var candidate := {
		"score": score,
		"hints_used": safe_hints,
		"effective_score": _effective_score(score, safe_hints),
		"timestamp": Time.get_unix_time_from_system(),
	}
	return _is_entry_better(candidate, entries[entries.size() - 1])

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

func _save() -> void:
	var cfg := ConfigFile.new()
	for mode in _data:
		for i in _data[mode].size():
			var e: Dictionary = _data[mode][i]
			cfg.set_value(mode, str(i) + "_name", e["name"])
			cfg.set_value(mode, str(i) + "_email", e.get("email", ""))
			cfg.set_value(mode, str(i) + "_score", e["score"])
			cfg.set_value(mode, str(i) + "_hints_used", e.get("hints_used", 0))
			cfg.set_value(mode, str(i) + "_effective_score", e.get("effective_score", _effective_score(int(e["score"]), int(e.get("hints_used", 0)))))
			cfg.set_value(mode, str(i) + "_timestamp", e["timestamp"])
		cfg.set_value(mode, "count", _data[mode].size())
	cfg.save(SAVE_PATH)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for mode in ["story", "racing"]:
		var count: int = cfg.get_value(mode, "count", 0)
		_data[mode] = []
		for i in count:
			var score: int = int(cfg.get_value(mode, str(i) + "_score", 0))
			var hints_used: int = int(cfg.get_value(mode, str(i) + "_hints_used", 0))
			var effective_key := str(i) + "_effective_score"
			var effective_value: float = _effective_score(score, hints_used)
			if cfg.has_section_key(mode, effective_key):
				effective_value = float(cfg.get_value(mode, effective_key, effective_value))
			_data[mode].append(_normalize_entry({
				"name": cfg.get_value(mode, str(i) + "_name", "???"),
				"email": cfg.get_value(mode, str(i) + "_email", ""),
				"score": score,
				"hints_used": hints_used,
				"effective_score": effective_value,
				"timestamp": cfg.get_value(mode, str(i) + "_timestamp", 0),
			}))
		_data[mode].sort_custom(_compare_entries)
		if _data[mode].size() > MAX_ENTRIES:
			_data[mode].resize(MAX_ENTRIES)

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
