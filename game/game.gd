extends Node


const PRL_SCREEN_MAIN = preload("res://gui/main_screen.tscn")
const PRL_SCREEN_DIFFICULTY_CHOOSE = preload("res://gui/difficulty_choose_screen.tscn")
const PRL_CUTSCENE_INTRO = preload("res://cutscenes/intro_cutscene.tscn")
const PRL_DIALOG_POST_INTRO = preload("res://dialogs/intro_post_cutscene_dialog.tscn")
const PRL_LEVEL = preload("res://game/level.tscn")
const PRL_LEVEL_GUI = preload("res://gui/level_gui.tscn")
const CARVING_SOUNDS: Array = [
	preload("res://assets/sounds/carving/carving_1.wav"),
	preload("res://assets/sounds/carving/carving_2.wav"),
	preload("res://assets/sounds/carving/carving_3.wav"),
]
const STARTING_SCULPTURE_SOUND = preload("res://assets/sounds/starting_sculpture.wav")

const DIFFICULTY_DICTIONARY = {
	Difficulty.NOVICE: {8: 5, 16: 1},
	Difficulty.NORMAL: {8: 6, 16: 2},
	Difficulty.MADNESS: {8: 2, 16: 5, 24: 1},
}

enum Difficulty { NOVICE, NORMAL, MADNESS }

var _curr_gui_element = null
var _level = null
var _difficulty: int = Difficulty.NORMAL
var _is_match_in_progress: bool = false

var _refs_list: Array[Dictionary] = []
var _scores: PackedInt32Array = []

@onready var gui_layer = get_node("GUILayer")
@onready var cinematic_transition = get_node("TransitionLayer/CinematicTransition")
@onready var timer = get_node("Timer")
@onready var music_player = get_node("MusicStreamPlayer")
@onready var sound_player = get_node("SoundStreamPlayer")


func _ready():
	cinematic_transition.duration_in = 0.8
	cinematic_transition.duration_out = 0.8
	music_player.play()
	_curr_gui_element = PRL_SCREEN_MAIN.instantiate()
	_curr_gui_element.button_play_pressed.connect(_on_button_play_pressed)
	_curr_gui_element.button_settings_pressed.connect(_on_button_settings_pressed)
	_curr_gui_element.button_credits_pressed.connect(_on_button_credits_pressed)
	gui_layer.add_child(_curr_gui_element)


func _process(delta):
	if _is_match_in_progress:
		_curr_gui_element.set_current_time(timer.time_left)
	else:
		if _curr_gui_element is Cutscene:
			if Input.is_action_just_pressed("skip_cinematic"):
				_curr_gui_element.skip()
		elif _curr_gui_element is Dialog:
			if Input.is_action_just_pressed("skip_cinematic"):
				_curr_gui_element.skip(true)
			elif Input.is_action_just_pressed("skip_dialog"):
				_curr_gui_element.skip()


func cinematic_fade_in(duration: float = cinematic_transition.duration_in) -> void:
	cinematic_transition.visible = true
	cinematic_transition.fade_in(duration)
	await cinematic_transition.finished
	cinematic_transition.visible = false


func cinematic_fade_out(duration: float = cinematic_transition.duration_out) -> void:
	cinematic_transition.visible = true
	cinematic_transition.fade_out(duration)


func start_match(difficulty: int):
	var refs_list: Array[Dictionary] = generate_references_list(DIFFICULTY_DICTIONARY[_difficulty])
	var score: int = 0
	_is_match_in_progress = true
	_level.enable_edition()
	print("Match started!")
	for ref in refs_list:
		print("Round started!")
		play_sound(STARTING_SCULPTURE_SOUND)
		_level.set_sculpture_data(ref)
		_curr_gui_element.update()
		timer.start(_level.reference.time)
		await timer.timeout
		var round_score: int = _level.get_score_percent() * 10000
		score += round_score
		print("Round finished! Score: ", round_score)
	print("Match finished! Score: ", score)
	_level.enable_edition(false)
	_is_match_in_progress = false


func play_sound(sound) -> void:
	sound_player.set_stream(sound)
	sound_player.play()


func play_music(music) -> void:
	music_player.set_stream(music)
	music_player.play()


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


func _on_button_play_pressed() -> void:
	print("Play")
	cinematic_fade_out()
	await cinematic_transition.finished
	_curr_gui_element.queue_free()
	_curr_gui_element = PRL_SCREEN_DIFFICULTY_CHOOSE.instantiate()
	_curr_gui_element.button_novice_pressed.connect(_on_difficulty_choose.bind(Difficulty.NOVICE))
	_curr_gui_element.button_normal_pressed.connect(_on_difficulty_choose.bind(Difficulty.NORMAL))
	_curr_gui_element.button_madness_pressed.connect(_on_difficulty_choose.bind(Difficulty.MADNESS))
	gui_layer.add_child(_curr_gui_element)
	cinematic_fade_in()
	pass


func _on_button_settings_pressed() -> void:
	print("Settings")
	pass


