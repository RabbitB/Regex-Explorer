extends TextureButton


const RegexRule: Script = preload("res://regex_rule/regex_rule.gd")
const DragPreview: PackedScene = preload("res://regex_rule/drag_preview/drag_preview.tscn")


func get_drag_data(_position: Vector2):
	var parent: RegexRule = get_parent() as RegexRule
	var preview: Node = DragPreview.instance()

	preview.preview_regex(parent.regex_text(), parent.replacement_text())
	set_drag_preview(preview)

	return parent

