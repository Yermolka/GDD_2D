class_name PlayAnimation extends ActionLeaf

@export_enum("Top", "Bottom", "Both") var which: int = 2
@export var anim_name: StringName
@export var interrupt_current: bool = true

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor = actor as Enemy
	if interrupt_current:
		match which:
			0:
				actor.body_top_anim.play(anim_name)
			1:
				actor.body_bot_anim.play(anim_name)
			2:
				actor.body_top_anim.play(anim_name)
				actor.body_bot_anim.play(anim_name)
	else:
		match which:
			0:
				if actor.body_top_anim.is_playing() and actor.body_top_anim.current_animation != anim_name:
					return RUNNING
				actor.body_top_anim.play(anim_name)
			1:
				if actor.body_bot_anim.is_playing() and actor.body_bot_anim.current_animation != anim_name:
					return RUNNING
				actor.body_bot_anim.play(anim_name)
			2:
				if (actor.body_bot_anim.is_playing() and actor.body_bot_anim.current_animation != anim_name) or (actor.body_top_anim.is_playing() and actor.body_top_anim.current_animation != anim_name):
					return RUNNING
				actor.body_top_anim.play(anim_name)
				actor.body_bot_anim.play(anim_name)
	return SUCCESS
