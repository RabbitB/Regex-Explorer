extends HBoxContainer

signal path_changed(path, is_path_valid)

onready var BrowseFileDialog: FileDialog = $FileDialog as FileDialog

onready var AddressLineEdit: LineEdit = $AddressLineEdit as LineEdit

#warning-ignore:unused_class_variable
var path: String setget , _get_path
#warning-ignore:unused_class_variable
var is_path_valid: bool setget , _get_is_path_valid

var _target_dir: Directory = Directory.new()

func _ready() -> void:
	
	update_path(OS.get_executable_path().get_base_dir(), true)

func update_path(new_path: String, update_ui_text: bool = false) -> void:

	if update_ui_text: AddressLineEdit.text = new_path
	
	if _get_is_path_valid():
		
		_target_dir.open(_get_path())
		BrowseFileDialog.current_dir = _get_path()
	
	emit_signal("path_changed", new_path, _get_is_path_valid())

func _on_AddressLineEdit_text_changed(new_text: String) -> void:
	
	update_path(new_text)

func _on_UpDirButton_pressed() -> void:

	_target_dir.change_dir("..")
	update_path(_target_dir.get_current_dir(), true)

func _on_BrowseButton_pressed() -> void:
	
	var file_dialog_min_size: Vector2 = get_viewport().size - Vector2(50, 75)
	BrowseFileDialog.popup_centered(file_dialog_min_size)

func _on_FileDialog_dir_selected(dir_path: String) -> void:

	update_path(dir_path, true)

func _get_path() -> String:
	
	return AddressLineEdit.text

func _get_is_path_valid() -> bool:
	
	return _target_dir.dir_exists(AddressLineEdit.text) && AddressLineEdit.text.is_abs_path()