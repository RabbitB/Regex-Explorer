extends HBoxContainer

signal add_rule_pressed
signal remove_rule_pressed
signal rule_updated
signal review_rule_toggled(should_review)

export (bool) onready var removable: bool = false setget _set_removable
export (bool) onready var active: bool = true setget _set_active

onready var _DeleteRegexButton: TextureButton = $DeleteRegexButton as TextureButton

onready var _ValidRegexIndicator: TextureRect = $ValidRegexIndicator as TextureRect
onready var _RegexCompileTimer: Timer = $RegexCompileTimer as Timer

onready var _RegexLineEdit: LineEdit = $RegexLineEdit as LineEdit
onready var _ReplacementLineEdit: LineEdit = $ReplacementLineEdit as LineEdit
onready var _AffectsSelectedFilesCheckBox: CheckBox = $AffectsSelectedFilesCheckBox as CheckBox

var _regex: RegEx = RegEx.new()

func _set_removable(is_removable: bool) -> void:

	removable = is_removable
	_DeleteRegexButton.disabled = !removable


func _set_active(is_active: bool) -> void:

	active = is_active

	if active:
		self.modulate = Color("FFFFFF")
		_RegexLineEdit.editable = true
		_ReplacementLineEdit.editable = true
	else:
		self.modulate = Color("808080")
		_RegexLineEdit.editable = false
		_ReplacementLineEdit.editable = false


func _ready() -> void:

	compile_regex()


func process_string(input: String) -> String:

	if !compiled_regex_is_valid():
		return input

	return _regex.sub(input, _ReplacementLineEdit.text, true)


func compile_regex() -> bool:

	var is_valid: bool = _regex.compile(_RegexLineEdit.text) == OK
	_ValidRegexIndicator.valid = is_valid

	emit_signal("rule_updated")
	return is_valid


func compiled_regex_is_valid() -> bool:

	return _ValidRegexIndicator.valid


func affects_all_files() -> bool:

	return !_AffectsSelectedFilesCheckBox.pressed


func _on_AddNewRegexButton_pressed():

	emit_signal("add_rule_pressed")


func _on_DeleteRegexButton_pressed():

	emit_signal("remove_rule_pressed")


func _on_RegexLineEdit_text_changed(new_text: String) -> void:

	_ValidRegexIndicator.standby = true
	_RegexCompileTimer.start()


func _on_ReplacementLineEdit_text_changed(new_text: String) -> void:

	emit_signal("rule_updated")


func _on_RegexCompileTimer_timeout():

	_ValidRegexIndicator.standby = false
	compile_regex()


func _on_AffectsSelectedFilesCheckBox_toggled(button_pressed):

	emit_signal("rule_updated")


func _on_ReviewRuleRollover_mouse_entered():

	emit_signal("review_rule_toggled", true)


func _on_ReviewRuleRollover_mouse_exited():

	emit_signal("review_rule_toggled", false)


func _on_SwapRuleDirectionButton_pressed():

	var regex_text = _RegexLineEdit.text

	_RegexLineEdit.text = _ReplacementLineEdit.text
	_ReplacementLineEdit.text = regex_text

	compile_regex()

