class_name MoveToIdle extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Enemy
	if not actor.nav_agent.is_navigation_finished():
		actor.look_at(actor.nav_agent.get_next_path_position())
		actor.global_rotation.x = 0
		actor.global_rotation.z = 0
		return RUNNING

	return SUCCESS
