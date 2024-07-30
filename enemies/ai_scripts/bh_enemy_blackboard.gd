class_name EnemyBlackboard extends Blackboard

enum EnemyState {
    IDLE,
    PATROL,
    AGGRO,
    RETURN,
}

signal enemy_returning()

func _ready() -> void:
    set_value("base_position", get_parent().global_position)
    set_value("state", EnemyState.IDLE)
