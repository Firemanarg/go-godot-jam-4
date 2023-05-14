extends Node
class_name Dialog


signal started
signal finished

enum Side { LEFT = 0, RIGHT = 1 }

@export var text_appear_speed: float = 16.0

# Mandatory fields:
#  "visible_actors" -> PackedStringArray, "actors_animations" -> Dictionary(String: String),
#  "visible_backgrounds" -> PackedStingArray, text" -> String, "side" (0 LEFT or 1 RIGHT) -> int
@export var dialogs: Array[Dictionary] = []

var _curr_dialog_index: int = 0
var _dialog_side: int = Side.LEFT : set = set_dialog_side
var _current_text: String = "" : set = set_current_text
var _curr_tween: Tween = null
var _tween_in_progress: bool = false

@onready var camera = get_node("Camera2D")
@onready var label_text: Array = [ %LeftLabelText, %RightLabelText ]
@onready var container: Array = [
	get_node("TextLayer/Control/LeftContainer"),
	get_node("TextLayer/Control/RightContainer")
]
@onready var label_continue: Array = [ %LeftLabelContinue, %RightLabelContinue ]


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
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "I know what to do!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "All I have to do is carve a copy of each sculpture that I broke!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "The fewer mistakes I have, the more alike they will become.",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "After all, less is more!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "But what if someone notices? I'll lose my job!",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "Will I be able to do it? I've never carved anything before...",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "I only have until 6:00 am to finish...",
			"side": Side.RIGHT,
		},
		{
			"visible_actors": PackedStringArray(["MainCharacter"]),
			"actors_animations": {"MainCharacter": "thinking"},
			"visible_backgrounds": PackedStringArray(["DestroyedMuseum"]),
			"text": "I think I can do it!",
			"side": Side.RIGHT,
		},
	]
#	play_curr_dialog()
	pass


func _process(delta):
	pass


func play() -> void:
	camera.enabled = true
	_curr_dialog_index = 0
	started.emit()
	play_curr_dialog()


func play_curr_dialog() -> void:
	if _curr_dialog_index == dialogs.size():
		finished.emit()
		return
	var dialog: Dictionary = dialogs[_curr_dialog_index]
	var visible_actors: PackedStringArray = dialog.get("visible_actors", [])
	var actors_animations: Dictionary = dialog.get("actors_animations", {})
	var visible_backgrounds: PackedStringArray = dialog.get("visible_backgrounds", [])
	var text: String = dialog.get("text", "")
	var side: int = dialog.get("side", Side.LEFT)
	set_visible_actors(visible_actors, actors_animations)
	set_visible_backgrounds(visible_backgrounds)
	set_current_text(text)
	set_dialog_side(side)
	show_text_animated()


func skip(full_skip: bool = false) -> void:
	if full_skip:
		_curr_dialog_index = dialogs.size()
		finished.emit()
		return
	if _tween_in_progress:
		_curr_tween.kill()
		_tween_in_progress = false
		var label = label_text[_dialog_side]
		label.visible_ratio = 1.0
		label_continue[Side.LEFT].visible = true
		label_continue[Side.RIGHT].visible = true
	else:
		if _curr_dialog_index == dialogs.size():
			finished.emit()
		else:
			_curr_dialog_index += 1
			play_curr_dialog()


func show_text_animated() -> void:
	var char_count: int = len(_current_text)
	var time: float = char_count / text_appear_speed
	var label = label_text[_dialog_side]
	label.visible_ratio = 0.0
	_curr_tween = create_tween()
	_curr_tween.finished.connect(_on_tween_finished)
	_curr_tween.tween_property(label, "visible_ratio", 1.0, time)
	_tween_in_progress = true


func set_dialog_side(side: int) -> void:
	_dialog_side = side
	if container[Side.LEFT]:
		container[Side.LEFT].visible = (side == Side.LEFT)
	if container[Side.RIGHT]:
		container[Side.RIGHT].visible = (side == Side.RIGHT)
	if label_continue[Side.LEFT]:
		label_continue[Side.LEFT].visible = false
	if label_continue[Side.RIGHT]:
		label_continue[Side.RIGHT].visible = false


func set_current_text(text: String):
	_current_text = text
	if label_text[Side.LEFT]:
		label_text[Side.LEFT].text = text
	if label_text[Side.RIGHT]:
		label_text[Side.RIGHT].text = text


func set_visible_actors(visible_actors: PackedStringArray, animations: Dictionary) -> void:
	for actor in get_node("Actors").get_children():
		actor.visible = (actor.name in visible_actors)
		var anim_name: String = animations.get(actor.name, "")
		if actor.has_node("AnimationPlayer") and not anim_name.is_empty():
			var anim_player = actor.get_node("AnimationPlayer")
			anim_player.play(anim_name)


func set_visible_backgrounds(visible_backgrounds: PackedStringArray) -> void:
	for background in get_node("Backgrounds").get_children():
		background.visible = (background.name in visible_backgrounds)


func _on_tween_finished():
	label_continue[Side.LEFT].visible = true
	label_continue[Side.RIGHT].visible = true
	_tween_in_progress = false
	_curr_dialog_index += 1
	if _curr_dialog_index == dialogs.size():
		finished.emit()
