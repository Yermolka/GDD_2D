class_name Player extends Entity


@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap
@onready var inventory: Inventory = $Inventory
@onready var equipment: Equipment = $Equipment
@onready var ability_container: AbilityContainer = $AbilityContainer

@export var level: int = 1
@export var current_xp: int = 0:
	get:
		return current_xp
	set(value):
		current_xp = value
		if xp_map.size() > level and current_xp >= xp_map[level]:
			current_xp -= xp_map[level]
			level += 1
			level_changed.emit(level)
		if xp_map.size() > level:
			current_xp_changed.emit(current_xp, xp_map[level])
@export var xp_map: Array[int]
signal current_xp_changed(value: int, maxValue: int)
signal level_changed(value: int)

const SPEED: float = 5.0
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
		func(_item: Item) -> void:
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

	call_deferred("_setup_equipped_items")

func _setup_equipped_items() -> void:
	for eqb: EquipmentBase in equipment.equipped_items:
		if eqb is Weapon:
			ability_container.grant(eqb.skill)
			for tier: SkillTreeTierData in eqb.skill_tree.tiers:
				for upgrade: GDDSkillUpgrade in tier.skills:
					if upgrade.learned:
						upgrade.apply(eqb.skill, ability_container)
		add_child(eqb.effect)
		equipment.equipped.emit(eqb, null)

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

	print("Player: granted ", ability_container.grant_all_abilities(), " abilities")

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
	# if Input.is_action_just_pressed("ability1"):
	# 	pass

	# if Input.is_action_just_pressed("ability2"):
	# 	pass

	# if Input.is_action_just_pressed("ability3"):
	# 	pass

	# if Input.is_action_just_pressed("ability4"):
	# 	pass
	pass
		

func _process_movement() -> void:
	if ability_container.has_tag("movement.dashing"):
		return

	var horizontal: float = Input.get_axis("move_left", "move_right")
	var vertical: float = Input.get_axis("move_up", "move_down")
	var direction: Vector3 = Vector3(horizontal, 0, vertical).normalized()

	if direction:
		velocity = direction * movement_speed
		ability_container.add_tag("moving")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		ability_container.remove_tag("moving")

	move_and_slide()

func helper(duration: float, gameplay_effect: GameplayEffect) -> void:
	await get_tree().create_timer(duration).timeout
	attribute_map.apply_effect(gameplay_effect)

func give_xp(amount: int) -> void:
	current_xp += amount
	var weapons: Array = equipment.slots.filter(func(x: EquipmentSlot) -> bool: return "weapon" in x.name)
	for w: EquipmentSlot in weapons:
		if w.has_equipped_item:
			w.equipped.give_xp(amount)
