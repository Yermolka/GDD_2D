class_name SkeletonBossBlackboard extends Blackboard

func _ready() -> void:
	set_value("phase", 1)
	set_value("state", "idle")
