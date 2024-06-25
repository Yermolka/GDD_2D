class_name Player extends CharacterBody2D


@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap
@onready var inventory: Inventory = $Inventory
@onready var equipment: Equipment = $Equipment

@onready var test_helm: EquipmentBase = preload("res://items/test_helm.tres").duplicate()
@onready var healing_potion: ItemBase = preload("res://items/healing_potion.tres")

const SPEED: float = 300.0
var movement_speed: float:
	get:
		return SPEED * attribute_map.get_attribute_by_name("movement_speed").current_value / 100.0
	set(value):
		attribute_map.get_attribute_by_name("movement_speed").current_value = value

func _ready() -> void:
	attribute_map.attribute_changed.connect(
		func (attr: AttributeSpec) -> void:
			print("Player HP: ", attr.current_buffed_value, "/", attr.maximum_value)
	)
	attribute_map.attribute_effect_applied.connect(
		func (_attribute_effect: AttributeEffect, attribute: AttributeSpec) -> void:
			print(attribute.current_buffed_value)
	)

	inventory.item_added.connect(
		func(item: Item) -> void:
			if item is EquipmentBase:
				test_helm = item
	)

	equipment.equipped.connect(
		func(item: Item, _slot: EquipmentSlot) -> void:
			var _item: EquipmentBase = item as EquipmentBase
			if not _item:
				return
			attribute_map.apply_effect(_item.effect)
	)

	equipment.unequipped.connect(
		func(item: Item, _slot: EquipmentSlot) -> void:
			var _item: EquipmentBase = item as EquipmentBase
			if not _item:
				return
			attribute_map.apply_effect(_item.antieffect)
	)

	inventory.add_item(test_helm)

func _physics_process(_delta: float) -> void:
	_process_movement()
	_process_input()

func _process_input() -> void:
	if Input.is_action_just_pressed("ability1"):
		if test_helm in equipment.equipped_items:
			equipment.unequip(test_helm)
			inventory.add_item(test_helm)
		else:
			inventory.remove_item(test_helm)
			equipment.equip(test_helm)

	if Input.is_action_just_pressed("ability2"):
		inventory.add_item(healing_potion)

	if Input.is_action_just_pressed("ability3"):
		attribute_map.get_attribute_by_name("health").current_value -= 50

func _process_movement() -> void:
	var horizontal: float = Input.get_axis("move_left", "move_right")
	var vertical: float = Input.get_axis("move_up", "move_down")
	var direction: Vector2 = Vector2(horizontal, vertical).normalized()

	if direction:
		velocity = direction * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

func helper(duration: float, gameplay_effect: GameplayEffect) -> void:
	await get_tree().create_timer(duration).timeout
	attribute_map.apply_effect(gameplay_effect)
