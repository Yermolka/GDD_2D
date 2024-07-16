class_name IsAbilityOnCooldown extends ConditionLeaf

@export var ability_name: String


## SUCCESS if can cast
func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Enemy
	var ability: ActiveSkill = actor.ability_container.find_by(func (x: Ability) -> bool: return x.ui_name == ability_name)
	if not actor.ability_container._has_cooldown(ability):
		return SUCCESS

	if actor.ability_container._get_cooldown_timer(ability).is_stopped():
		return SUCCESS
	else:
		return FAILURE
