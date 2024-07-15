class_name MoveToPlayer extends ActionLeaf

@export var range: float = 2.0
@export var max_range: float = 20.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Enemy
	if actor.nav_agent.distance_to_target() > max_range:
		actor.nav_agent.target_position = actor.global_position
		return FAILURE
	elif actor.nav_agent.distance_to_target() > range:
		return RUNNING
	
	return SUCCESS
