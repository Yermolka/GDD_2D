class_name CanUseAbility extends ConditionLeaf

@export var ability_name: String

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Enemy
	var ability: ActiveSkill = actor.ability_container.find_by(func (x: Ability) -> bool: return x.ui_name == ability_name)
	if ability.can_activate(ActivationEvent.new(actor.ability_container)):
		return SUCCESS
	else:
		return FAILURE
