extends HBoxContainer


signal add_rule_pressed()
signal remove_rule_pressed()
signal rule_updated()
signal review_mode_toggled(should_review)

export (bool) onready var removable: bool = false setget _set_removable
export (bool) onready var active: bool = true setget _set_active

var _regex: RegEx = RegEx.new()

onready var _delete_regex_btn: TextureButton = $DeleteRegexButton as TextureButton

onready var _valid_regex_indicator: TextureRect = $ValidRegexIndicator as TextureRect
onready var _regex_compile_timer: Timer = $RegexCompileTimer as Timer

onready var _regex_line_edit: LineEdit = $RegexLineEdit as LineEdit
onready var _replacement_line_edit: LineEdit = $ReplacementLineEdit as LineEdit
onready var _affects_selected_checkbox: CheckBox = $AffectsSelectedFilesCheckBox as CheckBox


func _ready() -> void:
	compile_regex()


func process_string(input: String) -> String:
	if !compiled_regex_is_valid():
		return input

	return _regex.sub(input, _replacement_line_edit.text, true)


func compile_regex() -> bool:
	_valid_regex_indicator.valid = _regex.compile(_regex_line_edit.text) == OK
	emit_signal("rule_updated")

	return compiled_regex_is_valid()


func compiled_regex_is_valid() -> bool:
	return _valid_regex_indicator.valid


func affects_all_files() -> bool:
	return !_affects_selected_checkbox.pressed


func _set_removable(is_removable: bool) -> void:
	removable = is_removable
	_delete_regex_btn.disabled = !removable


func _set_active(is_active: bool) -> void:
	active = is_active

	if active:
		self.modulate = Color("FFFFFF")
		_regex_line_edit.editable = true
		_replacement_line_edit.editable = true
	else:
		self.modulate = Color("808080")
		_regex_line_edit.editable = false
		_replacement_line_edit.editable = false


func _on_AddNewRegexButton_pressed():
	emit_signal("add_rule_pressed")


func _on_DeleteRegexButton_pressed():
	emit_signal("remove_rule_pressed")


func _on_RegexLineEdit_text_changed(new_text: String) -> void:
	_valid_regex_indicator.standby = true
	_regex_compile_timer.start()


func _on_ReplacementLineEdit_text_changed(new_text: String) -> void:
	emit_signal("rule_updated")


func _on_RegexCompileTimer_timeout():
	_valid_regex_indicator.standby = false
	compile_regex()


func _on_AffectsSelectedFilesCheckBox_toggled(button_pressed):
	emit_signal("rule_updated")


func _on_ReviewRuleRollover_mouse_entered():
	emit_signal("review_mode_toggled", true)


func _on_ReviewRuleRollover_mouse_exited():
	emit_signal("review_mode_toggled", false)


func _on_SwapRuleDirectionButton_pressed():
	var regex_text = _regex_line_edit.text

	_regex_line_edit.text = _replacement_line_edit.text
	_replacement_line_edit.text = regex_text

	compile_regex()

