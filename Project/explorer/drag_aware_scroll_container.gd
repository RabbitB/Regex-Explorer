extends ScrollContainer


#	Controls whether the scroll container will scroll when an item is dragged.
export(bool) var scroll_on_drag: bool = true

#	The width of the margin at the (outer) edge of the scroll container, that the mouse must be
#	over, to start scrolling.
export(int) var drag_overflow_margin: int = 30

#	The width of the margin at the (inner) edge of the scroll container, that the mouse must be
#	over, to start scrolling.
export(int) var drag_edge_margin: int = 10

#	Scroll speed is in terms of fractions of the size of the scroll container, per second.
#	So a value of one, is scrolling the width/height of the container, per second. 0.5 would be
#	half the width/height per second, and so on.
export(float) var scroll_speed: float = 1


func _ready() -> void:
	set_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN && scroll_on_drag:
		set_process(true)
	elif what == NOTIFICATION_DRAG_END:
		set_process(false)


func _process(delta: float) -> void:
	var local_mouse_pos: Vector2 = get_local_mouse_position()
	var scroll_bounds: Rect2 = Rect2(Vector2(0, 0), rect_size)
	var total_margin: int = drag_edge_margin

	scroll_bounds = scroll_bounds.grow(drag_overflow_margin)
	total_margin += drag_overflow_margin

	var top_scroll_area: Rect2 = Rect2(
			scroll_bounds.position,
			Vector2(scroll_bounds.size.x, total_margin))
	var bottom_scroll_area: Rect2 = Rect2(
			scroll_bounds.position.x, scroll_bounds.end.y - total_margin,
			scroll_bounds.size.x, total_margin)
	var left_scroll_area: Rect2 = Rect2(
			scroll_bounds.position,
			Vector2(total_margin, scroll_bounds.size.y))
	var right_scroll_area: Rect2 = Rect2(
			scroll_bounds.end.x - total_margin, scroll_bounds.position.y,
			total_margin, scroll_bounds.size.y)

	if top_scroll_area.has_point(local_mouse_pos):
		scroll_vertical -= int(max(1.0, scroll_speed * rect_size.y * delta))

	if bottom_scroll_area.has_point(local_mouse_pos):
		scroll_vertical += int(max(1.0, scroll_speed * rect_size.y * delta))

	if left_scroll_area.has_point(local_mouse_pos):
		scroll_horizontal -= int(max(1.0, scroll_speed * rect_size.x * delta))

	if right_scroll_area.has_point(local_mouse_pos):
		scroll_horizontal += int(max(1.0, scroll_speed * rect_size.x * delta))

