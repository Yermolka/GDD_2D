class_name Enemy extends Entity

@onready var drop: Drop = $Drop
@export var xp_reward: int = 0
@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap
@onready var ability_container: AbilityContainer = $AbilityContainer
@export var ui_name: String = "enemy"
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
const SPEED: float = 100.0

@export_group("animation")
@export var body_top: Node3D
@export var body_top_anim: AnimationPlayer
@export var body_bot: Node3D
@export var body_bot_anim: AnimationPlayer

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


func _physics_process(delta: float) -> void:
	var old_rotation: Vector3 = global_rotation
	if not nav_agent.is_navigation_finished():
		global_rotation = Vector3.ZERO
		var next_point: Vector3 = to_local(nav_agent.get_next_path_position())
		
		velocity = next_point.normalized() * SPEED * delta
	else:
		velocity = Vector3.ZERO
	move_and_slide()
	global_rotation = old_rotation


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
