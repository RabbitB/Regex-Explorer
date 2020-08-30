extends Reference
class_name ArrayHelper


static func has_type(array: Array, type: int) -> bool:

	for item in array:

		if typeof(item) == type:
			return true

	return false


static func has_class(array: Array, name_of_class: String, include_ancestors: bool = true) -> bool:

	for item in array:

		if typeof(item) != TYPE_OBJECT:
			continue

		var item_class: String = item.get_class()

		if item_class == name_of_class || (include_ancestors && ClassDB.is_parent_class(item_class, name_of_class)):
			return true

	return false

