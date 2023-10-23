extends Button


const HOVER_SCALE: float = 1.2
const PRESSED_SCALE: float = 1.1
const DEFAULT_MODULATE: Color = Color(1, 1, 1, 1)
const PRESSED_MODULATE: Color = Color(0.6, 0.6, 0.6, 1)

var _is_mouse_over: bool = false


func _ready():
	pass


func _process(delta):
	pass


func _on_mouse_entered():
	scale = Vector2(HOVER_SCALE, HOVER_SCALE)
	_is_mouse_over = true


func _on_mouse_exited():
	scale = Vector2(1, 1)
	_is_mouse_over = false


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				scale = Vector2(PRESSED_SCALE, PRESSED_SCALE)
#				modulate = PRESSED_MODULATE
			else:
				if _is_mouse_over:
					scale = Vector2(HOVER_SCALE, HOVER_SCALE)
				else:
					scale = Vector2(1, 1)
#				modulate = DEFAULT_MODULATE
