extends Node

const SAVE_PATH := "user://leaderboard.cfg"
const MAX_ENTRIES := 10

# { "story": [...], "racing": [...] }
var _data: Dictionary = {"story": [], "racing": []}

func _ready() -> void:
	_load()

func add_entry(mode: String, player_name: String, score: int) -> int:
	var entry := {"name": player_name, "score": score, "timestamp": Time.get_unix_time_from_system()}
	_data[mode].append(entry)
	_data[mode].sort_custom(func(a, b): return a["score"] > b["score"])
	if _data[mode].size() > MAX_ENTRIES:
		_data[mode].resize(MAX_ENTRIES)
	_save()
	for i in _data[mode].size():
		if _data[mode][i]["timestamp"] == entry["timestamp"] and _data[mode][i]["name"] == player_name:
			return i
	return -1

func get_entries(mode: String) -> Array:
	return _data.get(mode, [])

func is_top_ten(mode: String, score: int) -> bool:
	var entries := get_entries(mode)
	if entries.size() < MAX_ENTRIES:
		return true
	return score > entries[entries.size() - 1]["score"]

func _save() -> void:
	var cfg := ConfigFile.new()
	for mode in _data:
		for i in _data[mode].size():
			var e: Dictionary = _data[mode][i]
			cfg.set_value(mode, str(i) + "_name", e["name"])
			cfg.set_value(mode, str(i) + "_score", e["score"])
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
			_data[mode].append({
				"name": cfg.get_value(mode, str(i) + "_name", "???"),
				"score": cfg.get_value(mode, str(i) + "_score", 0),
				"timestamp": cfg.get_value(mode, str(i) + "_timestamp", 0),
			})
