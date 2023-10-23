extends Node2D


signal block_carved

enum SubBlockID {
	EMPTY = -1,
	BLACK,
	DARK_GRAY,
	GRAY,
	WHITE,
}

const _SubBlockCoords = {
	SubBlockID.EMPTY: Vector2i(-1, -1),
	SubBlockID.BLACK: Vector2i(0, 0),
	SubBlockID.DARK_GRAY: Vector2i(2, 0),
	SubBlockID.GRAY: Vector2i(4, 0),
	SubBlockID.WHITE: Vector2i(6, 0),
}

var size: Vector2i = Vector2i(8, 8) : set = set_size
var cell_size: Vector2 = Vector2(16, 16)
var selector_size: Vector2 = Vector2(16, 16)

var grid_color: Color = Color(0.7, 0.7, 0.7)

var _enable_edition: bool = true
var _can_sculpt: bool = false
var _safe_regenerate_enabled: bool = false

@onready var tilemap = get_node("TileMap")
@onready var area2d = get_node("Area2D")
@onready var collision_shape = get_node("Area2D/CollisionShape2D")
@onready var selector = get_node("Selector")


func _ready():
	regenerate_block(SubBlockID.GRAY)
	_update_area_2d()

#	var ref = get_node("SculptureReference")
#	ref.init(ref.texture)
#	var used_pixels: Array[Vector2i] = ref.used_pixels
#	for x in size.x:
#		for y in size.y:
#			var pos: Vector2i = Vector2i(x, y)
#			if not pos in used_pixels:
#				set_sub_block(pos, SubBlockID.EMPTY, true)


func _process(delta):
	var is_mouse_just_released: bool = Input.is_action_just_released("mouse_button_left")
	if _safe_regenerate_enabled and is_mouse_just_released:
		enable_safe_regenerate(false)
	if not _safe_regenerate_enabled and _enable_edition and _can_sculpt:
		var is_mouse_pressed: bool = Input.is_action_pressed("mouse_button_left")
		var is_mouse_just_pressed: bool = Input.is_action_just_pressed("mouse_button_left")
		if is_mouse_pressed or is_mouse_just_pressed:
			var mouse_pos: Vector2 = to_local(get_global_mouse_position())
			var map_pos: Vector2i = tilemap.local_to_map(mouse_pos)
			var fixed_map_pos: Vector2i = map_pos + Vector2i(size.x / 2.0, size.y)
			set_sub_block(fixed_map_pos, SubBlockID.EMPTY)


func set_size(new_size: Vector2i):
	size = new_size
	_update_area_2d()
	regenerate_block()


func is_sub_block_empty(pos: Vector2i) -> bool:
	var id: Vector2i = tilemap.get_cell_atlas_coords(0, pos)
	return (id == _SubBlockCoords[SubBlockID.EMPTY])


func set_sub_block(pos: Vector2i, id: SubBlockID):
	var atlas_coord: Vector2i = _SubBlockCoords[id]
	if id == SubBlockID.EMPTY:
		var prev_coords: Vector2i = tilemap.get_cell_atlas_coords(0, pos)
		if prev_coords != atlas_coord:
			block_carved.emit()
	tilemap.set_cell(0, pos, 0, atlas_coord)


func regenerate_block(id: SubBlockID = SubBlockID.GRAY):
	tilemap.position = -Vector2(size.x / 2.0, size.y) * cell_size
	tilemap.clear()
	for x in size.x:
		for y in size.y:
			set_sub_block(Vector2i(x, y), id)
	enable_safe_regenerate()


func get_used_pixels() -> Array[Vector2i]:
	return (tilemap.get_used_cells(0))


func enable_safe_regenerate(enable: bool = true) -> void:
	_safe_regenerate_enabled = enable


func enable_edition(is_enabled: bool = true):
	_enable_edition = is_enabled
	enable_safe_regenerate(false)
	if not _enable_edition:
		selector.visible = false


func _update_area_2d():
	var shape: RectangleShape2D = collision_shape.shape
	shape.size = Vector2(size) * cell_size
	area2d.position.y = -(size.y / 2.0) * cell_size.y


func _update_visible_grid() -> void:
	pass


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
		if _enable_edition:
			var mouse_pos: Vector2 = to_local(get_global_mouse_position())
			var map_pos: Vector2i = tilemap.local_to_map(mouse_pos)
			var fixed_map_pos: Vector2i = map_pos + Vector2i(size.x / 2.0, size.y)
			selector.visible = true
			selector.position = (Vector2(map_pos) * cell_size) + (selector_size / 2.0)
			_can_sculpt = true


func _on_area_2d_mouse_exited():
	selector.visible = false
	_can_sculpt = false
