extends Control


signal started
signal finished

enum { STOPPED = -1, FADE_IN, FADE_OUT }

const TRANSPARENT_COLOR: Color = Color(0, 0, 0, 0)

@export var color: Color = Color(0.09411764889956, 0.09411764889956, 0.09411764889956)
@export var duration_in: float = 1.0
@export var duration_out: float = 1.0

var _state: int = STOPPED

@onready var color_rect = get_node("ColorRect")


func _ready():
	pass


func _process(delta):
	pass


func fade_in(duration: float = duration_in) -> void:
	_state = FADE_IN
	started.emit()
	if duration > 0.0:
		_fade(color, TRANSPARENT_COLOR, duration)
	else:
		color_rect.color = TRANSPARENT_COLOR
		_state = STOPPED
		visible = false
		finished.emit()


func fade_out(duration: float = duration_out) -> void:
	_state = FADE_OUT
	started.emit()
	if duration > 0.0:
		_fade(TRANSPARENT_COLOR, color, duration)
	else:
		color_rect.color = color
		_state = STOPPED
		finished.emit()


func _fade(initial_color: Color, final_color: Color, duration: float = self.duration) -> void:
	visible = true
	var tween: Tween = create_tween()
	tween.finished.connect(_on_tween_finished)
	color_rect.color = initial_color
	tween.tween_property(color_rect, "color", final_color, duration)


func _on_tween_finished() -> void:
	_state = STOPPED
	visible = false
	finished.emit()
