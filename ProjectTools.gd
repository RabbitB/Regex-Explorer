tool
extends Reference
class_name ProjectTools

static func try_register_project_setting(
		name: String, 
		default_value, 
		type: int, 
		hint: int = PROPERTY_HINT_NONE, 
		hint_string: String = "") -> bool:
		
	if ProjectSettings.has_setting(name): return false
	
	register_project_setting(name, default_value, type, hint, hint_string)
	return true
	

static func register_project_setting(
		name: String, default_value, 
		type: int, 
		hint: int = PROPERTY_HINT_NONE, 
		hint_string: String = "") -> void:
	
	var setting_info: Dictionary = {
		"name": name, 
		"type": type, 
		"hint": hint, 
		"hint_string": hint_string
	}
	
	ProjectSettings.set_setting(name, default_value)
	ProjectSettings.add_property_info(setting_info)
	ProjectSettings.set_initial_value(name, default_value)