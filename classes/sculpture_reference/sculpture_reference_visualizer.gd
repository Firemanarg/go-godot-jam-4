extends Control


var reference = null

@onready var texture_rect = get_node("MarginContainer/PanelContainer/TextureRect")


func _ready():
	pass


func _process(delta):
	pass


func update() -> void:
	if not reference:
		return
	texture_rect.set_texture(reference.texture)
	print("Updating texture!")
#	texture_rect.texture = reference.texture
