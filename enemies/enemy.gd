class_name Enemy extends Entity

@onready var drop: Drop = $Drop
@export var xp_reward: int = 0
@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap
@onready var ability_container: AbilityContainer = $AbilityContainer

func _ready() -> void:
	add_to_group("enemies")
	attribute_map.attribute_changed.connect(
		func (attr: AttributeSpec) -> void:
			if attr.attribute_name == "health" and attr.current_buffed_value == 0:
				drop.drop_items()
				var player: Player = get_tree().get_first_node_in_group("player")
				player.give_xp(xp_reward)
				call_deferred("queue_free")
			print(attr.attribute_name, ": ", attr.current_buffed_value)
	)

	print("Enemy: ", name, " was granted ", ability_container.grant_all_abilities(), " abilities")

# func _physics_process(delta: float) -> void:
	# var player: Player = get_tree().get_first_node_in_group("player")
	# var abc: TargetedSkill = ability_container.find_by(func(x: Ability) -> bool: return x is TargetedSkill)
	# abc.set_target(player)
	# ability_container.activate_one(abc)
