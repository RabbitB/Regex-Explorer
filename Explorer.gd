extends Control

const RegexRuleContainer: Script = preload("res://RegexRuleContainer/RegexRuleContainer.gd")

export (Color) var InvalidFileNameHighlightColor = Color8(211, 71, 74)
export (Color) var ModifiedFileNameHighlightColor = Color8(236, 131, 60)

onready var ValidDirIndicator: ColorRect = $MainVBoxContainer/ValidDirIndicator as ColorRect
onready var OriginalFileList: ItemList = $MainVBoxContainer/FileSplitContainer/RuleSplitContainer/OriginalFileList as ItemList
onready var PreviewFileList: ItemList = $MainVBoxContainer/FileSplitContainer/PreviewFileList as ItemList
onready var RegexRuleController: RegexRuleContainer = $MainVBoxContainer/FileSplitContainer/RuleSplitContainer/RegexRuleScrollContainer/RegexRuleContainer as RegexRuleContainer

var _target_dir: Directory = Directory.new()

func read_dir_contents(dir_path: String) -> void:

	OriginalFileList.clear()
	assert(_target_dir.dir_exists(dir_path))

	_target_dir.open(dir_path)
	_target_dir.list_dir_begin(true, true)

	var next_item : String = _target_dir.get_next()

	while !next_item.empty():

		if _target_dir.current_is_dir():

			OriginalFileList.add_item(next_item, preload("res://directory_icon.png"))

		else:

			OriginalFileList.add_item(next_item)

		next_item = _target_dir.get_next()

	_update_file_output()

func preview_list_contains_item_text(item_text: String) -> int:

	for i in range(PreviewFileList.get_item_count()):
		if PreviewFileList.get_item_text(i) == item_text: return i

	return -1

func _update_file_output():

	PreviewFileList.clear()

	for i in range(OriginalFileList.get_item_count()):

		var new_file_name: String = RegexRuleController.process_string(OriginalFileList.get_item_text(i), OriginalFileList.is_selected(i))
		var sanitized_file_name = _sanitize_file_name(new_file_name)

		var validating_regex: RegEx = RegEx.new()
		validating_regex.compile("\\w+")
		var is_valid_name: bool = validating_regex.search(sanitized_file_name) != null
		var is_duplicate_name: bool = preview_list_contains_item_text(sanitized_file_name) != -1

		if is_valid_name && !is_duplicate_name:

			PreviewFileList.add_item(sanitized_file_name)

			if sanitized_file_name != new_file_name:

				PreviewFileList.set_item_custom_fg_color(i, ModifiedFileNameHighlightColor)
				PreviewFileList.set_item_tooltip(i, "Filename \"%s\" is invalid. Auto-corrected to valid name." % new_file_name)

		else:

			PreviewFileList.add_item(OriginalFileList.get_item_text(i))
			PreviewFileList.set_item_disabled(i, true)
			PreviewFileList.set_item_custom_fg_color(i, InvalidFileNameHighlightColor)

			if is_duplicate_name:

				PreviewFileList.set_item_text(i, sanitized_file_name)
				PreviewFileList.set_item_tooltip(i, "Filename already exists. Cannot rename.")

			else:

				PreviewFileList.set_item_tooltip(i, "Filename invalid. Could not auto-correct into valid name.")

		var file_icon: Texture = OriginalFileList.get_item_icon(i)
		if file_icon: PreviewFileList.set_item_icon(i, file_icon)

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

func _on_ExplorerAddressBar_path_changed(path: String, is_path_valid: bool):

	ValidDirIndicator.valid = is_path_valid
	if is_path_valid: read_dir_contents(path)

func _on_RenameFilesButton_pressed():

	for i in range(PreviewFileList.get_item_count()):

		if PreviewFileList.is_item_disabled(i): continue

		var new_file_path: String = _target_dir.get_current_dir().plus_file(PreviewFileList.get_item_text(i))
		var old_file_path: String = _target_dir.get_current_dir().plus_file(OriginalFileList.get_item_text(i))

		_target_dir.rename(old_file_path, new_file_path)
		read_dir_contents(_target_dir.get_current_dir())

func _on_OriginalFileList_multi_selected(index, selected):

	_update_file_output()