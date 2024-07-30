class_name MoveToPlayer extends ActionLeaf

@export var range: float = 2.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Enemy
	var player: Player = get_tree().get_first_node_in_group("player")
	if not actor.nav_agent.is_navigation_finished():
		var look_pos: Vector3 = actor.nav_agent.get_next_path_position()
		if look_pos != actor.global_position:
			actor.look_at(actor.nav_agent.get_next_path_position())
	else:
		actor.look_at(player.global_position)
	actor.global_rotation.x = 0
	actor.global_rotation.z = 0

	if actor.nav_agent.distance_to_target() > range:
		return RUNNING
	
	return SUCCESS
