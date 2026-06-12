class_name PasswordGate
extends PanelContainer

# Porte mot de passe réutilisable pour protéger l'accès aux modales de
# paramètres (F10). Émet `unlocked` quand le bon mot de passe est saisi,
# `cancelled` si l'utilisateur annule.
#
# Usage :
#   var gate := PasswordGate.new()
#   parent.add_child(gate)
#   gate.unlocked.connect(_on_unlocked)
#   gate.cancelled.connect(_on_cancelled)
#   gate.reset()  # à chaque ouverture : vide le champ + focus

signal unlocked
signal cancelled

# Mot de passe requis pour accéder aux paramètres (F10). À modifier ici pour
# changer le code d'accès admin (partagé par toutes les modales protégées).
const PASSWORD := "DevquestMAIF2026"

var _input: LineEdit = null
var _error: Label = null

func _ready() -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.10, 0.16, 0.97)
	sb.border_color = Color(0.55, 0.62, 0.78, 0.55)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(28)
	add_theme_stylebox_override("panel", sb)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	vb.custom_minimum_size = Vector2(360, 0)
	add_child(vb)

	var title := Label.new()
	title.text = "Accès paramètres protégé"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.92, 0.55, 1))
	vb.add_child(title)

	var prompt := Label.new()
	prompt.text = "Mot de passe :"
	prompt.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95, 1))
	vb.add_child(prompt)

	_input = LineEdit.new()
	_input.secret = true
	_input.placeholder_text = "••••••••"
	_input.text_submitted.connect(func(_t): _submit())
	vb.add_child(_input)

	_error = Label.new()
	_error.text = "Mot de passe incorrect"
	_error.visible = false
	_error.add_theme_color_override("font_color", Color(1, 0.45, 0.45, 1))
	vb.add_child(_error)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	vb.add_child(row)

	var btn_ok := Button.new()
	btn_ok.text = "Valider"
	btn_ok.pressed.connect(_submit)
	row.add_child(btn_ok)

	var btn_cancel := Button.new()
	btn_cancel.text = "Annuler"
	btn_cancel.pressed.connect(func(): cancelled.emit())
	row.add_child(btn_cancel)

# Remet la porte à zéro (champ vide, erreur masquée) et donne le focus.
# À appeler à chaque ouverture de la modale.
func reset() -> void:
	if _input:
		_input.text = ""
		_input.grab_focus()
	if _error:
		_error.visible = false

func _submit() -> void:
	if _input.text == PASSWORD:
		_error.visible = false
		unlocked.emit()
	else:
		_error.visible = true
		_input.text = ""
		_input.grab_focus()
