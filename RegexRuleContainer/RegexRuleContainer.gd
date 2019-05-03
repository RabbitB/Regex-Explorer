extends VBoxContainer

const RegexRule: Script = preload("res://../RegexRule/RegexRule.gd")
const RegexRuleScene: PackedScene = preload("res://../RegexRule/RegexRule.tscn")

signal rules_updated

var rules: Array = []

func _ready() -> void:

	_update_rules()
	_connect_new_rule(rules[0])

func process_string(input: String, file_selected: bool = true) -> String:

	var output_string: String = input

	for rule in rules:

		output_string = rule.process_string(output_string, file_selected)

	return output_string

func insert_rule(insert_after: RegexRule) -> void:

	var new_rule: RegexRule = RegexRuleScene.instance()
	add_child_below_node(insert_after, new_rule, true)

	_connect_new_rule(new_rule)
	_update_rules()
	emit_signal("rules_updated")

func remove_rule(rule_to_remove: RegexRule) -> void:

	remove_child(rule_to_remove)
	rule_to_remove.queue_free()

	_update_rules()
	emit_signal("rules_updated")

func _connect_new_rule(new_rule: RegexRule) -> void:

	new_rule.connect("add_new_rule", self, "insert_rule", [new_rule])
	new_rule.connect("remove_rule", self, "remove_rule", [new_rule])
	new_rule.connect("rule_updated", self, "_rule_was_updated", [new_rule])

func _update_rules() -> void:

	var rule_count: int = 0
	rules.clear()

	for rule in get_children():

		if rule is RegexRule:

			rules.append(rule)
			rule.rule_number = rule_count
			rule.enable_delete_button(true)

			rule_count += 1

	if rule_count == 1:
		rules[0].enable_delete_button(false)

func _rule_was_updated(updated_rule: RegexRule) -> void:

	emit_signal("rules_updated")