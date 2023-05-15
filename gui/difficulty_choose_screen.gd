extends Control


signal button_novice_pressed
signal button_normal_pressed
signal button_madness_pressed


func _ready():
	pass


func _process(delta):
	pass


func _on_button_novice_pressed():
	button_novice_pressed.emit()


func _on_button_normal_pressed():
	button_normal_pressed.emit()


func _on_button_madness_pressed():
	button_madness_pressed.emit()
