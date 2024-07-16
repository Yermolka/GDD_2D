class_name PlayerInRange extends ConditionLeaf

@export var range: float = 10.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player: Player = get_tree().get_first_node_in_group("player")
	if actor.global_position.distance_to(player.global_position) <= range:
		return SUCCESS
	else:
		return FAILURE
