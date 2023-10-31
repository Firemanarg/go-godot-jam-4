extends TextureButton

const HOVER_SCALE: float = 1.2
const PRESSED_SCALE: float = 1.1
const DEFAULT_MODULATE: Color = Color(1, 1, 1, 1)
const PRESSED_MODULATE: Color = Color(0.6, 0.6, 0.6, 1)

@export var chisel: Chisel = null


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	scale = Vector2.ONE * HOVER_SCALE


func _on_mouse_exited() -> void:
	scale = Vector2.ONE


#func _on_pressed() -> void:
#	scale = Vector2.ONE
#	modulate = PRESSED_MODULATE


func _on_button_down() -> void:
	modulate = PRESSED_MODULATE


func _on_button_up() -> void:
	modulate = DEFAULT_MODULATE
