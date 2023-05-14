extends Control


signal button_play_pressed
signal button_settings_pressed
signal button_credits_pressed


func _ready():
	pass


func _process(delta):
	pass


func _physics_process(delta):
	pass



func _on_button_play_pressed():
	button_play_pressed.emit()


func _on_button_settings_pressed():
	button_settings_pressed.emit()


func _on_button_credits_pressed():
	button_credits_pressed.emit()
