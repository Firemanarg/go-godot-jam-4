extends Node


const MATCH_WEIGHT: Array[float] = [1.0, 3.0]
const UNMATCH_WEIGHT: Array[float] = [2.0, 3.0]
const EMPTY: int = 0
const NOT_EMPTY: int = 1

@onready var sculpture_block = get_node("Level/SculptureBlock")
@onready var sculpture_reference = get_node("Level/SculptureReference")
@onready var reference_visualizer = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/SculptureReferenceVisualizer")
@onready var button_check = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/ButtonCheck")
@onready var label_percent = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer/LabelPercent")


func _ready():
	reference_visualizer.reference = sculpture_reference


func _process(delta):
	pass


func _physics_process(delta):
	pass


func get_sculpture_match_percent() -> float:
	var size: Vector2i = sculpture_reference.size
	var max_size: int = size.x * size.y
	var original_pixels: Array[Vector2i] = sculpture_reference.used_pixels
	var copy_pixels: Array[Vector2i] = sculpture_block.get_used_pixels()

	var max_match_count: Array[int] = [
		max_size - original_pixels.size(),
		original_pixels.size(),
	]
	var max_unmatch_count: Array[int] = [
		max_match_count[NOT_EMPTY],
		max_match_count[EMPTY],
	]

	var match_count: Array[int] = [0, 0]
	var unmatch_count: Array[int] = [0, 0]
	for x in size.x:
		for y in size.y:
			var pos: Vector2i = Vector2i(x, y)
			if pos in copy_pixels:
				if pos in original_pixels:
					match_count[NOT_EMPTY] += 1
				else:
					unmatch_count[NOT_EMPTY] += 1
			elif not pos in copy_pixels:
				if not pos in original_pixels:
					match_count[EMPTY] += 1
				else:
					unmatch_count[EMPTY] += 1

	var total_match: Array[float] = [
		lerp(0.0, 1.0, float(match_count[EMPTY]) / max_match_count[EMPTY]),
		lerp(0.0, 1.0, float(match_count[NOT_EMPTY]) / max_match_count[NOT_EMPTY]),
	]
	var total_unmatch: Array[float] = [
		lerp(0.0, 1.0, float(unmatch_count[EMPTY]) / max_unmatch_count[EMPTY]),
		lerp(0.0, 1.0, float(unmatch_count[NOT_EMPTY]) / max_unmatch_count[NOT_EMPTY]),
	]
	var match_percent: float = (
			(total_match[EMPTY] * MATCH_WEIGHT[EMPTY])
			+ (total_match[NOT_EMPTY] * MATCH_WEIGHT[NOT_EMPTY])
		) / (MATCH_WEIGHT[EMPTY] + MATCH_WEIGHT[NOT_EMPTY])
	var unmatch_percent: float = (
			total_unmatch[EMPTY] * UNMATCH_WEIGHT[EMPTY]
			+ total_unmatch[NOT_EMPTY] * UNMATCH_WEIGHT[NOT_EMPTY]
		) / (UNMATCH_WEIGHT[EMPTY] + UNMATCH_WEIGHT[NOT_EMPTY])
	var percent: float = match_percent - unmatch_percent
	percent = clamp(percent, 0.0, 1.0)
	return (percent)


func _change_sculpture(sculpture_data: Dictionary) -> void:
	sculpture_reference.set_sculpture_data(sculpture_data)
	reference_visualizer.update()


func _on_button_check_pressed():
	var match_percent: float = round(get_sculpture_match_percent() * 100)
	label_percent.text = str(match_percent) + "%"


func _on_button_smile_pressed():
	var data: Dictionary = Sculptures.get_sculpture_data(8, 0)
	_change_sculpture(data)
	sculpture_block.set_size(sculpture_reference.size)
	print("Setting sculpture to ", data["name"])


func _on_button_toy_1_pressed():
	var data: Dictionary = Sculptures.get_sculpture_data(8, 1)
	_change_sculpture(data)
	sculpture_block.set_size(sculpture_reference.size)
	print("Setting sculpture to ", data["name"])


func _on_button_skull_pressed():
	var data: Dictionary = Sculptures.get_sculpture_data(16, 0)
	_change_sculpture(data)
	sculpture_block.set_size(sculpture_reference.size)
	print("Setting sculpture to ", data["name"])
