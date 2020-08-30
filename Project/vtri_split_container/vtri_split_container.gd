extends VSplitContainer

onready var _previous_height: float = rect_size.y


func _ready():

	var second_child: Control = get_child(1)

	self.connect("resized", self, "_on_resized")
	self.connect("dragged", self, "_on_dragged")

	rect_min_size.y = second_child.rect_position.y + second_child.rect_min_size.y


func _on_resized():

	var delta_height: int = (rect_size.y - _previous_height) as int
	_previous_height = rect_size.y

	split_offset -= delta_height
	clamp_split_offset()


func _on_dragged(offset: int):

	var second_child: Control = get_child(1)
	rect_min_size.y = second_child.rect_position.y + second_child.rect_min_size.y

