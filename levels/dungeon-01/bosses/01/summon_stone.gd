extends Entity


@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap


func _ready() -> void:
    $GameplayAttributeMap.attribute_changed.connect(
        func (x: AttributeSpec) -> void:
            if x.attribute_name == "health" and x.current_buffed_value == 0:
                queue_free()
    )
    var summon: Ability = load("res://abilities/boss_abilities/summon_skeletons.tres").duplicate(true)
    $AbilityContainer.abilities.assign([summon])
    $AbilityContainer.grant_all_abilities()

    get_tree().get_first_node_in_group("player").death.connect(queue_free)


func _physics_process(delta: float) -> void:
    if $AnimationPlayer.current_animation.is_empty():
        $AbilityContainer.activate_one($AbilityContainer.granted_abilities[0])
