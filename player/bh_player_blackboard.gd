class_name PlayerBlackboard extends Blackboard

func _ready() -> void:
	set_value("moving", false)
	set_value("casting", false)
	set_value("attacking", false)
