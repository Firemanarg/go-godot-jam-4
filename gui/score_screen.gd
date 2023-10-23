extends Control


#signal button_play_again_pressed
#signal button_return_pressed
signal button_pressed(action_name: String)

@onready var label_score = %LabelScore
@onready var label_percent = %LabelPercent
@onready var character = get_node("MainCharacter")
@onready var anim_player = get_node("MainCharacter/AnimationPlayer")


func _ready():
	pass


func _process(delta):
	pass


func _physics_process(delta):
	pass


func set_score(score: int) -> void:
	label_score.text = str(score)


func set_percent(percent: float) -> void:
	var clamped: int = clamp(percent, 0.0, 1.0) * 100
	label_percent.text = str(clamped) + "%"


func play_victory_animation() -> void:
	anim_player.play("victory")


func play_defeat_animation() -> void:
	anim_player.play("defeat")


func _on_button_play_again_pressed():
	print("Play again!")
#	button_play_again_pressed.emit()
	button_pressed.emit("play_again")


func _on_button_return_main_screen_pressed():
	print("Return to main screen!")
#	button_return_pressed.emit()
	button_pressed.emit("main_screen")
