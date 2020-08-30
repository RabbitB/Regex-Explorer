extends Reference
class_name TreeItemHelper


static func expand_all_ancestors(tree_item: TreeItem) -> void:

	tree_item.collapsed = false

	var parent: TreeItem = tree_item.get_parent()
	while parent:

		parent.collapsed = false
		parent = parent.get_parent()


static func expand_all_children(tree_item: TreeItem) -> void:

	tree_item.collapsed = false

	var child: TreeItem = tree_item.get_children()
	while child:

		expand_all_children(child)
		child = child.get_next()


static func collapse_all_children(tree_item: TreeItem, collapse_root: bool = true) -> void:

	tree_item.collapsed = collapse_root

	var child: TreeItem = tree_item.get_children()
	while child:

		collapse_all_children(child)
		child = child.get_next()


static func get_all_children(tree_item: TreeItem) -> Array:

	var children: TreeItem = tree_item.get_children()
	var children_array: Array = []

	while children != null:
		children_array.append(children)
		children = children.get_next()

	return children_array


static func filter_children(tree_item: TreeItem, column: int, filter) -> Array:

	var all_children: Array = get_all_children(tree_item)
	var filtered_children: Array = []

	for child in all_children:

		if child.get_text(column) == filter:
			filtered_children.append(child)

	return filtered_children


static func filter_children_custom(tree_item: TreeItem, filter, obj, function: String) -> Array:

	var all_children: Array = get_all_children(tree_item)
	var filtered_children: Array = []

	for child in all_children:

		if obj.call(function, child, filter):
			filtered_children.append(child)

	return filtered_children


static func tree_depth(tree_item: TreeItem, calculate_from_root: bool = false) -> int:

	var depth: int = 0
	var current_parent = tree_item.get_parent()

	while current_parent:

		depth += 1
		current_parent = current_parent.get_parent()

	if depth > 0 && !calculate_from_root:
		depth -= 1

	return depth

