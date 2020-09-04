extends VBoxContainer


signal rules_updated()

const RegexRule: Script = preload("res://regex_rule/regex_rule.gd")
const RegexRuleScene: PackedScene = preload("res://regex_rule/regex_rule.tscn")
const RulePlaceholder: Script = preload("res://regex_rule/rule_placeholder/rule_placeholder.gd")
const RulePlaceholderScene: PackedScene = preload("res://regex_rule/rule_placeholder/rule_placeholder.tscn")

var _rule_placeholder: RulePlaceholder = null
var _dragged_rule: RegexRule
var _dragged_rule_original_index: int = 0
var _valid_drag_drop: bool = false


func _ready() -> void:
	_update_all_rules()


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN && get_viewport().gui_get_drag_data() is RegexRule:
		_dragged_rule = get_viewport().gui_get_drag_data()
		_dragged_rule_original_index = _dragged_rule.get_index()
	elif what == NOTIFICATION_DRAG_END:
		if !_valid_drag_drop:
			move_child(_dragged_rule, _dragged_rule_original_index)

		_dragged_rule = null
		_valid_drag_drop = false
		_dragged_rule_original_index = 0


func can_drop_data(position: Vector2, data) -> bool:
	if data is RegexRule:
		var insert_index: int = get_insert_index_for_position(position)
		if insert_index != -1:
			move_child(data, insert_index)
#
#			if !_rule_placeholder:
#				_rule_placeholder = RulePlaceholderScene.instance()
#				add_child(_rule_placeholder)
#
#			if _rule_placeholder.get_index() != insert_index:
#				_rule_placeholder.expand()
#				move_child(_rule_placeholder, insert_index)


		return true

	return false


func drop_data(position: Vector2, data) -> void:
	_valid_drag_drop = false

	if data is RegexRule:
		var insert_index: int = get_insert_index_for_position(position)
		if insert_index != -1:
			move_child(data, get_insert_index_for_position(position))

		_valid_drag_drop = true


func get_insert_index_for_position(position: Vector2) -> int:
	var rules: Array = get_rules()
	var current_index: int = 0
	var previous_rule: RegexRule = null
	var next_rule: RegexRule = null

	#	Exit early and return an invalid index if the data isn't even being drug over this control.
	if !get_rect().has_point(position):
		return -1

	for rule in rules:
		next_rule = rules[current_index + 1] if (current_index + 1) < rules.size() else null
		previous_rule = rules[current_index - 1] if current_index > 0 else null

		var rule_rect: Rect2 = (rule as RegexRule).get_rect()
		var upper_half: Rect2 = Rect2(rule_rect.position, Vector2(rule_rect.size.x, rule_rect.size.y / 2))
		var lower_half: Rect2 = Rect2(rule_rect.position + Vector2(0, upper_half.size.y), upper_half.size)

		if upper_half.has_point(position):
			return current_index
		elif lower_half.has_point(position):
			return current_index + 1
		elif position.y < rule_rect.position.y && (!previous_rule || position.y > previous_rule.get_rect().end.y):
			return current_index
		elif position.y > rule_rect.end.y && (!next_rule || position.y < next_rule.get_rect().position.y):
			return current_index + 1

		current_index += 1

	#	'position' isn't a valid position for which an insertion index could be generated, so return an invalid index.
	return -1


func process_string(input: String, in_preview_mode: bool = false, using_rules: Array = []) -> String:
	var output_string: String = input
	var rules: Array = get_rules() if using_rules.empty() else using_rules

	for rule in rules:
		if !rule.force_disabled && (rule.active || !in_preview_mode):
			output_string = rule.process_string(output_string)

	return output_string


func get_rules() -> Array:
	var rules: Array = []

	for child in get_children():
		if child is RegexRule:
			rules.append(child)

	return rules


func insert_rule(insert_after: RegexRule) -> void:
	var new_rule: RegexRule = RegexRuleScene.instance()
	add_child_below_node(insert_after, new_rule, true)

	_update_all_rules()


func remove_rule(rule_to_remove: RegexRule) -> void:
	remove_child(rule_to_remove)
	rule_to_remove.queue_free()

	_update_all_rules()


func preview_rule(should_preview: bool, rule_to_preview: RegexRule) -> void:
	var rules: Array = get_rules()
	var rule_index: int = rules.find(rule_to_preview)

	if rule_index == -1:
		rule_index = rules.size()

	for i in rules.size():
		if !should_preview || i <= rule_index:
			rules[i].active = true
		else:
			rules[i].active = false

	emit_signal("rules_updated")


func _connect_rule(rule: RegexRule) -> void:
	rule.connect("add_rule_pressed", self, "insert_rule", [rule])
	rule.connect("remove_rule_pressed", self, "remove_rule", [rule])
	rule.connect("rule_updated", self, "_rule_was_updated", [rule])
	rule.connect("preview_mode_toggled", self, "preview_rule", [rule])

func _update_all_rules() -> void:
	var rules: Array = get_rules()

	for rule in rules:
		rule.removable = true

		if !rule.is_connected("rule_updated", self, "_rule_was_updated"):
			_connect_rule(rule)

	rules[0].removable = rules.size() > 1
	emit_signal("rules_updated")


func _rule_was_updated(_updated_rule: RegexRule) -> void:
	emit_signal("rules_updated")

