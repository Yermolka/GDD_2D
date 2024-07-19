class_name PlayPlayerAnimation extends ActionLeaf

@export var anim_name: String
@export var interrupt_current: bool = true
@export var loop: Animation.LoopMode = Animation.LOOP_NONE

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Player
	if interrupt_current:
		actor.mesh_anim.play(anim_name)
	else:
		if actor.mesh_anim.is_playing() and actor.mesh_anim.current_animation != anim_name:
			return RUNNING
		actor.mesh_anim.play(anim_name)

	actor.mesh_anim.get_animation(anim_name).loop_mode = loop
	return SUCCESS
