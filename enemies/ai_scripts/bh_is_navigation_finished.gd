class_name IsNavigationFinished extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
    if actor.nav_agent.distance_to_target() < 2.0:
        return SUCCESS

    return FAILURE
