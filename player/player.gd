class_name Player extends Entity

signal current_xp_changed(value: int, maxValue: int)
signal level_changed(value: int)

@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap
@onready var inventory: Inventory = $Inventory
@onready var equipment: Equipment = $Equipment
@onready var ability_container: AbilityContainer = $AbilityContainer
@export var movement_skill: MovementSkill

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
@export var xp_map: Array
var unlocked_passives: Array[String] = []

@onready var forward: Vector3 = get_viewport().get_camera_3d().global_transform.basis.z
@onready var player_screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(global_position)
@onready var mesh: Node3D = $Model

@export_group("Animation")
@export var mesh_anim: AnimationPlayer
@export var body_top: Node3D
@export var body_bot: Node3D
@onready var blackboard: PlayerBlackboard = $PlayerBlackboard


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
				"resource_path": x.equipped.get_resource_path() if x.has_equipped_item else null
			}
	)


var stats: Dictionary:
	get:
		return attribute_map._attributes_dict
	set(value):
		attribute_map._attributes_dict = stats


var camera: CameraController:
	get:
		return get_viewport().get_camera_3d()


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


func _setup_ability_container() -> void:
	ability_container.abilities.append(movement_skill)
	print(ability_container.grant_all_abilities())

	ability_container.ability_activated.connect(handle_ability_activated)
	ability_container.ability_ended.connect(handle_ability_ended)


func handle_ability_ended(ability: ActiveSkill, activation_event: ActivationEvent) -> void:
	blackboard.set_value("attacking", false)


func handle_ability_activated(ability: ActiveSkill, activation_event: ActivationEvent) -> void:
	if ability.cast_time > 0.0:
		blackboard.set_value("casting", true)
		await ability.cast_ended
		blackboard.set_value("casting", false)
	else:
		blackboard.set_value("attacking", true)


func _ready() -> void:
	add_to_group("player")
	add_to_group("persist")

	_setup_attr_map()
	_setup_inventory()
	_setup_quests()
	_setup_ability_container()

	await get_tree().physics_frame

	forward = get_viewport().get_camera_3d().global_transform.basis.z
	

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

	if Input.is_physical_key_pressed(KEY_B):
		print(unlocked_passives)


func _process_movement() -> void:
	look_at(camera.last_ray_position)
	global_rotation.z = 0
	global_rotation.x = 0

	velocity = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= 9.8

	if ability_container.has_tag("movement.dashing"):
		blackboard.set_value("moving", true)
		return

	var horizontal: Vector3 = (Input.get_axis("move_left", "move_right") * forward).rotated(Vector3.UP, PI / 2)
	var vertical: Vector3 = Input.get_axis("move_up", "move_down") * forward
	var direction: Vector3 = (horizontal + vertical).normalized()

	if direction:
		blackboard.set_value("moving", true)
		velocity += direction * movement_speed
		ability_container.add_tag("moving")
	else:
		blackboard.set_value("moving", false)
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


func serialize() -> Dictionary:
	var attribute_map_data: Dictionary = {}
	for key: String in attribute_map._attributes_dict.keys():
		attribute_map_data[key] = {
							"minimum_value": attribute_map._attributes_dict[key].minimum_value,
							"maximum_value": attribute_map._attributes_dict[key].maximum_value,
							"current_value": attribute_map._attributes_dict[key].current_value,
							"buffing_value": attribute_map._attributes_dict[key].buffing_value,
		}

	# TODO: Also save unlocked skills & upgrades
	return {
		"player": {
			"global_position": global_position,
			"level": level,
			"current_xp": current_xp,
			"xp_map": xp_map,
			"inventory_data": {
				"max_size": inventory.max_size,
				"items": inventory_items,
				"equipped_items": equipped_items,
			},
			"ability_container_tags": ability_container.tags,
			"attribute_map_data": attribute_map_data,
			"unlocked_passives": unlocked_passives,
		}
	}


func deserialize(body: Dictionary) -> void:
	global_position = body.global_position
	level = body.level
	current_xp = body.current_xp
	xp_map = body.xp_map
	unlocked_passives = body.unlocked_passives

	var inventory_data: Dictionary = body.inventory_data
	inventory.max_size = inventory_data.max_size
	inventory.items = []
	for item_dict: Dictionary in inventory_data.items:
		var new_item: ItemBase = load(item_dict.resource_path)
		new_item.quantity_current = item_dict.quantity
		inventory.call_deferred("add_item", new_item)
	
	for item_dict: Dictionary in inventory_data.equipped_items:
		if item_dict.resource_path == null:
			continue

		var slot: EquipmentSlot = equipment.find_slot_by(func (x: EquipmentSlot) -> bool: return x.name == item_dict.name)
		slot.equipped = null
		var new_item: EquipmentBase = load(item_dict.resource_path)
		slot.call_deferred("equip", new_item)

	var typed_tags: Array[String] = []
	typed_tags.assign(body.ability_container_tags)

	ability_container.tags = typed_tags
