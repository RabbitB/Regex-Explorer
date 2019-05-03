extends CanvasItem

export (bool) var valid: bool = false setget _on_valid_change
export (bool) var standby: bool = false setget _on_standby_change
export (Color) var valid_color: Color = Color8(71, 211, 103)
export (Color) var invalid_color: Color = Color8(211, 71, 74)
export (Color) var standby_color: Color = Color8(236, 131, 60)

func _ready():
	
	update_color()

func _on_valid_change(is_valid: bool) -> void:

	valid = is_valid
	update_color()
	
func _on_standby_change(is_standby: bool) -> void:
	
	standby = is_standby
	update_color()

func update_color():
	
	self.self_modulate = valid_color if valid else invalid_color
	self.self_modulate = standby_color if standby else self.self_modulate