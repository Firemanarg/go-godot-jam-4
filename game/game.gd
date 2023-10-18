extends Node


signal screen_changed

const PRL_SCREEN_MAIN = preload("res://gui/main_screen.tscn")
const PRL_SCREEN_DIFFICULTY_CHOOSE = preload("res://gui/difficulty_choose_screen.tscn")
const PRL_SCREEN_SCORE = preload("res://gui/score_screen.tscn")
const PRL_CUTSCENE_INTRO = preload("res://cutscenes/intro_cutscene.tscn")
const PRL_DIALOG_INTRO = preload("res://dialogs/intro_post_cutscene_dialog.tscn")
const PRL_LEVEL = preload("res://game/level.tscn")
const PRL_LEVEL_GUI = preload("res://gui/level_gui.tscn")
const CARVING_SOUNDS: Array = [
	preload("res://assets/sounds/carving/carving_1.wav"),
	preload("res://assets/sounds/carving/carving_2.wav"),
	preload("res://assets/sounds/carving/carving_3.wav"),
]
const PRL_SOUND_STARTING_SCULPTURE = preload("res://assets/sounds/starting_sculpture.wav")
const PRL_MUSIC_MAIN_MENU = preload("res://assets/musics/main_menu_improvisation.ogg")
const PRL_MUSIC_SCORE_DEFEAT = preload("res://assets/musics/defeat_music.ogg")
const PRL_MUSIC_SCORE_VICTORY = preload("res://assets/musics/victory_music.ogg")
const DIFFICULTY_DICTIONARY: Dictionary = {
	Difficulty.NOVICE: {8: 1},
#	Difficulty.NOVICE: {8: 5, 16: 1},
	Difficulty.NORMAL: {8: 6, 16: 2},
	Difficulty.MADNESS: {8: 2, 16: 5, 24: 1},
}
const DIFFICULTY_MULTIPLIER: Dictionary = {
	Difficulty.NOVICE: 1.0,
	Difficulty.NORMAL: 1.5,
	Difficulty.MADNESS: 2.0,
}
const SIZE_MULTIPLIER: Dictionary = {
	8: 5000,
	16: 10000,
	24: 15000,
}

enum Difficulty { NOVICE, NORMAL, MADNESS }

var _curr_gui = null
#var _level = null
var _difficulty: int = Difficulty.NORMAL
var _is_match_in_progress: bool = false

var _refs_list: Array[Dictionary] = []
var _percents: PackedFloat32Array = []
#var _scores: PackedInt32Array = []

@onready var gui_layer = get_node("GUILayer")
@onready var cinematic_transition = get_node("TransitionLayer/CinematicTransition")
@onready var timer = get_node("Timer")
@onready var music_player = get_node("MusicStreamPlayer")
@onready var sound_player = get_node("SoundStreamPlayer")


func _ready():
	cinematic_transition.duration_in = 0.8
	cinematic_transition.duration_out = 0.8
	_change_to_main_screen(true)


func _process(delta):
	if _is_match_in_progress and _curr_gui:
		if _curr_gui is Cutscene:
			var skip: bool = Input.is_action_just_pressed("skip_cinematic")
			if skip:
				_curr_gui.skip()
		elif _curr_gui is Dialog:
			var skip_full: bool = Input.is_action_just_pressed("skip_cinematic")
			var skip_step: bool = Input.is_action_just_pressed("skip_dialog")
			if skip_full or skip_step:
				_curr_gui.skip(skip_full)
		elif _curr_gui is Level:
			_curr_gui.set_current_time(timer.time_left)


func cinematic_fade_in(duration: float = cinematic_transition.duration_in) -> void:
	print("[func_call]: cinematic_fade_in")
	cinematic_transition.visible = true
	cinematic_transition.fade_in(duration)
	await cinematic_transition.finished
	cinematic_transition.visible = false


func cinematic_fade_out(duration: float = cinematic_transition.duration_out) -> void:
	print("[func_call]: cinematic_fade_out")
	cinematic_transition.visible = true
	cinematic_transition.fade_out(duration)


func play_music(music, stop_previous: bool = false) -> void:
	if music == null or stop_previous:
		music_player.stop()
	music_player.set_stream(music)
	music_player.play()


func change_screen(new_screen) -> void:
	print()
	print("[func_call]: change_screen(", new_screen, ")")
	if new_screen == null:
		return
	if _curr_gui:
		await cinematic_fade_out()
#		cinematic_fade_out()
#		await cinematic_transition.finished
		if _curr_gui.has_signal("button_pressed"):
			print("[state_bef]: connections of '", _curr_gui.button_pressed, "' -> ",
					_curr_gui.button_pressed.get_connections())
			for conn in _curr_gui.button_pressed.get_connections():
				_curr_gui.button_pressed.disconnect(conn.get("callable"))
			print("[state_aft]: connections of '", _curr_gui.button_pressed, "' -> ",
					_curr_gui.button_pressed.get_connections())
		_curr_gui.queue_free()
	_curr_gui = new_screen
	gui_layer.add_child(_curr_gui)
	cinematic_fade_in()
	print("[signal]: emitted '", screen_changed, "'")
	screen_changed.emit()


