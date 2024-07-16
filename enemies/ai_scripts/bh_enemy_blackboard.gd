class_name EnemyBlackboard extends Blackboard

func _ready() -> void:
	set_value("base_position", get_parent().global_position)
