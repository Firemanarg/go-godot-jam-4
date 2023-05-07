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

var size: Vector2 = Vector2(8, 8)
var cell_size: Vector2 = Vector2(16, 16)
var selector_size: Vector2 = Vector2(16, 16)

var _can_sculpt: bool = false

@onready var tilemap = get_node("TileMap")
@onready var area2d = get_node("Area2D")
@onready var collision_shape = get_node("Area2D/CollisionShape2D")
@onready var selector = get_node("Selector")


func _ready():
	regenerate_block(SubBlockID.GRAY)
	_update_area_2d()


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
			set_sub_block(fixed_map_pos, SubBlockID.EMPTY)


func set_sub_block(pos: Vector2i, id: SubBlockID):
	var atlas_coord: Vector2i = _SubBlockCoords[id]
	tilemap.set_cell(0, pos, 0, atlas_coord)


func regenerate_block(id: SubBlockID):
	tilemap.position = -Vector2(size.x / 2.0, size.y) * cell_size
	tilemap.clear()
	for x in size.x:
		for y in size.y:
			set_sub_block(Vector2i(x, y), id)


func _update_area_2d():
	var shape: RectangleShape2D = collision_shape.shape
	shape.size = size * cell_size
	area2d.position.y = -(size.y / 2.0) * cell_size.y


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
