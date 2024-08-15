class_name IsDead extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
    if actor.attribute_map.get_attribute_by_name("health").current_buffed_value == 0:
        return SUCCESS
    else:
        return FAILURE
