extends Node2D


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

var size: Vector2i = Vector2i(8, 8)
var cell_size: Vector2 = Vector2(16, 16)
var selector_size: Vector2 = Vector2(16, 16)

var grid_color: Color = Color(0.7, 0.7, 0.7)

var _can_sculpt: bool = false

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
	if _can_sculpt:
		var is_mouse_pressed: bool = (
				Input.is_action_pressed("mouse_button_left")
				or Input.is_action_just_pressed("mouse_button_left")
		)
		if is_mouse_pressed:
			var mouse_pos: Vector2 = to_local(get_global_mouse_position())
			var map_pos: Vector2i = tilemap.local_to_map(mouse_pos)
			var fixed_map_pos: Vector2i = map_pos + Vector2i(size.x / 2.0, size.y)
			set_sub_block(fixed_map_pos, SubBlockID.EMPTY, true)


func _draw():
	_update_visible_grid()


func set_size(size: Vector2i):
	self.size = size
	_update_area_2d()
	regenerate_block()


func is_sub_block_empty(pos: Vector2i) -> bool:
	var id: Vector2i = tilemap.get_cell_atlas_coords(0, pos)
	return (id == _SubBlockCoords[SubBlockID.EMPTY])


func set_sub_block(pos: Vector2i, id: SubBlockID, update_draw: bool = false):
	var atlas_coord: Vector2i = _SubBlockCoords[id]
	tilemap.set_cell(0, pos, 0, atlas_coord)
	if update_draw:
		update_visible_grid()


func regenerate_block(id: SubBlockID = SubBlockID.GRAY):
	tilemap.position = -Vector2(size.x / 2.0, size.y) * cell_size
	tilemap.clear()
	for x in size.x:
		for y in size.y:
			set_sub_block(Vector2i(x, y), id)
	update_visible_grid()


func get_used_pixels() -> Array[Vector2i]:
	return (tilemap.get_used_cells(0))


func update_visible_grid() -> void:
	queue_redraw()


func _update_area_2d():
	var shape: RectangleShape2D = collision_shape.shape
	shape.size = Vector2(size) * cell_size
	area2d.position.y = -(size.y / 2.0) * cell_size.y


func _update_visible_grid() -> void:
	var used_cells: Array[Vector2i] = tilemap.get_used_cells(0)
	var top_left_origin: Vector2 = (
			tilemap.map_to_local(Vector2i.ZERO)
			+ tilemap.position
			+ Vector2(cell_size.x, -cell_size.y) / 2.0
		)
	for cell in used_cells:
		var start_pos: Vector2 = (
				top_left_origin
				+ Vector2(cell) * cell_size
				- Vector2(cell_size.x, 0)
			)
		var top_left: Vector2 = start_pos
		var top_right: Vector2 = start_pos + Vector2(cell_size.x, 0)
		var bottom_left: Vector2 = start_pos + Vector2(0, cell_size.y)
		var bottom_right: Vector2 = start_pos + cell_size
		draw_line(top_left, top_right, grid_color)
		draw_line(bottom_left, bottom_right, grid_color)
		draw_line(top_left, bottom_left, grid_color)
		draw_line(top_right, bottom_right, grid_color)
#		draw_line(start_pos, start_pos + cell_size * Vector2.LEFT, grid_color)


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = to_local(get_global_mouse_position())
		var map_pos: Vector2i = tilemap.local_to_map(mouse_pos)
		var fixed_map_pos: Vector2i = map_pos + Vector2i(size.x / 2.0, size.y)
		selector.visible = true
		selector.position = (Vector2(map_pos) * cell_size) + (selector_size / 2.0)
		_can_sculpt = true


func _on_area_2d_mouse_exited():
	selector.visible = false
	_can_sculpt = false
