extends HSplitContainer
class_name HSplitRatioContainer

export (float) var a: float = 1.0 setget _set_a
export (float) var b: float = 1.0 setget _set_b

onready var _is_ready = true


func _set_a(part_a: float) -> void:

	a = part_a
	_normalize_ratio()

	if _is_ready:
		_split_with_ratio(a, b)


func _set_b(part_b: float) -> void:

	b = part_b
	_normalize_ratio()

	if _is_ready:
		_split_with_ratio(a, b)


func _ready():

	self.connect("resized", self, "_on_resized")
	self.connect("dragged", self, "_on_dragged")

	_normalize_ratio()
	_split_with_ratio(a, b)


func _get_normalized_ratio(part_a: float, part_b: float) -> Vector2:

	var min_part: float = min(part_a, part_b)
	var scale: float = 1.0

	if min_part < 1.0 && min_part != 0.0:
		scale = 1.0 / min_part

	return Vector2(part_a, part_b) * scale


func _normalize_ratio() -> void:

	var normalized_ratio: Vector2 = _get_normalized_ratio(a, b)
	a = normalized_ratio.x
	b = normalized_ratio.y


func _is_infinite_ratio(part_a: float, part_b: float) -> bool:

	return part_a == 0.0 || part_b == 0.0


func _offset_for_infinite_ratio(part_a: float, part_b: float) -> int:

	var half_width: float = rect_size.x / 2

	if part_a == 0.0:
		return -int(half_width)
	elif part_b == 0.0:
		return int(half_width)

	return 0


func _split_with_ratio(part_a: float, part_b: float) -> void:

	if _is_infinite_ratio(part_a, part_b):

		split_offset = _offset_for_infinite_ratio(part_a, part_b)
		return

	var width: float = rect_size.x
	var half_width: float = width / 2

	var normalized_ratio: Vector2 = _get_normalized_ratio(part_a, part_b)
	part_a = normalized_ratio.x
	part_b = normalized_ratio.y

	var segment_width: float = width / (part_a + part_b)
	split_offset = int(-half_width + (segment_width * part_a))


func _on_resized() -> void:

	_split_with_ratio(a, b)
	clamp_split_offset()


func _on_dragged(offset: int) -> void:

	var width: float = rect_size.x
	var half_width: float = width / 2

	a = (offset + half_width) / width
	b = 1.0 - a

	_normalize_ratio()

