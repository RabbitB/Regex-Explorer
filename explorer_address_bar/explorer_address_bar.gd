extends HBoxContainer

signal path_changed(path, is_path_valid)

onready var BrowseFileDialog: FileDialog = $FileDialog as FileDialog
onready var AddressLineEdit: LineEdit = $AddressLineEdit as LineEdit

var path: String setget _set_path, _get_path

var _error: int = OK
var _target_dir: Directory = Directory.new()


func _set_path(new_path: String) -> void:

	update_path(new_path, true)


func _get_path() -> String:

	return AddressLineEdit.text


func _ready() -> void:

	update_path(OS.get_executable_path().get_base_dir(), true)


func update_path(new_path: String, update_ui_text: bool) -> void:

	if update_ui_text: AddressLineEdit.text = new_path

	if is_path_valid():

		_error = _target_dir.open(self.path)

		if !_error:
			BrowseFileDialog.current_dir = self.path

	emit_signal("path_changed", new_path, is_path_valid())


func get_directory() -> Directory:

	return _target_dir if is_path_valid() && !_error else null


func get_dir_contents() -> Array:

	var dir_contents: Array = []

	if !is_path_valid() || _error:
		return dir_contents

	_error = _target_dir.list_dir_begin(true, true)

	if _error:
		return dir_contents

	var next_item: String = _target_dir.get_next()

	while !next_item.empty():

		var item_info: Dictionary = { "name": next_item, "is_dir": _target_dir.current_is_dir() }
		dir_contents.append(item_info)

		next_item = _target_dir.get_next()

	_target_dir.list_dir_end()

	return dir_contents


func get_active_path() -> String:

	return _target_dir.get_current_dir()


func is_path_valid(a_path: String = "") -> bool:

	if a_path.empty():
		a_path = self.path

	return _target_dir.dir_exists(a_path) && a_path.is_abs_path()


func encountered_error() -> int:

	return _error


func _on_AddressLineEdit_text_changed(new_text: String) -> void:

	update_path(new_text, false)


func _on_UpDirButton_pressed() -> void:

	if is_path_valid() && !_error:
		_error = _target_dir.change_dir("..")

	update_path(_target_dir.get_current_dir(), true)


func _on_BrowseButton_pressed() -> void:

	var file_dialog_min_size: Vector2 = get_viewport().size - Vector2(50, 75)
	BrowseFileDialog.popup_centered(file_dialog_min_size)


func _on_FileDialog_dir_selected(dir_path: String) -> void:

	update_path(dir_path, true)

