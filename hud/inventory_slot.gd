class_name InventorySlot extends Panel

signal slot_pressed(item: Item)

var texture: Texture2D:
	get:
		return $TextureRect.texture
	set(value):
		$TextureRect.texture = value

var item: ItemBase:
	set(value):
		item = value
		if item != null:
			tooltip_text = "1"
			texture = item.ui_icon
			if item.can_stack:
				$CountLabel.text = str(item.quantity_current)
			else:
				$CountLabel.text = ""
		else:
			tooltip_text = ""
			texture = null
			$CountLabel.text = ""

var equipment: Equipment
var inventory: Inventory

func _on_gui_input(event: InputEvent) -> void:
	if item == null:
		return
	
	event = event as InputEventMouseButton
	if not event:
		return

	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and item._can_equip(equipment):
		slot_pressed.emit(item)


func _make_custom_tooltip(for_text: String) -> Control:
	var new_tooltip: ItemTooltip = load("res://hud/inventory/item_tooltip.tscn").instantiate()
	new_tooltip.visible = true
	new_tooltip.set_item(item)
	return new_tooltip


func update() -> void:
	await get_tree().process_frame
	$CountLabel.text = str(item.quantity_current)


func _get_drag_data(at_position: Vector2) -> Variant:
	print("Begin drag")
	if not item:
		return null

	var preview: TextureRect = TextureRect.new()
	preview.custom_minimum_size = Vector2(32, 32)
	preview.texture = item.ui_icon
	set_drag_preview(preview)
	
	return {
		"item": item,
		"owner": self,
	}


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data.get("item") is ItemBase


func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("End drag")
	if data.get("owner") is InventorySlot:
		data["owner"].item = item
		item = data["item"]
	elif data.get("owner") is EquipmentSlot:
		if item == null:
			item = data["item"]
		elif item._can_equip(equipment) and data["owner"].can_equip(item):
			inventory.add_item(data["item"])
			equipment.unequip(data["item"])
			equipment.equip(item)
			inventory.remove_item(item)
