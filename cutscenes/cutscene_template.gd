extends Node
class_name Cutscene


signal started
signal finished

@export var animations_names_list: PackedStringArray = PackedStringArray()

var curr_index: int = 0

@onready var actors = get_node("Actors")
@onready var camera = get_node("Camera2D")
@onready var anim_player = get_node("AnimationPlayer")


func _ready():
	pass


func _process(delta):
	pass


func play() -> void:
	if not animations_names_list.is_empty():
		camera.enabled = true
		anim_player.play(animations_names_list[0])
		curr_index = 0
		started.emit()


func skip() -> void:
	finished.emit()

func _on_animation_player_animation_finished(anim_name):
	if curr_index == animations_names_list.size() - 1:
		curr_index = 0
		finished.emit()
	else:
		curr_index += 1
		anim_player.play(animations_names_list[curr_index])
