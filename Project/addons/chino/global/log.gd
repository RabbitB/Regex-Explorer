extends Reference
class_name Log


static func _call_stack_to_string(call_stack: Array) -> String:
	var output_string: String = ""

	for call in call_stack:

		var spacing_character: String = "" if output_string.empty() else "\n"
		var call_string: String = "function: %s, line: %d, source: %s" % [call["function"], call["line"], call["source"]]
		output_string += "%s%s" % [spacing_character, call_string]

	return output_string


static func _message(msg: String, msg_args: Array, log_call_stack: bool = false, call_discard_depth: int = 2) -> String:
	var formatted_msg: String = msg % msg_args
	var stack_output: String

	if log_call_stack:

		var call_stack: Array = get_stack()
		var discard_count: int = call_discard_depth

		#	It's necessary to remove a number of calls (declared by call_discard_depth) from the call-stack, so that we
		#	return an accurate representation of where this message was actually logged from. The end-user doesn't care
		#	that the actual top of the stack is this utility function; they care about logging where they called it from.
		#	As this is a private function of the Log class, it's largely called as a helper by other Log class functions,
		#	and thus the default discard depth of the call-stack is 2. One for this function, and one for the other Log
		#	function that called it.
		if call_stack.size() <= call_discard_depth:
			call_stack.clear()
		else:

			while discard_count > 0:

				call_stack.pop_front()
				discard_count -= 1

		stack_output = "\n%s" % [_call_stack_to_string(call_stack)]

	printerr(formatted_msg, stack_output)
	return formatted_msg


static func error(error_msg: String, msg_args: Array, log_call_stack: bool = false) -> void:
	var logged_msg: String = _message(error_msg, msg_args, log_call_stack)
	push_error(logged_msg)


static func warning(warning_msg: String, msg_args: Array, log_call_stack: bool = false) -> void:
	var logged_msg: String = _message(warning_msg, msg_args, log_call_stack)
	push_warning(logged_msg)


static func get_error_description(error: int) -> String:
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

