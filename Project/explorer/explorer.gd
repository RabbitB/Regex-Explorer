extends Control


const ExplorerAddressBar: Script = preload("res://explorer_address_bar/explorer_address_bar.gd")
const RegexRuleContainer: Script = preload("res://regex_rule_container/regex_rule_container.gd")
const StatusItemList: Script = preload("res://explorer/status_item_list.gd")

const DIR_ICON: Texture = preload("res://explorer/iconography/directory/directory_icon.png")
const CONFIG_FILE_PATH: String = "user://config.cfg"

export (Color) var invalid_filename_highlight_color: Color = Color8(211, 71, 74)
export (NodePath) var address_bar_path: NodePath
export (NodePath) var valid_dir_indicator_path: NodePath
export (NodePath) var original_file_list_path: NodePath
export (NodePath) var preview_file_list_path: NodePath
export (NodePath) var regex_rule_container_path: NodePath
export (NodePath) var rename_files_button_path: NodePath

var _sanitizing_regex_chars: RegEx
var _sanitizing_regex_postfix: RegEx
var _sanitizing_regex_names: RegEx
var _validation_regex: RegEx
var _config_file: ConfigFile

onready var _address_bar: ExplorerAddressBar = get_node(address_bar_path) as ExplorerAddressBar
onready var _valid_dir_indicator: ColorRect = get_node(valid_dir_indicator_path) as ColorRect
onready var _original_file_list: StatusItemList = get_node(original_file_list_path) as StatusItemList
onready var _preview_file_list: StatusItemList = get_node(preview_file_list_path) as StatusItemList
onready var _regex_rule_container: RegexRuleContainer = get_node(regex_rule_container_path) as RegexRuleContainer
onready var _rename_files_button: Button = get_node(rename_files_button_path) as Button


func _init() -> void:
	_setup_regex()
	_config_file = ConfigFile.new()


