class_name InventoryHUD extends Control

var inventory: Inventory
var equipment: Equipment

@onready var inventory_frame: GridContainer = $Inventory/GridContainer
@onready var char_screen_frame: GridContainer = $CharScreen/GridContainer
@onready var inventory_slot_scene: PackedScene = preload("res://hud/inventory_slot.tscn")

var inventory_map: Array[InventorySlot]

func setup(_inventory: Inventory, _equipment: Equipment) -> void:
	inventory = _inventory
	equipment = _equipment

	inventory.item_added.connect(
		func (_item: Item) -> void:
		var item: ItemBase = _item as ItemBase
		for i: InventorySlot in inventory_map:
			if i.item == item:
				return
		if item == null:
			printerr(_item.name, " is not ItemBase!")
			return
		_first_free_slot().item = item
	)
	inventory.item_removed.connect(
		func (_item: Item) -> void:
			var item: ItemBase = _item as ItemBase
			for i: InventorySlot in inventory_map:
				if i.item == _item:
					i.item = null
					return
	)
	inventory.item_depleted.connect(
		func (_item: Item) -> void:
			var item: ItemBase = _item as ItemBase
			for i: InventorySlot in inventory_map:
				if i.item == _item:
					i.item = null
					return
	)

	$Inventory.visible = false
	$CharScreen.visible = false

	for i: int in range(inventory.max_size):
		var inventory_slot: InventorySlot = inventory_slot_scene.instantiate()
		inventory_frame.add_child(inventory_slot)
		inventory_slot.slot_pressed.connect(
			func (item: Item) -> void:
				if item is EquipmentBase:
					inventory.remove_item(item)
					equipment.equip(item)
				elif inventory.can_activate(item):
					inventory.activate(item)
		)
		inventory_map.append(inventory_slot)

	var equipment_slots: Array = char_screen_frame.get_children().filter(func (x: Node) -> bool: return x is EquipmentSlotUI)
	for i: int in range(equipment_slots.size()):
		equipment_slots[i].setup(equipment.slots[i])

func _first_free_slot() -> InventorySlot:
	for i: InventorySlot in inventory_map:
		if i.item == null:
			return i
	
	return null

func toggle_inventory() -> void:
	$Inventory.visible = not $Inventory.visible

func toggle_char_screen() -> void:
	$CharScreen.visible = not $CharScreen.visible
