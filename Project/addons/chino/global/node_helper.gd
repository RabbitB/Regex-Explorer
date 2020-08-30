extends Reference
class_name NodeHelper


static func get_child_of_class(node: Node, name_of_class: String, include_ancestors: bool = true) -> Node:

	for child in node.get_children():

		var child_class: String = child.get_class()

		if child_class == name_of_class || (include_ancestors && ClassDB.is_parent_class(child_class, name_of_class)):
			return child

	return null


static func get_children_of_class(node: Node, name_of_class: String, include_ancestors: bool = true) -> Array:

	var children_of_class: Array = []

	for child in node.get_children():

		var child_class: String = child.get_class()

		if child_class == name_of_class || (include_ancestors && ClassDB.is_parent_class(child_class, name_of_class)):
			children_of_class.append(child)

	return children_of_class

