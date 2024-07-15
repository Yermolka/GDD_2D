class_name Enemy extends Entity

@onready var drop: Drop = $Drop
@export var xp_reward: int = 0
@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap
@onready var ability_container: AbilityContainer = $AbilityContainer
@export var ui_name: String = "enemy"

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("persist")

	attribute_map.attribute_changed.connect(
		func (attr: AttributeSpec) -> void:
			if attr.attribute_name == "health" and attr.current_buffed_value == 0:
				drop.drop_items()
				var player: Player = get_tree().get_first_node_in_group("player")
				player.give_xp(xp_reward)
				EventBus.enemyKilled.emit(self)
				call_deferred("queue_free")
			print(attr.attribute_name, ": ", attr.current_buffed_value)
	)

	print("Enemy: ", name, " was granted ", ability_container.grant_all_abilities(), " abilities")

# func _physics_process(delta: float) -> void:
	# var player: Player = get_tree().get_first_node_in_group("player")
	# var abc: TargetedSkill = ability_container.find_by(func(x: Ability) -> bool: return x is TargetedSkill)
	# abc.set_target(player)
	# ability_container.activate_one(abc)


func serialize() -> Dictionary:
	return {
		"filename": scene_file_path,
		"parent": get_parent().get_path(),
		"pos_x": global_position.x,
		"pos_y": global_position.y,
		"pos_z": global_position.z,
		"xp_reward": xp_reward,
		"drop_table": drop.drop_table.resource_path,
	}
