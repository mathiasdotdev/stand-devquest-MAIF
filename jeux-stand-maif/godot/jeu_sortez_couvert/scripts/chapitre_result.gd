extends "res://jeu_sortez_couvert/scripts/pause_layout.gd"

@onready var _conseiller: Node = $MarginContainer/VBoxContainer/ConseillerArea/Conseiller
@onready var _dialogue_box: Node = $MarginContainer/VBoxContainer/DialogueArea/DialogueBox
@onready var _chapitre_num_label: Label = $MarginContainer/VBoxContainer/ChapitreNumLabel
@onready var _score_label: Label = $MarginContainer/VBoxContainer/TopHBox/ScoreLabel
@onready var _titre_label: Label = $MarginContainer/VBoxContainer/TopHBox/TitreLabel
@onready var _contexte_label: Label = $MarginContainer/VBoxContainer/ContexteLabel
@onready var _background: Sprite2D = $Background

var _lines: Array = []
var _line_idx: int = 0

func _ready() -> void:
	super._ready() # necessaire pour le pause_layout
	StorySceneLayout.apply(self, "intro")
	
	# Ajuste le fond pour qu'il couvre tout l'écran (effet cover)
	if _background.texture:
		var screen_size: Vector2 = get_viewport_rect().size
		var tex_size: Vector2 = Vector2(_background.texture.get_width(), _background.texture.get_height())
		var scale_factor: float = max(screen_size.x / tex_size.x, screen_size.y / tex_size.y)
		_background.scale = Vector2(scale_factor, scale_factor)
		_background.position = get_viewport_rect().size / 2
		_background.centered = true

	var story_engine: Node = get_node("/root/StoryEngine")
	var chapitres: Node = get_node("/root/Chapitres")
	var answer = story_engine.answers.back()
	var chapitre = chapitres.get_chapitre(story_engine.current_chapitre)
	var disasters: Array = answer.get("disaster_hits", [])
	var total_count: int = max(disasters.size(), 1)
	var uncovered_count: int = 0
	for hit: Dictionary in disasters:
		if not bool(hit.get("was_covered", false)):
			uncovered_count += 1
	var covered_count: int = total_count - uncovered_count
	var net_score: int = covered_count - uncovered_count

	_chapitre_num_label.text = "Chapitre " + str(story_engine.current_chapitre + 1) + " / " + str(chapitres.count())
	_score_label.text = "Score : " + str(net_score) + " / " + str(total_count)
	_titre_label.text = chapitre["emoji"] + "  " + chapitre["titre"]
	_contexte_label.text = str(chapitre.get("contexte", ""))

	if uncovered_count == 0:
		_score_label.add_theme_color_override("font_color", Color(0.25, 0.9, 0.45, 1.0))
	elif uncovered_count < int(ceil(float(total_count) / 2.0)):
		_score_label.add_theme_color_override("font_color", Color(1.0, 0.67, 0.2, 1.0))
	else:
		_score_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1.0))
	_score_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_RIGHT)
	_dialogue_box.advance.connect(_on_advance)

	_build_lines(answer)
	_show_line(0)

func _build_lines(answer: Dictionary) -> void:
	_lines = []
	var score: int = int(answer.get("score_earned", 0))
	var disasters: Array = answer.get("disaster_hits", [])
	var total_count: int = disasters.size()
	var covered_count: int = 0
	for hit: Dictionary in disasters:
		if bool(hit.get("was_covered", false)):
			covered_count += 1
	var uncovered_count: int = total_count - covered_count

	if score >= 3:
		_lines.append({
			"expression": "hyper-good",
			"text": "Incroyable ! Tout est couvert. Vous avez joué comme un véritable chef de clan.",
		})
	elif score >= 2:
		_lines.append({
			"expression": "ok",
			"text": "Bien joué ! La majorité des risques est couverte.",
		})
	elif uncovered_count >= int(ceil(float(max(total_count, 1)) / 2.0)):
		_lines.append({
			"expression": "wrong",
			"text": "Aie... trop de risques ne sont pas couverts. Il faut renforcer la protection.",
		})
	else:
		_lines.append({
			"expression": "wrong",
			"text": "C'est encore fragile. On corrige ça ensemble.",
		})

	var chosen_contracts: Array = answer.get("chosen_contracts", [])
	var disasters_singleton: Node = get_node("/root/Disasters")
	var contracts_singleton: Node = get_node("/root/Contracts")
	for hit: Dictionary in disasters:
		var narrative: String = str(hit.get("narrative", ""))
		var disaster_type: String = hit.get("type", "")
		var was_covered: bool = bool(hit.get("was_covered", false))
		var dis: Dictionary = disasters_singleton.get_disaster(disaster_type)
		var covering_contracts: Array = dis.get("covering_contracts", [])
		var contract_labels: Array = []
		for ct in covering_contracts:
			var c = contracts_singleton.get_by_type(ct)
			contract_labels.append(c.get("icon", "") + " " + c.get("label", ct))
		if was_covered:
			var player_contracts: Array[Variant] = []
			for ct in chosen_contracts:
				if covering_contracts.has(ct):
					var c = contracts_singleton.get_by_type(ct)
					player_contracts.append(c.get("icon", "") + " " + c.get("label", ct))
			var contract_str: String = ", ".join(player_contracts) if player_contracts.size() > 0 else "?"
			_lines.append({
				"expression": "explain",
				"text": "✅ Couvert par " + contract_str + " : " + narrative,
			})
		else:
			var contract_str: String = ", ".join(contract_labels) if contract_labels.size() > 0 else "?"
			_lines.append({
				"expression": "explain",
				"text": "❌ Non couvert (contrat : " + contract_str + ") : " + narrative,
			})

func _show_line(idx: int) -> void:
	if idx < 0 or idx >= _lines.size():
		return
	var line: Dictionary = _lines[idx]
	_dialogue_box.show_text(str(line.get("text", "...")))
	if _conseiller:
		_conseiller.set_expression(str(line.get("expression", "explain")))
	else:
		print("[ERREUR] Le noeud Conseiller est null !")

func _on_advance() -> void:
	_line_idx += 1
	if _line_idx < _lines.size():
		_show_line(_line_idx)
		return

	var story_engine: Node = get_node("/root/StoryEngine")
	var has_next: bool = story_engine.next_chapitre()
	if has_next:
		get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/chapitre_intro.tscn")
	else:
		get_tree().change_scene_to_file("res://jeu_sortez_couvert/scenes/analysis.tscn")
