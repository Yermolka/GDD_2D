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
			texture = item.ui_icon
		else:
			texture = null

var equipment: Equipment = null

func _on_gui_input(event: InputEvent) -> void:
	if item == null:
		return
	
	event = event as InputEventMouseButton
	if not event:
		return

	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and item._can_equip(equipment):
		slot_pressed.emit(item)
