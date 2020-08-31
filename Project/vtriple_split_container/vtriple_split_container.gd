tool
class_name VTripleSplitContainer
extends VSplitContainer


onready var _previous_height: float = rect_size.y


func _ready() -> void:
	self.connect("resized", self, "_on_resized")
	self.connect("dragged", self, "_on_dragged")

	_update_min_size()


func _notification(what: int) -> void:
	if Engine.editor_hint && (what == NOTIFICATION_PATH_CHANGED || what == NOTIFICATION_SORT_CHILDREN):
		update_configuration_warning()


func _get_configuration_warning() -> String:
	if !(get_parent() is VSplitContainer) && !get_child(1):
		return "This node must be a child of a VSplitContainer and contain two children, to function properly."

	if !(get_parent() is VSplitContainer):
		return "This node must be a child of a VSplitContainer."

	if !get_child(1):
		return "This node must have two children to function properly."

	return ""


func _update_min_size() -> void:
	var second_child: Control = get_child(1) as Control
	rect_min_size.y = second_child.rect_position.y + second_child.rect_min_size.y


func _on_resized() -> void:
	var delta_height: int = (rect_size.y - _previous_height) as int
	_previous_height = rect_size.y

	split_offset -= delta_height
	clamp_split_offset()


func _on_dragged(offset: int) -> void:
	_update_min_size()

