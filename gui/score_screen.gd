extends Control


signal button_play_again_pressed
signal button_return_pressed

@onready var label_score = %LabelScore


func _ready():
	pass


func _process(delta):
	pass


func _physics_process(delta):
	pass


func set_score(score: int) -> void:
	label_score.text = str(score)


func _on_button_play_again_pressed():
	print("Play again!")
	button_play_again_pressed.emit()


func _on_button_return_main_screen_pressed():
	print("Return to main screen!")
	button_return_pressed.emit()
