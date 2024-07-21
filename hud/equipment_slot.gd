class_name EquipmentSlotUI extends Panel

var slot: EquipmentSlot
@onready var texture_rect: TextureRect = $TextureRect
var equipment: Equipment
var inventory: Inventory


func setup(_slot: EquipmentSlot, _equipment: Equipment, _inventory: Inventory) -> void:
	equipment = _equipment
	inventory = _inventory
	if slot == _slot:
		return

	slot = _slot
	slot.item_equipped.connect(_draw_slot)
	slot.item_unequipped.connect(
		func (_item: Item, __slot: EquipmentSlot) -> void:
			texture_rect.texture = null
	)
	if slot.has_equipped_item:
		_draw_slot(slot.equipped, slot)


func _draw_slot(item: Item, _slot: EquipmentSlot) -> void:
	item = item as EquipmentBase
	if item:
		texture_rect.texture = item.ui_icon
	else:
		texture_rect.texture = null


func _get_drag_data(at_position: Vector2) -> Variant:
	print("Begin drag from equipment")
	if not slot.equipped:
		return null

	var preview: TextureRect = TextureRect.new()
	preview.custom_minimum_size = Vector2(32, 32)
	preview.texture = slot.equipped.ui_icon
	set_drag_preview(preview)

	return {
		"item": slot.equipped,
		"owner": self,
	}


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not data["item"] is EquipmentBase:
		return false

	return data["item"]._can_equip(equipment) and slot.can_equip(data["item"])


func _drop_data(at_position: Vector2, data: Variant) -> void:
	print("End drag at equipment")
	if data["owner"] == self:
		return

	if data["owner"] is InventorySlot:
		data["owner"].item = null

	if slot.equipped != null:
		# inventory.add_item(slot.equipped)
		equipment.unequip(slot.equipped)
	equipment.equip(data["item"])
	inventory.remove_item(data["item"])
