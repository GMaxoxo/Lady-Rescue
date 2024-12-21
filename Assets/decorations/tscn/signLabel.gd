extends Node2D

@export var messageText: String
@export var texture: Texture

@onready var marginContainer = $NinePatchRect/MarginContainer
@onready var label = $NinePatchRect/MarginContainer/Label
@onready var textureRect = $NinePatchRect/MarginContainer/TextureRect

func _ready():
	#hide()
	if messageText:
		label.visible = true
		label.text = messageText
		textureRect.visible = false
	elif texture:
		label.visible = false
		textureRect.visible = true
		textureRect.texture = texture
	else:
		label.visible = false
		textureRect.visible = false
	update_size()

func _process(delta):
	update_size()

func update_size():
	var marginSide = (marginContainer.get_theme_constant("margin_left")
					+ marginContainer.get_theme_constant("margin_right"))
	if label.visible:
		$NinePatchRect.size.x = label.size.x + marginSide
	elif textureRect.visible:
		$NinePatchRect.size.x = textureRect.texture.get_size().x + marginSide
#
#func _on_show_message_box():
	#show()
#func _on_hide_message_box():
	#hide()
