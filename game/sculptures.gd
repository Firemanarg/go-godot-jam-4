extends Node

# fields: name (display name), texture (image texture), time (time in seconds)
const SCULPTURES: Dictionary = {
	"8px": [
		{
			"name": "Boat",
			"texture": preload("res://assets/images/sculptures/8px/boat.png"),
			"time": 14.0,
		},
		{
			"name": "Cookie",
			"texture": preload("res://assets/images/sculptures/8px/cookie.png"),
			"time": 14.0,
		},
		{
			"name": "Form 1",
			"texture": preload("res://assets/images/sculptures/8px/form1.png"),
			"time": 14.0,
		},
		{
			"name": "Form 2",
			"texture": preload("res://assets/images/sculptures/8px/form2.png"),
			"time": 14.0,
		},
		{
			"name": "House",
			"texture": preload("res://assets/images/sculptures/8px/house.png"),
			"time": 14.0,
		},
		{
			"name": "Pistol",
			"texture": preload("res://assets/images/sculptures/8px/pistol.png"),
			"time": 14.0,
		},
		{
			"name": "Play",
			"texture": preload("res://assets/images/sculptures/8px/play.png"),
			"time": 14.0,
		},
		{
			"name": "Slime",
			"texture": preload("res://assets/images/sculptures/8px/slime.png"),
			"time": 14.0,
		},
		{
			"name": "Smile",
			"texture": preload("res://assets/images/sculptures/8px/smile.png"),
			"time": 14.0,
		},
		{
			"name": "Toy 1",
			"texture": preload("res://assets/images/sculptures/8px/toy1.png"),
			"time": 20.0,
		},
		{
			"name": "X",
			"texture": preload("res://assets/images/sculptures/8px/x.png"),
			"time": 14.0,
		}
	],
	"16px": [
		{
			"name": "Calculator",
			"texture": preload("res://assets/images/sculptures/16px/calculator.png"),
			"time": 40.0,
		},
		{
			"name": "Chip",
			"texture": preload("res://assets/images/sculptures/16px/chip.png"),
			"time": 40.0,
		},
		{
			"name": "Crepi",
			"texture": preload("res://assets/images/sculptures/16px/crepi.png"),
			"time": 40.0,
		},
		{
			"name": "Cristu",
			"texture": preload("res://assets/images/sculptures/16px/cristu.png"),
			"time": 40.0,
		},
		{
			"name": "Dog 1",
			"texture": preload("res://assets/images/sculptures/16px/dog1.png"),
			"time": 40.0,
		},
		{
			"name": "Donut",
			"texture": preload("res://assets/images/sculptures/16px/donut.png"),
			"time": 40.0,
		},
		{
			"name": "Heart",
			"texture": preload("res://assets/images/sculptures/16px/heart.png"),
			"time": 40.0,
		},
		{
			"name": "Mando",
			"texture": preload("res://assets/images/sculptures/16px/mando.png"),
			"time": 40.0,
		},
		{
			"name": "Mongus",
			"texture": preload("res://assets/images/sculptures/16px/mongus.png"),
			"time": 40.0,
		},
		{
			"name": "Mouse",
			"texture": preload("res://assets/images/sculptures/16px/mouse.png"),
			"time": 40.0,
		},
		{
			"name": "Skull",
			"texture": preload("res://assets/images/sculptures/16px/skull.png"),
			"time": 40.0,
		},
	],
	"24px": [
		{
			"name": "Computer",
			"texture": preload("res://assets/images/sculptures/24px/computer.png"),
			"time": 40.0,
		},
		{
			"name": "Creature",
			"texture": preload("res://assets/images/sculptures/24px/creature.png"),
			"time": 40.0,
		},
		{
			"name": "Cyber Cat",
			"texture": preload("res://assets/images/sculptures/24px/cybercat.png"),
			"time": 40.0,
		},
		{
			"name": "Dog 2",
			"texture": preload("res://assets/images/sculptures/24px/dog2.png"),
			"time": 40.0,
		},
		{
			"name": "Lisamona",
			"texture": preload("res://assets/images/sculptures/24px/lisamona.png"),
			"time": 40.0,
		},
		{
			"name": "Liberty",
			"texture": preload("res://assets/images/sculptures/24px/liberty.png"),
			"time": 40.0,
		}
	]
}

func get_sculpture_data(pixel_size: int, index: int) -> Dictionary:
	if not pixel_size in [8, 16, 24]:
		return ({})
	var size_str: String = str(pixel_size) + "px"
	return (SCULPTURES[size_str][index])
