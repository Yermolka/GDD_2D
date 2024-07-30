class_name ChooseRandomPoint extends ActionLeaf

@export var radius: float = 10.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	if not actor.nav_agent.is_navigation_finished():
		return SUCCESS

	var base_pos: Vector3 = blackboard.get_value("base_position")
	
	actor.nav_agent.target_position = base_pos + (Vector3.RIGHT * randf_range(radius / 10, radius)).rotated(Vector3.UP, randf_range(0, 2 * PI))

	return SUCCESS
