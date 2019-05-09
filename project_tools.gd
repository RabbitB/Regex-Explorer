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


static func error_description(error: int) -> String:

	match error:
		OK:
			return "OK"
		FAILED:
			return "Failed: Generic Error"
		ERR_UNAVAILABLE:
			return "Unavailable"
		ERR_UNCONFIGURED:
			return "Unconfigured"
		ERR_UNAUTHORIZED:
			return "Unauthorized"
		ERR_PARAMETER_RANGE_ERROR:
			return "Parameter range"
		ERR_OUT_OF_MEMORY:
			return "Out of memory"
		ERR_FILE_NOT_FOUND:
			return "File not found"
		ERR_FILE_BAD_DRIVE:
			return "Bad file drive"
		ERR_FILE_BAD_PATH:
			return "Bad file path"
		ERR_FILE_NO_PERMISSION:
			return "Lack file permissions"
		ERR_FILE_ALREADY_IN_USE:
			return "File already in use"
		ERR_FILE_CANT_OPEN:
			return "Can't open file"
		ERR_FILE_CANT_WRITE:
			return "Can't write to file"
		ERR_FILE_CANT_READ:
			return "Can't read from file"
		ERR_FILE_UNRECOGNIZED:
			return "File is unrecognized"
		ERR_FILE_CORRUPT:
			return "File is corrupt"
		ERR_FILE_MISSING_DEPENDENCIES:
			return "Missing file dependencies"
		ERR_FILE_EOF:
			return "Unexpected end of file"
		ERR_CANT_OPEN:
			return "Can't open"
		ERR_CANT_CREATE:
			return "Can't create"
		ERR_PARSE_ERROR:
			return "Parsing error"
		ERR_QUERY_FAILED:
			return "Query failed"
		ERR_ALREADY_IN_USE:
			return "Already in use"
		ERR_LOCKED:
			return "Locked"
		ERR_TIMEOUT:
			return "Timeout"
		ERR_CANT_ACQUIRE_RESOURCE:
			return "Can't acquire resource"
		ERR_INVALID_DATA:
			return "Invalid data"
		ERR_INVALID_PARAMETER:
			return "Invalid parameter"
		ERR_ALREADY_EXISTS:
			return "Already exists"
		ERR_DOES_NOT_EXIST:
			return "Does not exist"
		ERR_DATABASE_CANT_READ:
			return "Can't read from database"
		ERR_DATABASE_CANT_WRITE:
			return "Can't write to database"
		ERR_COMPILATION_FAILED:
			return "Compilation failed"
		ERR_METHOD_NOT_FOUND:
			return "Method not found"
		ERR_LINK_FAILED:
			return "Linking failed"
		ERR_SCRIPT_FAILED:
			return "Script failed"
		ERR_CYCLIC_LINK:
			return "Cyclic linking error"
		ERR_BUSY:
			return "Busy"
		ERR_HELP:
			return "Help"
		ERR_BUG:
			return "Bug"
		_:
			return "Unknown"

