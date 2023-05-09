extends Node


var size: Vector2i = Vector2i(0, 0)
var used_pixels: Array[Vector2i] = []

var texture: Texture2D = preload("res://assets/images/sculptures/8px/toy1.png")


func _ready():
	pass


func _process(delta):
	pass


func init(sculpture_data: Dictionary)


func set_texture(texture: Texture2D) -> void:
	var image: Image = texture.get_image()
	size = image.get_size()
	used_pixels = []
	for x in size.x:
		for y in size.y:
			var color: Color = image.get_pixel(x, y)
			if not color.a == 0:
				used_pixels.append(Vector2i(x, y))
