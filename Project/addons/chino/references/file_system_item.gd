extends Reference
class_name FileSystemItem

var path: String setget _set_path

var _directory: Directory = Directory.new()
var _valid_directory: bool = false

var _this: Reference = get_script()


func _set_path(new_path: String) -> void:

	path = new_path
	_valid_directory = _directory.open(new_path) == OK

	if !_valid_directory && !is_file():
		Log.error("Failed to access the dir/file at '%s'", [path])


func _change_directory(new_path: String) -> void:

	_valid_directory = _directory.change_dir(new_path) == OK

	if !_valid_directory:
		Log.error("Failed to change the directory from '%s' to '%s'", [path, new_path])

	path = _directory.get_current_dir()


func list_all_contents(skip_navigational: bool = false, skip_hidden: bool = false) -> Array:

	var contents = []

	if !_valid_directory || _directory.list_dir_begin(skip_navigational, skip_hidden) != OK:

		Log.error("Failed to read the contents of '%s'", [path])
		return contents

	var next_item: String = _directory.get_next()

	while !next_item.empty():

		contents.append({ "name": next_item, "is_directory": _directory.current_is_dir() })
		next_item = _directory.get_next()

	return contents


func list_files(skip_hidden: bool = false, with_extension: String = "") -> Array:

	var contents = []

	if !_valid_directory || _directory.list_dir_begin(true, skip_hidden) != OK:

		Log.error("Failed to read the files stored in '%s'", [path])
		return contents

	var next_item: String = _directory.get_next()

	while !next_item.empty():

		if !_directory.current_is_dir() && (with_extension.empty() || next_item.get_extension() == with_extension):
			contents.append(next_item)

		next_item = _directory.get_next()

	return contents


func list_sub_directories(skip_hidden: bool = false) -> Array:

	var contents = []

	if !_valid_directory || _directory.list_dir_begin(true, skip_hidden) != OK:

		Log.error("Failed to read the sub-directories stored in '%s'", [path])
		return contents

	var next_item: String = _directory.get_next()

	while !next_item.empty():

		if _directory.current_is_dir():
			contents.append(next_item)

		next_item = _directory.get_next()

	return contents


func get_parent() -> FileSystemItem:

	var parent = _this.new()

	if is_file():

		parent.path = path.get_base_dir()

	elif _valid_directory:

		parent.path = path
		parent._change_directory("..")

	return parent


func get_child(name: String) -> FileSystemItem:

	var child = _this.new()

	if _valid_directory:
		child.path = path.plus_file(name)

	return child


func read_as_text() -> String:

	if !is_file():
		Log.error("'%s' is not a valid file or is a directory. Cannot read contents of file.", [path])
		return ""

	var file: File = File.new()
	var error: int = file.open(path, File.READ)

	if error != OK:
		Log.error("Failed to open file '%s' and read the contents as text. Encountered error: %d", \
				[path, Log.get_error_description(error)])
		return ""

	var read_text: String = file.get_as_text()
	file.close()

	return read_text


func read_as_json():

	var raw_json: String = read_as_text()
	var result_json: JSONParseResult = JSON.parse(raw_json)

	if result_json.error != OK:
		Log.error("Failed to parse '%s' as json. Encountered error '%s' on line '%d'. Failed to parse: '%s'", \
				[path, Log.get_error_description(result_json.error), result_json.error_line, result_json.error_string])
		return {}

	return result_json.result


func is_valid_directory() -> bool:

	return _valid_directory


func is_directory(a_path: String = "") -> bool:

	if a_path.empty():
		a_path = path

	return _directory.dir_exists(a_path)


func is_file(a_path: String = "") -> bool:

	if a_path.empty():
		a_path = path

	return _directory.file_exists(a_path)

