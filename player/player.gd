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

## For loading only
var inventory_items: Array:
	get:
		return inventory.items.map(
		func (x: ItemBase) -> Dictionary:
			print(x.resource_path)
			return {
				"resource_path": x.get_resource_path(),
				"quantity": x.quantity_current
			}
		)

var equipped_items: Array:
	get:
		return equipment.slots.map(
		func (x: EquipmentSlot) -> Dictionary:
			return {
				"name": x.name,
				"item_path": x.equipped.get_resource_path() if x.has_equipped_item else null
			}
	)

var stats: Dictionary:
	get:
		return attribute_map._attributes_dict
	set(value):
		attribute_map._attributes_dict = stats

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

	Questify.update_quests()

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
			print("Ready to turn in ", quest.name)
	)
	Questify.quest_turned_in.connect(
		func(quest: QuestResource) -> void:
			print("Turned in ", quest.name)
			if not quest.remove_items_on_complete:
				return

			var conditions: Array[QuestNode] = quest.nodes.filter(func(node: QuestNode) -> bool: return node is QuestCondition)
			for cond: QuestCondition in conditions:
				if cond.type != "has_item":
					continue

				var item: Item = inventory.find_by(func (x: Item) -> bool: return x.name == cond.key)
				if item: 
					inventory.remove_item(item, true)
					continue
				
				item = equipment.find_item_by(func (x: Item) -> bool: return x.name == cond.key)
				if item:
					equipment.unequip(item, true)
					inventory.remove_items_by(func (x: Item) -> bool: return x.name == cond.key)
	)

func _ready() -> void:
	add_to_group("player")
	add_to_group("persist")

	_setup_attr_map()
	_setup_inventory()
	_setup_quests()

	print("Player: granted ", ability_container.grant_all_abilities(), " abilities")

func _quest_update(type: String, key: String, value: Variant, requester: QuestCondition) -> void:
	if type != "has_item":
		return

	var found: Array[Item] = inventory.filter_by(func (item: Item) -> bool: return item.name == key) + equipment.equipped_items.filter(func (item: Item) -> bool: return item.name == key)
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

	if Input.is_action_just_pressed("quick_save"):
		Globals.save()
	if Input.is_action_just_pressed("quick_load"):
		Globals.load()
		

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


func finalize_load() -> void:
	load_inventory()
	load_equipment()


func serialize() -> Dictionary:
	return {
		"filename": scene_file_path,
		"parent": get_parent().get_path(),
		"pos_x": global_position.x,
		"pos_y": global_position.y,
		"pos_z": global_position.z,
		"stats": stats,
		"level": level,
		"current_xp": current_xp,
		"inventory_items": inventory_items,
		"equipped_items": equipped_items
	}


func load_inventory() -> void:
	for item: Dictionary in inventory_items:
		var new_item: Item = load(item.resource_path)
		new_item.quantity_current = item.quantity

		inventory.add_item(new_item)


func load_equipment() -> void:
	for item: Dictionary in equipped_items:
		for slot: EquipmentSlot in equipment.slots:
			if slot.name == item.name:
				if item.item_path:
					# slot.equipped = load(item.item_path)
					slot.equip(load(item.item_path))
				else:
					slot.equipped = null
