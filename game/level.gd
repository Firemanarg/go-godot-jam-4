extends Node


signal block_carved

const MATCH_WEIGHT: Array[float] = [1.0, 3.0]
const UNMATCH_WEIGHT: Array[float] = [2.0, 3.0]
const EMPTY: int = 0
const NOT_EMPTY: int = 1

const SCULPTURE_SETTINGS: Dictionary = {
	Vector2i(8, 8): {
		"position": Vector2(576, 450),
		"scale": Vector2(1.6, 1.6)
	},
	Vector2i(16, 16): {
		"position": Vector2(576, 490),
		"scale": Vector2(1.3, 1.3)
	},
	Vector2i(24, 24): {
		"position": Vector2(576, 580),
		"scale": Vector2(1.2, 1.2)
	},
}

@onready var reference = get_node("SculptureReference")
@onready var sculpture = get_node("Sculpture")
@onready var sculpture_block = get_node("Sculpture/SculptureBlock")


func _ready():
	pass


func enable_edition(is_enabled: bool = true):
	sculpture_block.enable_edition(is_enabled)


func set_sculpture_data(data: Dictionary) -> void:
	reference.set_sculpture_data(data)
	sculpture_block.set_size(reference.size)
	sculpture.position = SCULPTURE_SETTINGS[reference.size]["position"]
	sculpture.scale = SCULPTURE_SETTINGS[reference.size]["scale"]


func get_score_percent() -> float:
	if not reference:
		return (0.0)
	var size: Vector2i = reference.size
	var original_pixels: Array[Vector2i] = reference.used_pixels
	var copy_pixels: Array[Vector2i] = sculpture_block.get_used_pixels()
	var max_match_count: Array[int] = [
		(reference.size.x * reference.size.y) - original_pixels.size(),
		original_pixels.size(),
	]
	var max_unmatch_count: Array[int] = [
		max_match_count[NOT_EMPTY],
		max_match_count[EMPTY],
	]
	var match_count: Array[int] = [0, 0]
	var unmatch_count: Array[int] = [0, 0]
	for x in reference.size.x:
		for y in reference.size.y:
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


func _on_sculpture_block_block_carved():
	block_carved.emit()
