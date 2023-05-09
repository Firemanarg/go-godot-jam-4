extends Node

# fields: name (display name), texture (image texture), time (time in seconds)
const SCULPTURES: Dictionary = {
	"8px": [
		{
			"name": "Smile",
			"texture": preload("res://assets/images/sculptures/8px/smile.png"),
			"time": 20.0,
		},
		{
			"name": "Toy 1",
			"texture": preload("res://assets/images/sculptures/8px/toy1.png"),
			"time": 20.0,
		}
	],
	"16px": [
		{
			"name": "Skull",
			"texture": preload("res://assets/images/sculptures/16px/skull.png"),
			"time": 40.0,
		},
	]
}

func get_sculpture_data(pixel_size: int, index: int) -> Dictionary:
	if not pixel_size in [8, 16, 24]:
		return {}
	var size_str: String = str(pixel_size) + "px"
	return (SCULPTURES[size_str][index])
