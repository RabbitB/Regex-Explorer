extends CanvasItem

export (bool) var valid: bool = false setget _set_valid
export (bool) var standby: bool = false setget _set_standby
export (Color) var valid_color: Color = Color8(71, 211, 103)
export (Color) var invalid_color: Color = Color8(211, 71, 74)
export (Color) var standby_color: Color = Color8(236, 131, 60)


func _set_valid(is_valid: bool) -> void:

	valid = is_valid
	update_color()


func _set_standby(is_standby: bool) -> void:

	standby = is_standby
	update_color()


func _ready():

	update_color()


func update_color():

	self.self_modulate = valid_color if valid else invalid_color
	self.self_modulate = standby_color if standby else self.self_modulate

