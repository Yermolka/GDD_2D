class_name SkeletonBoss extends Enemy

## Thresholds in remaining hp
var phase_health: Array[int] = [500, 400, 150]
@onready var blackboard: SkeletonBossBlackboard = $SkeletonBossBlackboard

func _ready() -> void:
	super._ready()

	attribute_map.attribute_changed.connect(
		func (attr: AttributeSpec) -> void:
			if attr.attribute_name == "health":
				if attr.current_buffed_value <= phase_health[2]:
					blackboard.set_value("phase", 3)
				elif attr.current_buffed_value <= phase_health[1]:
					blackboard.set_value("phase", 2)

				
				if attr.current_buffed_value == 0:
					Globals.set_global_var("skeleton_boss_killed", true)
	)
