extends Node


const PRL_SCREEN_MAIN = preload("res://gui/main_screen.tscn")
const PRL_SCREEN_DIFFICULTY_CHOOSE = preload("res://gui/difficulty_choose_screen.tscn")
const PRL_SCREEN_SCORE = preload("res://gui/score_screen.tscn")
const PRL_CUTSCENE_INTRO = preload("res://cutscenes/intro_cutscene.tscn")
const PRL_DIALOG_POST_INTRO = preload("res://dialogs/intro_post_cutscene_dialog.tscn")
const PRL_LEVEL = preload("res://game/level.tscn")
const PRL_LEVEL_GUI = preload("res://gui/level_gui.tscn")
const CARVING_SOUNDS: Array = [
	preload("res://assets/sounds/carving/carving_1.wav"),
	preload("res://assets/sounds/carving/carving_2.wav"),
	preload("res://assets/sounds/carving/carving_3.wav"),
]
const PRL_SOUND_STARTING_SCULPTURE = preload("res://assets/sounds/starting_sculpture.wav")
const PRL_MUSIC_MAIN_MENU = preload("res://assets/musics/main_menu_improvisation.ogg")
const DIFFICULTY_DICTIONARY = {
	Difficulty.NOVICE: {8: 1},
#	Difficulty.NOVICE: {8: 5, 16: 1},
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
	play_music(PRL_MUSIC_MAIN_MENU, true)
	main_screen()
#	_curr_gui_element = PRL_SCREEN_MAIN.instantiate()
#	_curr_gui_element.button_play_pressed.connect(_on_button_play_pressed)
#	_curr_gui_element.button_settings_pressed.connect(_on_button_settings_pressed)
#	_curr_gui_element.button_credits_pressed.connect(_on_button_credits_pressed)
#	gui_layer.add_child(_curr_gui_element)


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
	print("Difficulty dictionary: ", DIFFICULTY_DICTIONARY[_difficulty])
	print("Refs list (", refs_list.size(), "): ", refs_list)
	var score: int = 0
	_is_match_in_progress = true
	_level.enable_edition()
	print("Match started!")
	var is_first: bool = true
	for ref in refs_list:
		print("Round started!")
		play_sound(PRL_SOUND_STARTING_SCULPTURE)
		_level.set_sculpture_data(ref)
		if is_first:
			_level.sculpture_block.enable_safe_regenerate(false)
			is_first = false
		_curr_gui_element.update()
		timer.start(_level.reference.time)
		await timer.timeout
		var round_score: int = _level.get_score_percent() * 10000
		score += round_score
		print("Round finished! Score: ", round_score)
	print("Match finished! Score: ", score)
	_level.enable_edition(false)
	_is_match_in_progress = false
	cinematic_fade_out()
	await cinematic_transition.finished
	score_screen(score)
	cinematic_fade_in()


func play_sound(sound, stop_previous: bool = false) -> void:
	if stop_previous:
		sound_player.stop()
	sound_player.set_stream(sound)
	sound_player.play()


func play_music(music, stop_previous: bool = false) -> void:
	if stop_previous:
		sound_player.stop()
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
		print("Generating references list -> size: ", size, " - count: ", count)
		if not count == 0:
			var shuffled_indexes: Array = range(len(Sculptures.SCULPTURES[str(size) + "px"]))
			shuffled_indexes.shuffle()
			print("Shuffled indexes: ", shuffled_indexes)
			for index in count:
				var fixed_index: int = index
				if index >= shuffled_indexes.size():
					fixed_index = shuffled_indexes.pick_random()
				print("Adding sculpture at ", fixed_index)
				refs_list.append(Sculptures.get_sculpture_data(size, fixed_index))
	return (refs_list)


func main_screen() -> void:
	_curr_gui_element = PRL_SCREEN_MAIN.instantiate()
	_curr_gui_element.button_play_pressed.connect(_on_button_play_pressed)
	_curr_gui_element.button_settings_pressed.connect(_on_button_settings_pressed)
	_curr_gui_element.button_credits_pressed.connect(_on_button_credits_pressed)
	gui_layer.add_child(_curr_gui_element)


func score_screen(score: int) -> void:
	if _curr_gui_element:
		_curr_gui_element.queue_free()
	_curr_gui_element = PRL_SCREEN_SCORE.instantiate()
	# Falta fazer os connects
	gui_layer.add_child(_curr_gui_element)
	_curr_gui_element.set_score(score)


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
