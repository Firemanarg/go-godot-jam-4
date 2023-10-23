extends Node


var sculpture_name: String = ""
var texture: Texture2D = null
var time: float = 0.0
var size: Vector2i = Vector2i(0, 0)

var used_pixels: Array[Vector2i] = []


func _ready():
	pass


func _process(delta):
	pass


func set_sculpture_data(data: Dictionary) -> void:
	sculpture_name = data.get("name", "")
	time = data.get("time", 0.0)
	_set_texture(data.get("texture"))


func _set_texture(texture: Texture2D) -> void:
	self.texture = texture
	used_pixels = []
	if not texture:
		size = Vector2i(0, 0)
		print("texture is null")
		return
	var image: Image = texture.get_image()
	size = image.get_size()
	for x in size.x:
		for y in size.y:
			var color: Color = image.get_pixel(x, y)
			if not color.a == 0:
				used_pixels.append(Vector2i(x, y))
