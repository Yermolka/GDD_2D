class_name MoveToSpawn extends ActionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
    if actor.nav_agent.target_position != blackboard.get_value("base_position"):
        actor.nav_agent.target_position = blackboard.get_value("base_position")

    if not actor.nav_agent.is_navigation_finished():
        actor.look_at(actor.nav_agent.get_next_path_position())
        actor.global_rotation.x = 0
        actor.global_rotation.z = 0

    return SUCCESS
