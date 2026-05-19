extends CanvasLayer

signal resume_requested
signal restart_requested
signal quit_requested

var _confirm_dialog: ConfirmationDialog = null

func _ready() -> void:
	$Container.visible = false
	$Container/Center/VBox/BtnResume.pressed.connect(_on_resume)
	$Container/Center/VBox/BtnRestart.pressed.connect(_on_restart_confirm)
	$Container/Center/VBox/BtnQuit.pressed.connect(_on_quit)

	# Création du dialog de confirmation si non présent
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.dialog_text = "Attention : si vous revenez au début, votre score ne sera pas enregistré dans le leaderboard. Voulez-vous vraiment recommencer ?"
	_confirm_dialog.ok_button_text = "Oui, recommencer"
	_confirm_dialog.cancel_button_text = "Annuler"
	_confirm_dialog.visible = false
	_confirm_dialog.confirmed.connect(_on_restart)
	add_child(_confirm_dialog)

func show_pause() -> void:
	get_tree().paused = true
	$Container.visible = true

func hide_pause() -> void:
	get_tree().paused = false
	$Container.visible = false

func _on_resume() -> void:
	hide_pause()
	resume_requested.emit()

func _on_restart_confirm() -> void:
	_confirm_dialog.popup_centered()
	_confirm_dialog.visible = true

func _on_restart() -> void:
	_confirm_dialog.visible = false
	hide_pause()
	restart_requested.emit()

func _on_quit() -> void:
	hide_pause()
	quit_requested.emit()
