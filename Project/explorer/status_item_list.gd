extends ItemList


enum ItemStatus {
	VALID,
	INVALID,
	MODIFIED,
	DISABLED_ON,
	DISABLED_OFF
}

const OK_ICON: Texture = preload("res://explorer/iconography/ok/ok_icon_modulate.png")
const ALERT_ICON: Texture = preload("res://explorer/iconography/alert/alert_icon_modulate.png")
const DISABLED_ICON: Texture = preload("res://explorer/iconography/disable_item/disable.png")
const DISABLED_ICON_OFF: Texture = preload("res://explorer/iconography/disable_item/disable_down.png")

export (Color) var valid_color: Color = Color8(71, 211, 103)
export (Color) var invalid_color: Color = Color8(211, 71, 74)
export (Color) var modified_color: Color = Color8(236, 131, 60)
export (Color) var disabled_color: Color = Color8(100, 100, 100)


func is_icon(idx: int) -> bool:
	#	Icons are always at even indices. Text is on odd.
	return !(idx % 2)


func add_item_with_status(
		item_text: String,
		item_status: int,
		item_icon: Texture = null,
		selectable: bool = true,
		icon_selectable: bool = false) -> void:
	var idx: int = get_item_count()

	add_icon_item(OK_ICON, icon_selectable)
	add_item(item_text, item_icon, selectable)

	_setup_icon(idx, item_status)
	_setup_text(idx + 1, item_status)


func change_item_status(idx: int, item_status: int) -> void:
	if !is_icon(idx):
		idx -= 1

	_setup_icon(idx, item_status)
	_setup_text(idx + 1, item_status)


func get_item_status(idx: int) -> int:
	if !is_icon(idx):
		idx -= 1

	match get_item_icon(idx):
		OK_ICON:
			return ItemStatus.VALID
		ALERT_ICON:
			return ItemStatus.MODIFIED if get_item_icon_modulate(idx) == modified_color else ItemStatus.INVALID
		DISABLED_ICON:
			return ItemStatus.DISABLED_ON
		DISABLED_ICON_OFF:
			return ItemStatus.DISABLED_OFF
		_:
			return ItemStatus.VALID


func change_item_text(idx: int, new_text: String) -> void:
	if is_icon(idx):
		idx += 1

	set_item_text(idx, new_text)


func set_icon_tooltip(idx: int, tooltip_text: String) -> void:
	if !is_icon(idx):
		idx -= 1

	set_item_tooltip(idx, tooltip_text)


func set_text_tooltip(idx: int, tooltip_text: String) -> void:
	if is_icon(idx):
		idx += 1

	set_item_tooltip(idx, tooltip_text)


func _setup_icon(idx: int, item_status: int) -> void:
	match item_status:
		ItemStatus.VALID:
			set_item_icon(idx, OK_ICON)
			set_item_icon_modulate(idx, valid_color)
		ItemStatus.INVALID:
			set_item_icon(idx, ALERT_ICON)
			set_item_icon_modulate(idx, invalid_color)
		ItemStatus.MODIFIED:
			set_item_icon(idx, ALERT_ICON)
			set_item_icon_modulate(idx, modified_color)
		ItemStatus.DISABLED_ON:
			set_item_icon(idx, DISABLED_ICON)
			set_item_icon_modulate(idx, Color.white)
		ItemStatus.DISABLED_OFF:
			set_item_icon(idx, DISABLED_ICON_OFF)
			set_item_icon_modulate(idx, Color.white)


func _setup_text(idx: int, item_status: int) -> void:
	match item_status:
		ItemStatus.DISABLED_ON:
			set_item_custom_fg_color(idx, disabled_color)
		_:
			set_item_custom_fg_color(idx, get_item_custom_fg_color(idx - 1))

