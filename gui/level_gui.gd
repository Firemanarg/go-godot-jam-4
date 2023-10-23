extends Control


signal chisel_selected(chisel)

@onready var label_timer = %LabelTimer
@onready var label_name = %LabelSculptureName
@onready var ref_visualizer = %SculptureReferenceVisualizer

@onready var chisel_single_pixel_button = get_node("MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer2/ChiselSinglePixelButton")
@onready var chisel_cross_pixel_button = get_node("MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer2/ChiselCrossPixelButton")
@onready var chisel_2x2_square_pixel_button = get_node("MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer2/Chisel2x2SquarePixelButton")

func _ready():
	pass


func _process(delta):
	pass


func set_current_time(time: float = 0.0) -> void:
	var seconds: int = fmod(time, 60.0)
	var minutes: int = int(time / 60.0) % 60
	label_timer.text = "%02d:%02d" % [minutes, seconds]


func set_reference(reference = null) -> void:
	ref_visualizer.set_reference(reference)
	if reference == null:
		return
	label_name.text = reference.sculpture_name
	set_current_time(reference.time)


func update() -> void:
	ref_visualizer.update()
	label_name.text = ref_visualizer.reference.sculpture_name


func _on_chisel_single_pixel_button_pressed() -> void:
	chisel_selected.emit(chisel_single_pixel_button)


func _on_chisel_cross_pixel_button_pressed() -> void:
	chisel_selected.emit(chisel_cross_pixel_button)


func _on_chisel_2x2_square_pixel_button_pressed() -> void:
	chisel_selected.emit(chisel_2x2_square_pixel_button)
