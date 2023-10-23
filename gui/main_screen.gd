extends Control


#signal button_play_pressed
#signal button_settings_pressed
#signal button_credits_pressed
signal button_pressed(action_name: String)


func _ready():
	pass


func _process(delta):
	pass


func _physics_process(delta):
	pass



func _on_button_play_pressed():
#	button_play_pressed.emit()
	button_pressed.emit("play")
#	print("button_play_pressed")


func _on_button_settings_pressed():
#	button_settings_pressed.emit()
	button_pressed.emit("settings")
#	print("button_settings_pressed")


func _on_button_credits_pressed():
#	button_credits_pressed.emit()
	button_pressed.emit("credits")
#	print("button_credits_pressed")
