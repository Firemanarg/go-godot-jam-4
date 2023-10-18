extends Control


#signal button_novice_pressed
#signal button_normal_pressed
#signal button_madness_pressed
signal button_pressed(action_name: String)


func _ready():
	pass


func _process(delta):
	pass


func _on_button_novice_pressed():
#	button_novice_pressed.emit()
	button_pressed.emit("choose_novice")
	print("[signal]: emitted '", button_pressed, "'(choose_novice)")


func _on_button_normal_pressed():
#	button_normal_pressed.emit()
	button_pressed.emit("choose_normal")
	print("[signal]: emitted '", button_pressed, "'(choose_normal)")


func _on_button_madness_pressed():
#	button_madness_pressed.emit()
	button_pressed.emit("choose_madness")
	print("[signal]: emitted '", button_pressed, "'(choose_madness)")
