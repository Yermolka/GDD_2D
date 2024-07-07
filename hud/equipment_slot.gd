class_name EquipmentSlotUI extends Panel

var slot: EquipmentSlot
@onready var texture_rect: TextureRect = $TextureRect

func setup(_slot: EquipmentSlot) -> void:
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
