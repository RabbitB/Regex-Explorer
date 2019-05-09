tool
extends Control

const SETTING_MAX_SIZE = "display/window/size_constraints/max_size"
const SETTING_MIN_SIZE = "display/window/size_constraints/min_size"

enum HandleType {
	Vertical = 1, 
	Horizontal = 2, 
}

export (HandleType, FLAGS) var handle_type: int = HandleType.Vertical | HandleType.Horizontal
export (bool) var resize_from_top_left: bool = false

var dragging: bool = false

var _local_mouse_pos_on_drag_start: Vector2
var _was_in_low_processor_usage_mode: bool = false

func _init() -> void:
	
	ProjectTools.try_register_project_setting(SETTING_MAX_SIZE, Vector2(0, 0), TYPE_VECTOR2)
	ProjectTools.try_register_project_setting(SETTING_MIN_SIZE, Vector2(0, 0), TYPE_VECTOR2)
	
	var error: int = ProjectSettings.save()
	if error: push_error("Encountered error %d when saving project settings." % error)

func _gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		
		var mouse_button_event: InputEventMouseButton = event as InputEventMouseButton
		
		if mouse_button_event.button_index == BUTTON_LEFT:
			
			dragging = mouse_button_event.pressed
			_local_mouse_pos_on_drag_start = get_local_mouse_position()
			
			if dragging:
				
				_was_in_low_processor_usage_mode = OS.low_processor_usage_mode
				OS.low_processor_usage_mode = false
				
			else:
				
				OS.low_processor_usage_mode = _was_in_low_processor_usage_mode
		
	elif dragging && event is InputEventMouseMotion:

#		We calculate our delta mouse movement based on where the drag started, not from the origin 
#		of the resize-handle control. If we didn't, the amount the window has been resized will be 
#		slightly off from how much the cursor has actually been moved.
		resize_window(get_local_mouse_position() - _local_mouse_pos_on_drag_start)

func resize_window(resize_by: Vector2) -> void:
	
	if resize_from_top_left: resize_by = -resize_by
	
	var orig_window_size: Vector2 = OS.window_size
	var naive_window_size: Vector2 = orig_window_size + resize_by
	var clamped_window_size: Vector2 = orig_window_size
	
	var max_size_setting: Vector2 = ProjectSettings.get_setting(SETTING_MAX_SIZE)
	var min_size_setting: Vector2 = ProjectSettings.get_setting(SETTING_MIN_SIZE)
	
	var max_size: Vector2 = naive_window_size
	var min_size: Vector2 = Vector2(0, 0)
	
	if max_size_setting.x > 0: max_size.x = max_size_setting.x
	if max_size_setting.y > 0: max_size.y = max_size_setting.y
	
	if min_size_setting.x > 0: min_size.x = min_size_setting.x
	if min_size_setting.y > 0: min_size.y = min_size_setting.y
	
	if handle_type & HandleType.Vertical:
		
		clamped_window_size.x = clamp(naive_window_size.x, min_size.x, max_size.x)
	
	if handle_type & HandleType.Horizontal:
		
		clamped_window_size.y = clamp(naive_window_size.y, min_size.y, max_size.y)

	if resize_from_top_left:
		
		OS.window_position.x -= clamped_window_size.x - orig_window_size.x
		OS.window_position.y -= clamped_window_size.y - orig_window_size.y
	
	OS.window_size = clamped_window_size