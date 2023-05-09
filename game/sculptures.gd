extends Node

# fields: name (display name), texture (image texture), time (time in seconds)
const sculptures: Dictionary = {
	"8px": [
		{
			"name": "Smile",
			"texture": preload("res://assets/images/sculptures/8px/smile.png"),
			"time": 20,
			"size": Vector2i(8, 8),
		},
		{
			"name": "Toy 1",
			"texture": preload("res://assets/images/sculptures/8px/toy1.png"),
			"time": 20,
			"size": Vector2i(8, 8),
		}
	]
}

func get_sculpture_data(pixel_size: int, index: int) -> Dictionary:
	if not pixel_size in [8, 16, 24]:
		return {}
	var size_str: String = str(pixel_size) + "px"
	return (sculptures[size_str][index])
