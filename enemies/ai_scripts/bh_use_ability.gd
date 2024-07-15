class_name UseAbility extends ActionLeaf

@export var ability_name: String

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Enemy
	actor.ability_container.activate_one(actor.ability_container.find_by(func (x: Ability) -> bool: return x.ui_name == ability_name))
	return SUCCESS
