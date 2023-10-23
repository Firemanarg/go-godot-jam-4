extends Dialog


func _ready():
	dialogs = [
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "scaried_shaking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "Oh no, what have I done?",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "scaried_shaking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "All the sculptures are broken!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "scaried"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "What am I supposed to do now?",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "neutral"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "I have to find a solution before the museum opens!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "Think, think, think...",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "happy_surprised"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "I know what to do!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "smiling"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "All I have to do is carve a copy of each sculpture that I broke!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "smiling"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "The fewer mistakes I have, the more alike they will become.",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "proud"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "After all, less is more!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "worried"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "But what if someone notices? I'll lose my job!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "worried"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "Will I be able to do it? I've never carved anything before...",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "neutral"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "I only have until 6:00 am to finish...",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "smiling"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "I think I can do it!",
			"side": Side.RIGHT,
		},
	]
