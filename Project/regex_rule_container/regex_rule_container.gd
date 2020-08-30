extends VBoxContainer

const RegexRule: Script = preload("res://../regex_rule/regex_rule.gd")
const RegexRuleScene: PackedScene = preload("res://../regex_rule/regex_rule.tscn")

signal rules_updated

var rules: Array = []

func _connect_rule(rule: RegexRule) -> void:

	rule.connect("add_rule_pressed", self, "insert_rule", [rule])
	rule.connect("remove_rule_pressed", self, "remove_rule", [rule])
	rule.connect("rule_updated", self, "_rule_was_updated", [rule])
	rule.connect("review_rule_toggled", self, "review_rule", [rule])

func _update_all_rules() -> void:

	rules.clear()

	for rule in get_children():

		if rule is RegexRule:

			rules.append(rule)
			rule.removable = true

			if !rule.is_connected("rule_updated", self, "_rule_was_updated"):
				_connect_rule(rule)

	rules[0].removable = rules.size() > 1
	emit_signal("rules_updated")


func _rule_was_updated(updated_rule: RegexRule) -> void:

	emit_signal("rules_updated")


func _ready() -> void:

	_update_all_rules()


func process_string(input: String, file_selected: bool = true, review_mode: bool = false) -> String:

	var output_string: String = input

	for rule in rules:

		if (rule.affects_all_files() || file_selected) && (rule.active || !review_mode):
			output_string = rule.process_string(output_string)

	return output_string


func insert_rule(insert_after: RegexRule) -> void:

	var new_rule: RegexRule = RegexRuleScene.instance()
	add_child_below_node(insert_after, new_rule, true)

	_update_all_rules()


func remove_rule(rule_to_remove: RegexRule) -> void:

	remove_child(rule_to_remove)
	rule_to_remove.queue_free()

	_update_all_rules()


func review_rule(should_review: bool, rule_to_review: RegexRule) -> void:

	var rule_index: int = rules.find(rule_to_review)

	if rule_index == -1:
		rule_index = rules.size()

	for i in rules.size():

		if !should_review || i <= rule_index:
			rules[i].active = true
		else:
			rules[i].active = false

	emit_signal("rules_updated")