func _on_button_credits_pressed() -> void:
	print("Credits")
	pass


func _on_difficulty_choose(difficulty: int):
	print("Difficulty: ", difficulty)
	_difficulty = difficulty
	cinematic_fade_out()
	await cinematic_transition.finished
	music_player.stop()
	_curr_gui_element.queue_free()
	_curr_gui_element = PRL_CUTSCENE_INTRO.instantiate()
	_curr_gui_element.finished.connect(_on_intro_cutscene_finished)
	gui_layer.add_child(_curr_gui_element)
	cinematic_fade_in()
	_curr_gui_element.play()


func _on_intro_cutscene_finished() -> void:
	print("Cutscene finished!")
	cinematic_fade_out()
	await cinematic_transition.finished
	_curr_gui_element.queue_free()
	_curr_gui_element = PRL_DIALOG_POST_INTRO.instantiate()
	_curr_gui_element.finished.connect(_on_dialog_post_intro_finished)
	gui_layer.add_child(_curr_gui_element)
	cinematic_fade_in()
	_curr_gui_element.play()


func _on_dialog_post_intro_finished() -> void:
	print("Dialog finished!")
	cinematic_fade_out()
	await cinematic_transition.finished
	_curr_gui_element.queue_free()
	_level = PRL_LEVEL.instantiate()
	_level.block_carved.connect(_on_block_carved)
	gui_layer.add_child(_level)
	_curr_gui_element = PRL_LEVEL_GUI.instantiate()
	gui_layer.add_child(_curr_gui_element)
	_curr_gui_element.set_reference(_level.reference)
	cinematic_fade_in()
	start_match(_difficulty)


func _on_block_carved() -> void:
	play_sound(CARVING_SOUNDS.pick_random())























