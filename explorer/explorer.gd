extends Control

const ExplorerAddressBar: Script = preload("res://explorer_address_bar/explorer_address_bar.gd")
const RegexRuleContainer: Script = preload("res://regex_rule_container/regex_rule_container.gd")

export (Color) var InvalidFileNameHighlightColor = Color8(211, 71, 74)
export (Color) var ModifiedFileNameHighlightColor = Color8(236, 131, 60)

onready var _AddressBar: ExplorerAddressBar = $MainVBoxContainer/ExplorerAddressBar as ExplorerAddressBar
onready var _ValidDirIndicator: ColorRect = $MainVBoxContainer/ValidDirIndicator as ColorRect
onready var _OriginalFileList: ItemList = $MainVBoxContainer/FileSplitContainer/RuleSplitContainer/OriginalFileList as ItemList
onready var _PreviewFileList: ItemList = $MainVBoxContainer/FileSplitContainer/PreviewFileList as ItemList
onready var _RegexRuleController: RegexRuleContainer = $MainVBoxContainer/FileSplitContainer/RuleSplitContainer/RegexRuleScrollContainer/RegexRuleContainer as RegexRuleContainer
onready var _RenameFilesButton: Button = $MainVBoxContainer/ButtonHBoxContainer/RenameFilesButton as Button


func _update_file_output(review_mode: bool):

	_PreviewFileList.clear()

	for i in range(_OriginalFileList.get_item_count()):

		var new_file_name: String = _RegexRuleController.process_string(_OriginalFileList.get_item_text(i), _OriginalFileList.is_selected(i), review_mode)
		var sanitized_file_name = _sanitize_file_name(new_file_name)

		var validating_regex: RegEx = RegEx.new()
		validating_regex.compile("\\w+")
		var is_valid_name: bool = validating_regex.search(sanitized_file_name) != null
		var is_duplicate_name: bool = preview_list_contains_item_text(sanitized_file_name) != -1

		if is_valid_name && !is_duplicate_name:

			_PreviewFileList.add_item(sanitized_file_name)

			if sanitized_file_name != new_file_name:

				_PreviewFileList.set_item_custom_fg_color(i, ModifiedFileNameHighlightColor)
				_PreviewFileList.set_item_tooltip(i, "Filename \"%s\" is invalid. Auto-corrected to valid name." % new_file_name)

		else:

			_PreviewFileList.add_item(_OriginalFileList.get_item_text(i))
			_PreviewFileList.set_item_disabled(i, true)
			_PreviewFileList.set_item_custom_fg_color(i, InvalidFileNameHighlightColor)

			if is_duplicate_name:

				_PreviewFileList.set_item_text(i, sanitized_file_name)
				_PreviewFileList.set_item_tooltip(i, "Filename already exists. Cannot rename.")

			else:

				_PreviewFileList.set_item_tooltip(i, "Filename invalid. Could not auto-correct into valid name.")

		var file_icon: Texture = _OriginalFileList.get_item_icon(i)
		if file_icon: _PreviewFileList.set_item_icon(i, file_icon)


func _sanitize_file_name(file_name: String) -> String:

	var sanitizing_regex: RegEx = RegEx.new()

#	Strip invalid characters
	sanitizing_regex.compile("[<>:\\\"/\\\\\\|?*]")
	file_name = sanitizing_regex.sub(file_name, "", true)

#	Strip characters that are only invalid at the end of a file name.
	sanitizing_regex.compile("[\\.| ]+$")
	file_name = sanitizing_regex.sub(file_name, "", true)

#	Strip invalid character names.
	sanitizing_regex.compile("(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])")
	file_name = sanitizing_regex.sub(file_name.get_file(), "", true)

	return file_name


func read_dir_contents(dir_path: String) -> void:

	var files: Array = _AddressBar.get_dir_contents()
	_OriginalFileList.clear()

	for file in files:

		if file.is_dir:

			_OriginalFileList.add_item(file.name, preload("res://explorer/directory_icon.png"))

		else:

			_OriginalFileList.add_item(file.name)

	_update_file_output(true)


func preview_list_contains_item_text(item_text: String) -> int:

	for i in range(_PreviewFileList.get_item_count()):
		if _PreviewFileList.get_item_text(i) == item_text: return i

	return -1


func _on_ExplorerAddressBar_path_changed(path: String, is_path_valid: bool):

	_ValidDirIndicator.valid = is_path_valid

	if _AddressBar.encountered_error():

		_RenameFilesButton.disabled = true
		_RenameFilesButton.hint_tooltip = "Encountered the error: \"%s\" with the current directory." % [ProjectTools.error_description(_AddressBar.encountered_error())]

	elif !is_path_valid:

		_RenameFilesButton.disabled = true
		_RenameFilesButton.hint_tooltip = ""

	else:

		read_dir_contents(path)
		_RenameFilesButton.disabled = false
		_RenameFilesButton.hint_tooltip = ""


func _on_RenameFilesButton_pressed():

	if !_AddressBar.is_path_valid() || _AddressBar.encountered_error():
		return

	var dir: Directory = _AddressBar.get_directory()
	var error: int

	var active_path: String = _AddressBar.get_active_path()

	_update_file_output(false)

	for i in range(_PreviewFileList.get_item_count()):

		if _PreviewFileList.is_item_disabled(i): continue

		var new_file_name: String = _PreviewFileList.get_item_text(i)
		var old_file_name: String = _OriginalFileList.get_item_text(i)

		if new_file_name == old_file_name:
			continue

		error = dir.rename(active_path.plus_file(old_file_name), active_path.plus_file(new_file_name))

		if error:

			_PreviewFileList.set_item_disabled(i, true)
			_PreviewFileList.set_item_custom_fg_color(i, InvalidFileNameHighlightColor)
			_PreviewFileList.set_item_tooltip(i, \
					"Encountered error: \"%s\" when renaming file \"%s\" to \"%s\"." % [ProjectTools.error_description(error), old_file_name, new_file_name])

	read_dir_contents(active_path)


func _on_OriginalFileList_multi_selected(index, selected):

	_update_file_output(true)


func _on_OriginalFileList_item_activated(index):

	var new_path: String = _AddressBar.get_active_path().plus_file(_OriginalFileList.get_item_text(index))

	if _AddressBar.is_path_valid(new_path):
		_AddressBar.update_path(new_path, true)

