extends Control


var reference = null

@onready var texture_rect = get_node("MarginContainer/PanelContainer/TextureRect")


func _ready():
	pass


func _process(delta):
	pass


func update() -> void:
	if not reference:
		texture_rect.visible = false
		print("reference is null")
		return
	texture_rect.visible = true
	texture_rect.set_texture(reference.texture)


func set_reference(reference = null):
	self.reference = reference
	update()