#const FADE_IN_DURATION: float = 0.8
#const FADE_OUT_DURATION: float = 0.8
#const MATCH_WEIGHT: Array[float] = [1.0, 3.0]
#const UNMATCH_WEIGHT: Array[float] = [2.0, 3.0]
#const EMPTY: int = 0
#const NOT_EMPTY: int = 1
#const INTRO_CINEMATIC_PRELOAD = preload("res://cinematics/intro_cinematic.tscn")
#const INTRO_POST_CINEMATIC_DIALOG_PRELOAD = preload("res://dialogs/intro_post_cinematic_dialog.tscn")
#
#var is_match_in_progress: bool = false
#var refs_list: Array[Dictionary] = []
#var curr_round: int = 0
#var curr_ref: Dictionary = {}
#var scores: Array = []
#
#var current_cinematic = null
#
#@onready var sculpture = get_node("Level/Sculpture")
#@onready var sculpture_block = get_node("Level/Sculpture/SculptureBlock")
#@onready var sculpture_reference = get_node("Level/Sculpture/SculptureReference")
#@onready var reference_visualizer = get_node("CanvasLayerOld/MarginContainer/HBoxContainer/VBoxContainer/SculptureReferenceVisualizer")
#@onready var timer = get_node("Timer")
#@onready var label_timer = get_node("CanvasLayerOld/MarginContainer/VBoxContainer/LabelTimer")
#@onready var cinematic_layer = get_node("CinematicLayer")
#@onready var transition = get_node("TransitionLayer/CinematicTransition")
#
#
#func _ready():
#	reference_visualizer.reference = sculpture_reference
#	transition.duration_in = FADE_IN_DURATION
#	transition.duration_out = FADE_OUT_DURATION
#
##	cinematic_transition(
##		INTRO_CINEMATIC_PRELOAD.instantiate(),
##		_on_intro_cinematic_finished)
#
#
#func _process(delta):
#	if current_cinematic:
#		if current_cinematic is Cinematic:
#			if Input.is_action_just_pressed("skip_cinematic"):
#				current_cinematic.skip()
#		elif current_cinematic is Dialog:
#			if Input.is_action_just_pressed("skip_cinematic"):
#				current_cinematic.skip(true)
#			if Input.is_action_just_pressed("skip_dialog"):
#				current_cinematic.skip()
#	if is_match_in_progress:
#		_update_timer(timer.get_time_left())
#
#
#func _physics_process(delta):
#	pass
#
#
#func set_current_cinematic(cinematic, finished_func: Callable) -> void:
#	if current_cinematic:
#		current_cinematic.queue_free()
#	current_cinematic = cinematic
#	current_cinematic.finished.connect(finished_func)
#	cinematic_layer.add_child(current_cinematic)
#
#
#func play_current_cinematic() -> void:
#	current_cinematic.play()
#
#
#func begin_match(refs_amount: Dictionary = {}) -> void:
#	refs_list = generate_references_list(refs_amount)
#	scores = []
#	begin_round()
#	is_match_in_progress = true
#
#
#func begin_round() -> void:
#	if curr_round >= refs_list.size():
#		return
#	curr_ref = refs_list[curr_round]
#	timer.start(curr_ref.get("time", 0.0))
#	_change_sculpture(curr_ref)
#	sculpture_block.enable_edition()
#
#
#func generate_references_list(amounts: Dictionary = {}) -> Array[Dictionary]:
#	if amounts.is_empty():
#		return ([])
#	var refs_list: Array[Dictionary] = []
#	for size in amounts.keys():
#		if not size in [8, 16, 24]:
#			continue
#		var count: int = amounts.get(size, 0)
#		if not count == 0:
#			var shuffled_indexes: Array = range(len(Sculptures.SCULPTURES[str(size) + "px"]))
#			shuffled_indexes.shuffle()
#			for index in shuffled_indexes:
#				refs_list.append(Sculptures.get_sculpture_data(size, index))
#	return (refs_list)
#
#
#func get_sculpture_match_percent() -> float:
#	var size: Vector2i = sculpture_reference.size
#	var max_size: int = size.x * size.y
#	var original_pixels: Array[Vector2i] = sculpture_reference.used_pixels
#	var copy_pixels: Array[Vector2i] = sculpture_block.get_used_pixels()
#
#	var max_match_count: Array[int] = [
#		max_size - original_pixels.size(),
#		original_pixels.size(),
#	]
#	var max_unmatch_count: Array[int] = [
#		max_match_count[NOT_EMPTY],
#		max_match_count[EMPTY],
#	]
#
#	var match_count: Array[int] = [0, 0]
#	var unmatch_count: Array[int] = [0, 0]
#	for x in size.x:
#		for y in size.y:
#			var pos: Vector2i = Vector2i(x, y)
#			if pos in copy_pixels:
#				if pos in original_pixels:
#					match_count[NOT_EMPTY] += 1
#				else:
#					unmatch_count[NOT_EMPTY] += 1
#			elif not pos in copy_pixels:
#				if not pos in original_pixels:
#					match_count[EMPTY] += 1
#				else:
#					unmatch_count[EMPTY] += 1
#
#	var total_match: Array[float] = [
#		lerp(0.0, 1.0, float(match_count[EMPTY]) / max_match_count[EMPTY]),
#		lerp(0.0, 1.0, float(match_count[NOT_EMPTY]) / max_match_count[NOT_EMPTY]),
#	]
#	var total_unmatch: Array[float] = [
#		lerp(0.0, 1.0, float(unmatch_count[EMPTY]) / max_unmatch_count[EMPTY]),
#		lerp(0.0, 1.0, float(unmatch_count[NOT_EMPTY]) / max_unmatch_count[NOT_EMPTY]),
#	]
#	var match_percent: float = (
#			(total_match[EMPTY] * MATCH_WEIGHT[EMPTY])
#			+ (total_match[NOT_EMPTY] * MATCH_WEIGHT[NOT_EMPTY])
#		) / (MATCH_WEIGHT[EMPTY] + MATCH_WEIGHT[NOT_EMPTY])
#	var unmatch_percent: float = (
#			total_unmatch[EMPTY] * UNMATCH_WEIGHT[EMPTY]
#			+ total_unmatch[NOT_EMPTY] * UNMATCH_WEIGHT[NOT_EMPTY]
#		) / (UNMATCH_WEIGHT[EMPTY] + UNMATCH_WEIGHT[NOT_EMPTY])
#	var percent: float = match_percent - unmatch_percent
#	percent = clamp(percent, 0.0, 1.0)
#	return (percent)
#
#
#func cinematic_transition(next_cinematic, finished_func: Callable) -> void:
#	transition.fade_out()
#	await transition.finished
#	transition.fade_in()
#	if next_cinematic:
#		set_current_cinematic(next_cinematic, finished_func)
#		play_current_cinematic()
##		await transition.finished
#
#
#func _change_sculpture(sculpture_data: Dictionary) -> void:
#	sculpture_reference.set_sculpture_data(sculpture_data)
#	reference_visualizer.update()
#	sculpture_block.set_size(sculpture_reference.size)
#	sculpture.position.y = (sculpture_block.size.y / 2) * sculpture_block.cell_size.y
#
#
#func _update_timer(time: float = 0.0) -> void:
#	var seconds: int = fmod(time, 60.0)
#	var minutes: int = int(time / 60.0) % 60
#	label_timer.text = "%02d:%02d" % [minutes, seconds]
#
#
#func _on_timer_timeout():
#	var score: int = get_sculpture_match_percent() * 10000
#	scores.append(score)
#	curr_round += 1
#	sculpture_block.enable_edition(false)
#	begin_round()
#	pass
#
#
#func _on_intro_cinematic_finished() -> void:
#	transition.fade_out()
#
#	cinematic_transition(
#		INTRO_POST_CINEMATIC_DIALOG_PRELOAD.instantiate(),
#		_on_intro_post_cinematic_dialog_finished)
#
#
#func _on_intro_post_cinematic_dialog_finished() -> void:
#	print("Dialog finished!")
#	transition.fade_out()
#	await transition.finished
#	current_cinematic.queue_free()
#	current_cinematic = null
#	transition.fade_in()
#	begin_match({8: 2, 16: 1})
