extends Node


const MATCH_WEIGHT: Array[float] = [1.0, 3.0]
const UNMATCH_WEIGHT: Array[float] = [2.0, 3.0]
const EMPTY: int = 0
const NOT_EMPTY: int = 1

var is_match_in_progress: bool = false
var refs_list: Array[Dictionary] = []
var curr_round: int = 0
var curr_ref: Dictionary = {}
var scores: Array = []

@onready var sculpture = get_node("Level/Sculpture")
@onready var sculpture_block = get_node("Level/Sculpture/SculptureBlock")
@onready var sculpture_reference = get_node("Level/Sculpture/SculptureReference")
@onready var reference_visualizer = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/SculptureReferenceVisualizer")
@onready var timer = get_node("Timer")
@onready var label_timer = get_node("CanvasLayer/MarginContainer/VBoxContainer/LabelTimer")


func _ready():
	reference_visualizer.reference = sculpture_reference
	begin_match({8: 2, 16: 1})


func _process(delta):
	if is_match_in_progress:
		_update_timer(timer.get_time_left())


func _physics_process(delta):
	pass


func begin_match(refs_amount: Dictionary = {}) -> void:
	refs_list = generate_references_list(refs_amount)
	scores = []
	begin_round()
	is_match_in_progress = true


func begin_round() -> void:
	if curr_round >= refs_list.size():
		return
	curr_ref = refs_list[curr_round]
	timer.start(curr_ref.get("time", 0.0))
	_change_sculpture(curr_ref)
	sculpture_block.enable_edition()


func generate_references_list(amounts: Dictionary = {}) -> Array[Dictionary]:
	if amounts.is_empty():
		return ([])
	var refs_list: Array[Dictionary] = []
	for size in amounts.keys():
		if not size in [8, 16, 24]:
			continue
		var count: int = amounts.get(size, 0)
		if not count == 0:
			var shuffled_indexes: Array = range(len(Sculptures.SCULPTURES[str(size) + "px"]))
			shuffled_indexes.shuffle()
			for index in shuffled_indexes:
				refs_list.append(Sculptures.get_sculpture_data(size, index))
	return (refs_list)


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
	sculpture_block.set_size(sculpture_reference.size)
	sculpture.position.y = (sculpture_block.size.y / 2) * sculpture_block.cell_size.y


func _update_timer(time: float = 0.0) -> void:
	var seconds: int = fmod(time, 60.0)
	var minutes: int = int(time / 60.0) % 60
	label_timer.text = "%02d:%02d" % [minutes, seconds]


func _on_timer_timeout():
	var score: int = get_sculpture_match_percent() * 10000
	scores.append(score)
	curr_round += 1
	sculpture_block.enable_edition(false)
	begin_round()
	pass
