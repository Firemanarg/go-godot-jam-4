extends Node


const FADE_IN_DURATION: float = 0.8
const FADE_OUT_DURATION: float = 0.8
const MATCH_WEIGHT: Array[float] = [1.0, 3.0]
const UNMATCH_WEIGHT: Array[float] = [2.0, 3.0]
const EMPTY: int = 0
const NOT_EMPTY: int = 1
const INTRO_CINEMATIC_PRELOAD = preload("res://cinematics/intro_cinematic.tscn")
const INTRO_POST_CINEMATIC_DIALOG_PRELOAD = preload("res://dialogs/intro_post_cinematic_dialog.tscn")

var is_match_in_progress: bool = false
var refs_list: Array[Dictionary] = []
var curr_round: int = 0
var curr_ref: Dictionary = {}
var scores: Array = []

var current_cinematic = null

@onready var sculpture = get_node("Level/Sculpture")
@onready var sculpture_block = get_node("Level/Sculpture/SculptureBlock")
@onready var sculpture_reference = get_node("Level/Sculpture/SculptureReference")
@onready var reference_visualizer = get_node("CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/SculptureReferenceVisualizer")
@onready var timer = get_node("Timer")
@onready var label_timer = get_node("CanvasLayer/MarginContainer/VBoxContainer/LabelTimer")
@onready var cinematic_layer = get_node("CinematicLayer")
@onready var transition = get_node("TransitionLayer/CinematicTransition")


func _ready():
	reference_visualizer.reference = sculpture_reference
	transition.duration_in = FADE_IN_DURATION
	transition.duration_out = FADE_OUT_DURATION
	cinematic_transition(
		INTRO_CINEMATIC_PRELOAD.instantiate(),
		_on_intro_cinematic_finished)


func _process(delta):
	if current_cinematic:
		if current_cinematic is Cinematic:
			if Input.is_action_just_pressed("skip_cinematic"):
				current_cinematic.skip()
		elif current_cinematic is Dialog:
			if Input.is_action_just_pressed("skip_cinematic"):
				current_cinematic.skip(true)
			if Input.is_action_just_pressed("skip_dialog"):
				current_cinematic.skip()
	if is_match_in_progress:
		_update_timer(timer.get_time_left())


func _physics_process(delta):
	pass


func set_current_cinematic(cinematic, finished_func: Callable) -> void:
	if current_cinematic:
		current_cinematic.queue_free()
	current_cinematic = cinematic
	current_cinematic.finished.connect(finished_func)
	cinematic_layer.add_child(current_cinematic)


func play_current_cinematic() -> void:
	current_cinematic.play()


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


func cinematic_transition(next_cinematic, finished_func: Callable) -> void:
	transition.fade_out()
	await transition.finished
	transition.fade_in()
	if next_cinematic:
		set_current_cinematic(next_cinematic, finished_func)
		play_current_cinematic()
#		await transition.finished


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


func _on_intro_cinematic_finished() -> void:
	transition.fade_out()

	cinematic_transition(
		INTRO_POST_CINEMATIC_DIALOG_PRELOAD.instantiate(),
		_on_intro_post_cinematic_dialog_finished)


func _on_intro_post_cinematic_dialog_finished() -> void:
	print("Dialog finished!")
	transition.fade_out()
	await transition.finished
	current_cinematic.queue_free()
	current_cinematic = null
	transition.fade_in()
	begin_match({8: 2, 16: 1})
