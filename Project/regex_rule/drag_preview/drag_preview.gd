extends HBoxContainer


export(String) var regex_text: String
export(String) var replacement_text: String


onready var _regex_line_edit: LineEdit = $RegexLineEdit as LineEdit
onready var _replacement_line_edit: LineEdit = $ReplacementLineEdit as LineEdit


func _ready() -> void:
	preview_regex(regex_text, replacement_text)


func preview_regex(preview_regex_text: String, preview_replacement_text: String) -> void:
	regex_text = preview_regex_text
	replacement_text = preview_replacement_text

	if is_inside_tree():
		_regex_line_edit.text = regex_text
		_replacement_line_edit.text = replacement_text

