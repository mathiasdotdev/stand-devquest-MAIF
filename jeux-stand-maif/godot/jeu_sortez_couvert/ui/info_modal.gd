extends CanvasLayer

# Modale d'information réutilisable, stylée comme le menu pause.
# Usage : instancier dans la scène, appeler `show_modal(title, message)`.

@onready var _container: Control = $Container
@onready var _title_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/Title
@onready var _message_label: Label = $Container/CenterContainer/MenuPanel/Margin/VBox/Message
@onready var _btn_ok: Button = $Container/CenterContainer/MenuPanel/Margin/VBox/BtnOk

func _ready() -> void:
	_btn_ok.pressed.connect(hide_modal)
	_container.visible = false

func show_modal(title: String, message: String) -> void:
	_title_label.text = title
	_message_label.text = message
	_container.visible = true

func hide_modal() -> void:
	_container.visible = false
