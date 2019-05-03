extends HBoxContainer

signal add_new_rule
signal remove_rule
signal rule_updated

export (bool) var rule_is_required: bool = false setget _set_rule_is_required
export (int) var rule_number: int = 0 setget _set_rule_number

onready var DeleteRegexButton: TextureButton = $DeleteRegexButton as TextureButton

onready var RuleNumberLabel: Label = $RuleNumberLabel as Label
onready var ValidRegexIndicator: TextureRect = $ValidRegexIndicator as TextureRect
onready var RegexCompileTimer: Timer = $RegexCompileTimer as Timer

onready var RegexLineEdit: LineEdit = $RegexLineEdit as LineEdit
onready var ReplacementLineEdit: LineEdit = $ReplacementLineEdit as LineEdit
onready var AffectsSelectedFilesCheckBox: CheckBox = $AffectsSelectedFilesCheckBox as CheckBox

onready var _is_ready: bool = true
var _regex: RegEx = RegEx.new()

func _ready() -> void:

	ValidRegexIndicator.valid = validate_regex()
	enable_delete_button(!rule_is_required)
	RuleNumberLabel.text = str(rule_number)

func process_string(input: String, file_selected: bool = true) -> String:

	if !compiled_regex_is_valid() || (!affects_all_files() && !file_selected): return input
	return _regex.sub(input, ReplacementLineEdit.text, true)

func validate_regex() -> bool:

	var compile_error: int = _regex.compile(RegexLineEdit.text)
	if compile_error: return false

	return true

func compiled_regex_is_valid() -> bool:

	return ValidRegexIndicator.valid

func affects_all_files() -> bool:

	return !AffectsSelectedFilesCheckBox.pressed

func enable_delete_button(enabled: bool):

	if enabled:

		DeleteRegexButton.disabled = false
		DeleteRegexButton.self_modulate = Color8(255, 255, 255)

	else:

		DeleteRegexButton.disabled = true
		DeleteRegexButton.self_modulate = Color8(80, 80, 80)

func _on_AddNewRegexButton_pressed():

	emit_signal("add_new_rule")

func _on_DeleteRegexButton_pressed():

	emit_signal("remove_rule")

func _on_RegexLineEdit_text_changed(new_text: String) -> void:

	ValidRegexIndicator.standby = true
	RegexCompileTimer.start()

func _on_ReplacementLineEdit_text_changed(new_text: String) -> void:

	emit_signal("rule_updated")

func _on_RegexCompileTimer_timeout():

	ValidRegexIndicator.standby = false
	ValidRegexIndicator.valid = validate_regex()

	emit_signal("rule_updated")

func _on_AffectsSelectedFilesCheckBox_toggled(button_pressed):

	emit_signal("rule_updated")

func _set_rule_is_required(is_required: bool) -> void:

	rule_is_required = is_required
	if _is_ready: enable_delete_button(!is_required)

	emit_signal("rule_updated")

func _set_rule_number(num: int) -> void:

	rule_number = num
	if _is_ready: RuleNumberLabel.text = str(rule_number)