func get_random_refs(pixel_size: int, amount: int) -> Array[Dictionary]:
	if not pixel_size in [8, 16, 24]:
		return ([])
	var refs: Array[Dictionary] = []
	var sculptures: Array = Sculptures.SCULPTURES[str(pixel_size) + "px"]
	refs.append_array(sculptures)
	for i in range(clamp(amount - len(sculptures), 0, amount)):
		refs.append(
			Sculptures.get_sculpture_data(
				pixel_size,
				randi_range(0, len(sculptures))))
	randomize()
	refs.shuffle()
	return (refs.slice(0, amount))


func _randomize_refs() -> void:
	var amounts: Dictionary = DIFFICULTY_DICTIONARY[_difficulty]
	_refs_list = []
	for pixel_size in amounts.keys():
		var amount: int = amounts[pixel_size]
		_refs_list.append_array(get_random_refs(pixel_size, amount))


func _change_to_main_screen(restart_music: bool = false) -> void:
	print()
	print("[func_call]: _change_to_main_screen(", restart_music, ")")
	if restart_music:
		play_music(PRL_MUSIC_MAIN_MENU, true)
	await change_screen(PRL_SCREEN_MAIN.instantiate())
	_curr_gui.button_pressed.connect(_on_main_screen_button_pressed)


func _on_main_screen_button_pressed(pressed_action: String) -> void:
	print()
	print("[func_call]: _on_main_screen_button_pressed(", pressed_action, ")")
	match pressed_action:
		"play":
			await change_screen(PRL_SCREEN_DIFFICULTY_CHOOSE.instantiate())
			_curr_gui.button_pressed.connect(_on_difficulty_choose_screen_button_pressed)
			print("[connection]: ", _curr_gui.button_pressed, " <- ", _on_difficulty_choose_screen_button_pressed)
		"settings": pass
		"credits": pass


func _on_difficulty_choose_screen_button_pressed(pressed_action: String) -> void:
	print()
	print("[func_call]: _on_difficulty_choose_screen_button_pressed(", pressed_action, ")")
	match pressed_action:
		"choose_novice":
			_start_match(Difficulty.NOVICE)
		"choose_normal":
			_start_match(Difficulty.NORMAL)
		"choose_madness":
			_start_match(Difficulty.MADNESS)


func _start_match(difficulty: Difficulty) -> void:
	print()
	print("[func_call]: _start_match(", difficulty, ")")
	_difficulty = difficulty
	_randomize_refs()
	await change_screen(PRL_CUTSCENE_INTRO.instantiate())
	_curr_gui.finished.connect(_on_intro_cutscene_finished)
	print("[connection]: ", _curr_gui.finished, " <- ", _on_intro_cutscene_finished)
	play_music(null)
	_is_match_in_progress = true
	_curr_gui.play()


func _on_intro_cutscene_finished() -> void:
	print()
	print("[func_call]: _on_intro_cutscene_finished")
	await change_screen(PRL_DIALOG_INTRO.instantiate())
	_curr_gui.finished.connect(_on_intro_dialog_finished)
	print("[connection]: ", _curr_gui.finished, " <- ", _on_intro_dialog_finished)
	_curr_gui.play()


func _on_intro_dialog_finished() -> void:
	print()
	print("[func_call]: _on_intro_dialog_finished")
	await change_screen(PRL_LEVEL.instantiate())
	_on_level_started()


func _on_level_started() -> void:
	print()
	print("[func_call]: _on_level_started")
	_percents = []
	for ref in _refs_list:
		var time: float = ref["time"]
		timer.start(time)
		_curr_gui.set_sculpture_data(ref)
		print("[info]: setting sculpture to ", ref["name"])
		await timer.timeout
		var percent: float = _curr_gui.get_score_percent()
		print("[info] percent: ", percent)
		_percents.append(percent)
	print("[info]: level finished!")
	await change_screen(PRL_SCREEN_SCORE.instantiate())
	_on_score_screen()


func _on_score_screen() -> void:
	print()
	print("[func_call]: _on_score_screen")
	_curr_gui.button_pressed.connect(_on_score_screen_button_pressed)
	print("[connection]: ", _curr_gui.button_pressed, " <- ", _on_score_screen_button_pressed)
	var final_percent: float = 0.0
	var final_score: int = 0
	for percent in _percents:
		final_percent += percent
		final_score += percent * 10000
	final_percent /= len(_percents)
	_curr_gui.set_percent(final_percent)
	_curr_gui.set_score(final_score)
	if final_percent >= 0.8:
		_curr_gui.play_victory_animation()
		play_music(PRL_MUSIC_SCORE_VICTORY)
	else:
		_curr_gui.play_defeat_animation()
		play_music(PRL_MUSIC_SCORE_DEFEAT)


func _on_score_screen_button_pressed(pressed_action: String) -> void:
	print()
	print("[func_call]: _on_score_screen_button_pressed(", pressed_action, ")")
	match pressed_action:
		"play_again":
			print("Play Again!")
			_start_match(_difficulty)
		"main_screen":
			print("Returning to Main Screen!")
			_change_to_main_screen(true)


#func _on_block_carved() -> void:
#	play_sound(CARVING_SOUNDS.pick_random())
