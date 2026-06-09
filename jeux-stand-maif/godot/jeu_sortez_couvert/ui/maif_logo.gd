extends TextureRect

# TextureRect qui charge le logo MAIF si présent dans les assets.
# Si le fichier est manquant, le node se masque silencieusement → la scène
# ne plante pas, on peut intégrer le logo plus tard sans retoucher au code.

const LOGO_PATH := "res://jeu_sortez_couvert/ui/assets/logo_MAIF.png"

func _ready() -> void:
	if not ResourceLoader.exists(LOGO_PATH):
		visible = false
		return
	var tex: Texture2D = load(LOGO_PATH)
	if tex == null:
		visible = false
		return
	texture = tex