func _ready() -> void:
	var error: int = _config_file.load(CONFIG_FILE_PATH)
	if error:
		Log.error("Could not load the config file. Using default settings.")

	#	If found, the address bar will auto-update to the last used path. Otherwise it will keep its default
	#	path.
	if _config_file.has_section_key("tracked", "last_accessed_dir"):
		_address_bar.update_path(_config_file.get_value("tracked", "last_accessed_dir"), true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_QUIT_REQUEST && _address_bar.is_path_valid():
		_config_file.set_value("tracked", "last_accessed_dir", _address_bar.get_active_path())

		var error: int = _config_file.save(CONFIG_FILE_PATH)
		if error:
			Log.error("Could not save the config file. Any changes will be lost.")


func read_dir_contents(_dir_path: String) -> void:
	var files: Array = _address_bar.get_dir_contents()
	_original_file_list.clear()

	for file in files:
		if file.is_dir:
			_original_file_list.add_item_with_status(
					file.name, StatusItemList.ItemStatus.DISABLED_OFF, DIR_ICON, true, true)
		else:
			_original_file_list.add_item_with_status(
					file.name, StatusItemList.ItemStatus.DISABLED_OFF, null, false, true)

		_original_file_list.set_icon_tooltip(_original_file_list.get_item_count() - 1, \
				"Click to toggle this file on/off for editing.")

	_update_file_output(true)


func preview_list_contains_item_text(item_text: String) -> int:
	for i in range(_preview_file_list.get_item_count()):
		if _preview_file_list.get_item_text(i) == item_text: return i

	return -1


func _update_file_output(in_preview_mode: bool):
	_preview_file_list.clear()

	for i in range(_original_file_list.get_item_count()):
		#	Icon items are there solely for UI reasons,
		#	and not actually a filesystem item that needs to be processed.
		if _original_file_list.is_icon(i):
			continue

		var item_disabled: bool = _original_file_list.get_item_status(i) == StatusItemList.ItemStatus.DISABLED_ON
		var item_text: String = _original_file_list.get_item_text(i)
		var new_file_name: String = item_text
		var sanitized_file_name: String = item_text

		#	We only need to process this item if it's not disabled.
		#	Otherwise we can pass it along as is.
		if !item_disabled:
			new_file_name = _regex_rule_container.process_string(item_text, in_preview_mode)
			sanitized_file_name = _sanitize_file_name(new_file_name)

		var is_valid_name: bool = _validation_regex.search(sanitized_file_name) != null
		var duplicate_name_idx: int = preview_list_contains_item_text(sanitized_file_name)
		var new_item_idx: int = _preview_file_list.get_item_count()

		#	No changes made, because the item is disabled.
		if item_disabled:
			_preview_file_list.add_item_with_status(
					item_text, StatusItemList.ItemStatus.DISABLED_OFF, null, false, false)
			_preview_file_list.set_item_disabled(new_item_idx + 1, true)

		#	Did not produce a valid filename after processing.
		elif !is_valid_name:
			_preview_file_list.add_item_with_status(
					item_text, StatusItemList.ItemStatus.INVALID, null, false, false)
			_preview_file_list.set_item_disabled(new_item_idx + 1, true)
			_preview_file_list.set_icon_tooltip(new_item_idx, \
					"Filename invalid. Could not auto-correct into a valid name.")

		#	Processing the filename produced a name that's a duplicate of another file.
		elif duplicate_name_idx != -1:
			_preview_file_list.add_item_with_status(
					sanitized_file_name, StatusItemList.ItemStatus.INVALID, null, false, false)
			_preview_file_list.set_icon_tooltip(new_item_idx, "Duplicate filenames. Skipping file.")
			_preview_file_list.set_item_disabled(new_item_idx + 1, true)

			_preview_file_list.change_item_status(duplicate_name_idx, StatusItemList.ItemStatus.INVALID)
			_preview_file_list.set_icon_tooltip(duplicate_name_idx, "Duplicate filenames. Skipping file.")
			_preview_file_list.set_item_disabled(duplicate_name_idx, true)

		#	The processed filename is valid, but it had errors that could be auto-corrected.
		elif sanitized_file_name != new_file_name:
			_preview_file_list.add_item_with_status(
					sanitized_file_name, StatusItemList.ItemStatus.MODIFIED, null, false, false)
			_preview_file_list.set_icon_tooltip(new_item_idx, \
					"Filename \"%s\" is invalid. Auto-corrected to a valid name." % new_file_name)

		#	No issues found with the newly processed name.
		else:
			_preview_file_list.add_item_with_status(
					sanitized_file_name, StatusItemList.ItemStatus.VALID, null, false, false)

		#	Add the directory icon to the text, if the original item was a directory.
		if _original_file_list.get_item_icon(i) == DIR_ICON:
			_preview_file_list.set_item_icon(new_item_idx + 1, DIR_ICON)


func _setup_regex() -> void:
	_sanitizing_regex_chars = RegEx.new()
	_sanitizing_regex_chars.compile("[<>:\\\"/\\\\\\|?*]")

	_sanitizing_regex_postfix = RegEx.new()
	_sanitizing_regex_postfix.compile("[\\.| ]+$")

	_sanitizing_regex_names = RegEx.new()
	_sanitizing_regex_names.compile("(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])")

	_validation_regex = RegEx.new()
	_validation_regex.compile("\\w+")


func _sanitize_file_name(file_name: String) -> String:
#	Strip invalid characters
	file_name = _sanitizing_regex_chars.sub(file_name, "", true)

#	Strip characters that are only invalid at the end of a file name.
	file_name = _sanitizing_regex_postfix.sub(file_name, "", true)

#	Strip invalid character names.
	file_name = _sanitizing_regex_names.sub(file_name.get_file(), "", true)

	return file_name


func _on_ExplorerAddressBar_path_changed(path: String, is_path_valid: bool):
	_valid_dir_indicator.valid = is_path_valid

	if _address_bar.encountered_error():
		_rename_files_button.disabled = true
		_rename_files_button.hint_tooltip = "Encountered the error: \"%s\" with the current directory." \
				% [Log.get_error_description(_address_bar.encountered_error())]
	elif !is_path_valid:
		_rename_files_button.disabled = true
		_rename_files_button.hint_tooltip = "Not a valid directory path."
	else:
		read_dir_contents(path)
		_rename_files_button.disabled = false
		_rename_files_button.hint_tooltip = ""


func _on_RenameFilesButton_pressed():
	if !_address_bar.is_path_valid() || _address_bar.encountered_error():
		return

	var dir: Directory = _address_bar.get_directory()
	var active_path: String = _address_bar.get_active_path()

	_update_file_output(false)

	for i in range(_preview_file_list.get_item_count()):
		if _preview_file_list.is_icon(i):
			continue

		var item_status: int = _preview_file_list.get_item_status(i)
		if item_status != StatusItemList.ItemStatus.VALID && item_status != StatusItemList.ItemStatus.MODIFIED:
			continue

		var new_file_name: String = _preview_file_list.get_item_text(i)
		var old_file_name: String = _original_file_list.get_item_text(i)

		if new_file_name == old_file_name:
			continue

		var error: int = dir.rename(active_path.plus_file(old_file_name), active_path.plus_file(new_file_name))
		if error:
			_preview_file_list.change_item_status(i, StatusItemList.ItemStatus.INVALID)
			_preview_file_list.set_icon_tooltip(i, \
					"Encountered error: \"%s\" when renaming file \"%s\" to \"%s\"." % \
					[Log.get_error_description(error), old_file_name, new_file_name])
			_preview_file_list.set_item_disabled(i, true)

	read_dir_contents(active_path)


func _on_OriginalFileList_item_selected(index: int) -> void:
	if !_original_file_list.is_icon(index):
		return

	var item_status: int = _original_file_list.get_item_status(index)

	if item_status == StatusItemList.ItemStatus.DISABLED_OFF:
		_original_file_list.change_item_status(index, StatusItemList.ItemStatus.DISABLED_ON)
		_original_file_list.unselect(index)
	elif item_status == StatusItemList.ItemStatus.DISABLED_ON:
		_original_file_list.change_item_status(index, StatusItemList.ItemStatus.DISABLED_OFF)
		_original_file_list.unselect(index)

	_update_file_output(true)


func _on_OriginalFileList_item_activated(index):
	var text_at_index: String = _original_file_list.get_item_text(index)
	var new_path: String = _address_bar.get_active_path().plus_file(text_at_index)

	if !text_at_index.empty() && _address_bar.is_path_valid(new_path):
		_address_bar.update_path(new_path, true)

