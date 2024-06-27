class_name Player extends Entity


@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap
@onready var inventory: Inventory = $Inventory
@onready var equipment: Equipment = $Equipment
@onready var ability_container: AbilityContainer = $AbilityContainer


@onready var test_helm: EquipmentBase = preload("res://items/test_helm.tres").duplicate()
@onready var healing_potion: ItemBase = preload("res://items/healing_potion.tres")
@onready var test_effect: ChanceAttributeEffect = ChanceAttributeEffect.new()

const SPEED: float = 300.0
var movement_speed: float:
	get:
		return SPEED * attribute_map.get_attribute_by_name("movement_speed").current_buffed_value / 100.0
	set(value):
		attribute_map.get_attribute_by_name("movement_speed").current_value = value

func _setup_attr_map() -> void:
	attribute_map.attribute_changed.connect(
		func (attr: AttributeSpec) -> void:
			print(attr.attribute_name, ": ", attr.current_buffed_value, "/", attr.maximum_value)
	)
	attribute_map.attribute_effect_applied.connect(
		func (_attribute_effect: AttributeEffect, attribute: AttributeSpec) -> void:
			print(attribute.current_buffed_value)
	)
	attribute_map.attribute_added.connect(
		func (attr: AttributeSpec) -> void:
			ability_container.add_tag("resources." + attr.attribute_name)
	)
	attribute_map.attribute_removed.connect(
		func (attr: AttributeSpec) -> void:
			ability_container.remove_tag("resources." + attr.attribute_name)
	)

func _setup_inventory() -> void:
	inventory.item_added.connect(
		func(item: Item) -> void:
			print(item.name)
			if item is EquipmentBase:
				test_helm = item

			Questify.update_quests()
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

func _setup_quests() -> void:
	Questify.condition_query_requested.connect(_quest_update)
	Questify.quest_started.connect(
		func(quest: QuestResource) -> void:
			print("Started ", quest.name)
	)
	Questify.quest_objective_completed.connect(
		func(quest: QuestResource, objective: QuestObjective) -> void:
			print(quest.name, ": objective complete --- ", objective.description)
	)
	Questify.quest_completed.connect(
		func(quest: QuestResource) -> void:
			print("Completed ", quest.name)
	)

func _ready() -> void:
	add_to_group("player")

	_setup_attr_map()
	_setup_inventory()
	_setup_quests()

	inventory.add_item(test_helm)
	var attr: AttributeSpec = AttributeSpec.new()
	attr.attribute_name = "rage"
	attr.minimum_value = 0
	attr.maximum_value = 100
	attr.current_value = 0

	attribute_map.add_attribute(attr)
	print(ability_container.grant_all_abilities())

	test_effect.attribute_name = "rage"
	test_effect.proc_chance = 50
	test_effect.minimum_value = 10
	test_effect.maximum_value = 50

func _quest_update(type: String, key: String, value: Variant, requester: QuestCondition) -> void:
	if type != "has_item":
		return

	var found: Array[Item] = inventory.filter_by(func (item: Item) -> bool: return item.name == key)
	var count: int = 0
	for f: Item in found:
		if f.can_stack:
			count += f.quantity_current
		else:
			count += 1

	if count >= value:
		requester.completed = true

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
		var abc: TargetedSkill = ability_container.find_by(func (x: Ability) -> bool: return x.ui_name == "Melee")
		if abc:
			abc.set_target(get_tree().get_first_node_in_group("selected"))
			ability_container.activate_one(abc)

	if Input.is_action_just_pressed("ability4"):
		# ability_container.abilities.append(load("res://abilities/passive/slippery_toes.tres"))
		# print(ability_container.grant(load("res://abilities/passive/slippery_toes.tres")))
		# ability_container.activate_many()
		# var abc: TargetedSkill = ability_container.find_by(func (x: Ability) -> bool: return x.ui_name == "Heroic Strike")
		# if abc:
		# 	abc.set_target(get_tree().get_first_node_in_group("selected"))
		# 	ability_container.activate_one(abc)
		# else:
		# 	print("got no rage!")

		var abc: TargetedSkill = ability_container.find_by(func (x: Ability) -> bool: return x.ui_name == "Melee")
		if abc:
			if abc.chance_effects.has(test_effect):
				print("Removing")
				abc.chance_effects.erase(test_effect)
			else:
				print("Adding")
				abc.chance_effects.append(test_effect)
			
		

func _process_movement() -> void:
	var horizontal: float = Input.get_axis("move_left", "move_right")
	var vertical: float = Input.get_axis("move_up", "move_down")
	var direction: Vector2 = Vector2(horizontal, vertical).normalized()

	if direction:
		velocity = direction * movement_speed
		ability_container.add_tag("interrupted")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		ability_container.remove_tag("interrupted")

	move_and_slide()

func helper(duration: float, gameplay_effect: GameplayEffect) -> void:
	await get_tree().create_timer(duration).timeout
	attribute_map.apply_effect(gameplay_effect)
