extends Node


signal cinematic_started
signal cinematic_finished

@onready var actors = get_node("Actors")
@onready var camera = get_node("Camera2D")
@onready var anim_player = get_node("AnimationPlayer")


func _ready():
	pass


func _process(delta):
	pass


func play_cinematic() -> void:
	camera.enabled = true
	anim_player.play("start")
	cinematic_started.emit()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "start":
		cinematic_finished.emit()
