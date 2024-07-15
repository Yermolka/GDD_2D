class_name TargetPlayer extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player: Player = get_tree().get_first_node_in_group("player")
	actor.nav_agent.target_position = player.global_position
	return SUCCESS
