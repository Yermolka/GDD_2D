class_name MeleeBase extends EffectedArea3D

@export var apply_once_per_target: bool = true
@onready var caster: Entity = get_parent()
var applied_to: Array[Entity] = []

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	hide()
	queue_free()

func should_apply_effect(node: Node3D) -> bool:
	node = node as Entity
	if not node:
		return false
	
	var should: bool = node.is_in_group("player") != caster.is_in_group("player")
	if not should:
		return false

	if apply_once_per_target and node in applied_to:
		return false

	applied_to.append(node)
	return true
