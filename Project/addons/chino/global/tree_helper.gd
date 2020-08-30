extends Reference
class_name TreeHelper

enum ScrollPlacement {
	VISIBLE,
	ON_TOP,
	ON_BOTTOM
}


static func _scroll_to_item(tree: Tree, item: TreeItem, select: bool, column: int) -> void:

	var scroll_selection: TreeSelection = TreeSelection.create(item, column)
	var previous_selection: TreeSelection = TreeSelection.current_selection_of_tree(tree)

	var y = scroll_selection.force_temp_select()
	tree.ensure_cursor_is_visible()
	y.resume()

	if select:
		scroll_selection.select()
	elif previous_selection.item != null:
		previous_selection.select()


static func scroll_to_item(
		tree: Tree,
		item: TreeItem,
		select: bool = false,
		column: int = 0,
		placement: int = ScrollPlacement.VISIBLE) -> void:

	if placement == ScrollPlacement.ON_TOP:
		scroll_to_bottom(tree)
	elif placement == ScrollPlacement.ON_BOTTOM:
		scroll_to_top(tree)

	_scroll_to_item(tree, item, select, column)


static func scroll_to_top(tree: Tree) -> void:

	var scroll_bar: VScrollBar = NodeHelper.get_child_of_class(tree, "VScrollBar") as VScrollBar
	scroll_bar.value = scroll_bar.min_value


static func scroll_to_bottom(tree: Tree) -> void:

	var scroll_bar: VScrollBar = NodeHelper.get_child_of_class(tree, "VScrollBar") as VScrollBar
	scroll_bar.value = scroll_bar.max_value


static func insert_collection_layout(tree: Tree, collection, parent: TreeItem = null) -> void:

	var collection_type: int = typeof(collection)

	var iterator_group = collection.keys() if collection_type == TYPE_DICTIONARY else range(collection.size())
	for iter in iterator_group:
		var collection_item = collection[iter]
		var collection_item_type: int = typeof(collection_item)
		
		var new_entry: TreeItem = tree.create_item(parent)
		if collection_item_type == TYPE_DICTIONARY || collection_item_type == TYPE_ARRAY:
			insert_collection_layout(tree, collection_item, new_entry)


class TreeSelection:

	var item: TreeItem
	var column: int


	static func create(item: TreeItem, column: int) -> TreeSelection:

		var new_selection: TreeSelection = TreeSelection.new()

		new_selection.item = item
		new_selection.column = column

		return new_selection


	static func current_selection_of_tree(tree: Tree) -> TreeSelection:

		if tree:
			return create(tree.get_selected(), tree.get_selected_column())

		return TreeSelection.new()


	func select() -> void:

		if !item:
			return

		item.select(column)


	func force_select() -> void:

		if !item:
			return

		if !item.is_selectable(column):
			item.set_selectable(column, true)

		item.select(column)


	func force_temp_select() -> void:

		if !item:
			return

		var item_is_selectable: bool = item.is_selectable(column)

		if !item_is_selectable:
			item.set_selectable(column, true)

		item.select(column)
		yield()
		item.deselect(column)

		if !item_is_selectable:
			item.set_selectable(column, false)

