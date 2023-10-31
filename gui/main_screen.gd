extends Control


signal button_pressed(action_name: String)


func _ready():
	pass


func _process(delta):
	pass


func _physics_process(delta):
	pass



func _on_button_play_pressed():
	button_pressed.emit("play")


func _on_button_settings_pressed():
	button_pressed.emit("settings")


func _on_button_credits_pressed():
	button_pressed.emit("credits")
