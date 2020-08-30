tool
extends Container
class_name Node2DContainer

export(Vector2) var target_position = Vector2()


func _ready() -> void:
	_sort_children()


func _notification(what: int) -> void:

	if what == NOTIFICATION_SORT_CHILDREN:
		_sort_children()


func _sort_children() -> void:

	var children_to_sort: Array = NodeHelper.get_children_of_class(self, "Node2D")

	for child in children_to_sort:

		var node_2d = child as Node2D
		node_2d.position = get_rect().size * target_position

	emit_signal("sort_children")

