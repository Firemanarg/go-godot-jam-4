extends Node


@onready var sculpture_block = get_node("Level/SculptureBlock")
@onready var reference_visualizer = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/SculptureReferenceVisualizer")
@onready var button_check = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/ButtonCheck")
@onready var label_percent = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/LabelPercent")


func _ready():
	pass


func _process(delta):
	pass


func _physics_process(delta):
	pass

func _on_button_check_pressed():
	var block_pixels: Array[Vector2i] = sculpture_block.get_used_pixels()
	var reference_pixels: Array[Vector2i] = reference_visualizer
	pass
