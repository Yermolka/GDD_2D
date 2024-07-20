class_name InventoryHUD extends Control

var inventory: Inventory
var equipment: Equipment

@onready var inventory_frame: GridContainer = $Inventory/GridContainer
@onready var char_screen_frame: GridContainer = $CharScreen/GridContainer
@onready var inventory_slot_scene: PackedScene = preload("res://hud/inventory_slot.tscn")

@onready var inventory_container: GridContainer = $InventoryContainer
var inventory_slots: Array[InventorySlot]

var inventory_map: Array[InventorySlot]

func setup(_inventory: Inventory, _equipment: Equipment) -> void:
	inventory = _inventory
	equipment = _equipment

	inventory_slots.assign(inventory_container.get_children())
	inventory.item_added.connect(
		func (_item: Item) -> void:
			var item: ItemBase = _item as ItemBase
			for i: InventorySlot in inventory_slots:
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
			for i: InventorySlot in inventory_slots:
				if i.item == _item:
					i.item = null
					return
	)
	inventory.item_depleted.connect(
		func (_item: Item) -> void:
			var item: ItemBase = _item as ItemBase
			for i: InventorySlot in inventory_slots:
				if i.item == _item:
					i.item = null
					return
	)
	inventory.item_activated.connect(
		func (_item: Item, _activation_type: int) -> void:
			var item: ItemBase = _item as ItemBase
			for i: InventorySlot in inventory_slots:
				if i.item == _item:
					i.update()
	)

	$Inventory.visible = false
	$CharScreen.visible = false
	$Inventory.visibility_changed.connect(
		func() -> void:
			if not $Inventory.visible:
				return
			for i: InventorySlot in inventory_slots:
				if not i.item:
					continue
				if i.item._can_equip(equipment):
					i.modulate = Color.WHITE
				else:
					i.modulate = Color.RED
	)

	for i: int in range(inventory_slots.size()):
		inventory_slots[i].slot_pressed.connect(
			func (item: Item) -> void:
				if item is EquipmentBase:
					inventory.remove_item(item)
					equipment.equip(item)
				elif inventory.can_activate(item):
					inventory.activate(item)
		)
		inventory_slots[i].equipment = equipment
		inventory_slots[i].inventory = inventory
		if inventory.items.size() > i:
			inventory_slots[i].item = inventory.items[i]

	var equipment_slots: Array = $EquipmentContainer.get_children()
	for i: int in range(equipment_slots.size()):
		equipment_slots[i].setup(equipment.slots[i], equipment, inventory)

	# var equipment_slots: Array = char_screen_frame.get_children().filter(func (x: Node) -> bool: return x is EquipmentSlotUI)
	# for i: int in range(equipment_slots.size()):
	# 	equipment_slots[i].setup(equipment.slots[i])

	# inventory.item_added.connect(
	# 	func (_item: Item) -> void:
	# 	var item: ItemBase = _item as ItemBase
	# 	for i: InventorySlot in inventory_map:
	# 		if i.item == item:
	# 			return
	# 	if item == null:
	# 		printerr(_item.name, " is not ItemBase!")
	# 		return
	# 	_first_free_slot().item = item
	# )
	# inventory.item_removed.connect(
	# 	func (_item: Item) -> void:
	# 		var item: ItemBase = _item as ItemBase
	# 		for i: InventorySlot in inventory_map:
	# 			if i.item == _item:
	# 				i.item = null
	# 				return
	# )
	# inventory.item_depleted.connect(
	# 	func (_item: Item) -> void:
	# 		var item: ItemBase = _item as ItemBase
	# 		for i: InventorySlot in inventory_map:
	# 			if i.item == _item:
	# 				i.item = null
	# 				return
	# )

func _first_free_slot() -> InventorySlot:
	for i: InventorySlot in inventory_slots:
		if i.item == null:
			return i

	return null

func toggle_inventory() -> void:
	visible = not visible
	# inventory_container.visible = not inventory_container.visible
	# $Inventory.visible = not $Inventory.visible

func toggle_char_screen() -> void:
	visible = not visible
	# inventory_container.visible = not inventory_container.visible
	# $CharScreen.visible = not $CharScreen.visible


func _on_close_button_pressed() -> void:
	$Inventory.visible = false


func _on_char_screen_close_button_pressed() -> void:
	$CharScreen.visible = false
