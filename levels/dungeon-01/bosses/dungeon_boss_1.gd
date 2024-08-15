extends Entity


signal phase_1_done
signal transition_1_done
signal phase_2_done
signal transition_2_done
signal death


@onready var ability_container: AbilityContainer = $AbilityContainer
var player: Player:
    get:
        return get_tree().get_first_node_in_group("player")
var ability_map: Dictionary
enum State {
    Idle,
    Phase1,
    Transition1,
    Phase2,
    Transition2,
    Phase3,
}
var state: State = State.Idle
var health: AttributeSpec:
    get:
        return $GameplayAttributeMap.get_attribute_by_name("health")
var phase1_abilities: Array[String] = ["Eye Beam", "Laser Sweep", "Exploding Ball"]
@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap
var pillars: Array[Entity] = []
@onready var pillar_scene: PackedScene = preload("res://levels/dungeon-01/bosses/01/summon_stone.tscn")
@onready var shield_mesh: MeshInstance3D = $MeshInstance3D
@onready var hellfire_scene: PackedScene = preload("res://levels/dungeon-01/bosses/01/hellfire.tscn")


func _ready() -> void:
    for a: GDDSkill in ability_container.granted_abilities:
        ability_map[a.ui_name] = a

    player.death.connect(reset)
    health.changed.connect(
        func (attr: AttributeSpec) -> void:
            if attr.current_buffed_value == 0:
                death.emit()
                EventBus.boss_fight_ended.emit()
                queue_free()
    )


func reset() -> void:
    ability_container.stop_many_cooldowns()
    state = State.Idle
    health.current_value = health.maximum_value
    rotation = Vector3.ZERO
    shield_mesh.visible = false
    %HurtBox.set_deferred("monitoring", true)
    %HurtBox.set_deferred("monitorable", true)


func _physics_process(delta: float) -> void:
    match state:
        State.Idle:
            return
        State.Phase1:
            process_phase1()
        State.Transition1:
            process_transition1()
        State.Phase2:
            process_phase2()
        State.Transition2:
            process_transition2()
        State.Phase3:
            process_phase3()


func process_phase1() -> void:
    look_at(player.global_position)
    rotation.x = 0
    rotation.z = 0
    rotation_degrees.y += 180
    for a: String in phase1_abilities:
        ability_container.activate_one(ability_map[a])

    if health.current_buffed_value <= health.maximum_value * 0.8:
        state = State.Transition1
        phase_1_done.emit()


func process_transition1() -> void:
    if pillars.size() == 0:
        var pos: Array[Vector3] = [
            global_position + Vector3(-12, 0.5, -9),
            global_position + Vector3(12, 0.5, -9),
            global_position + Vector3(12, 0.5, 9),
            global_position + Vector3(-12, 0.5, 9)
        ]
        for i in range(4):
            var pillar: Entity = pillar_scene.instantiate()
            get_tree().root.add_child(pillar)
            pillar.global_position = pos[i]
            pillars.append(pillar)
        %HurtBox.set_deferred("monitoring", false)
        %HurtBox.set_deferred("monitorable", false)
        shield_mesh.visible = true
    else:
        for p: Entity in pillars:
            if is_instance_valid(p):
                return

        transition_1_done.emit()
        state = State.Phase2
        %HurtBox.set_deferred("monitoring", true)
        %HurtBox.set_deferred("monitorable", true)
        shield_mesh.visible = false
        pillars.clear()


func process_phase2() -> void:
    look_at(player.global_position)
    rotation.x = 0
    rotation.z = 0
    rotation_degrees.y += 180
    for a: String in phase1_abilities:
        ability_container.activate_one(ability_map[a])

    if health.current_buffed_value <= health.maximum_value * 0.5:
        state = State.Transition2
        phase_2_done.emit()


func process_transition2() -> void:
    look_at(player.global_position)
    rotation.x = 0
    rotation.z = 0
    rotation_degrees.y += 180
    for a: String in phase1_abilities:
        ability_container.activate_one(ability_map[a])

    if pillars.size() == 0:
        var pos: Array[Vector3] = [
            global_position + Vector3(-12, 0.5, -9),
            global_position + Vector3(12, 0.5, -9),
            global_position + Vector3(12, 0.5, 9),
            global_position + Vector3(-12, 0.5, 9)
        ]
        for i in range(4):
            var pillar: Entity = pillar_scene.instantiate()
            get_tree().root.add_child(pillar)
            pillar.global_position = pos[i]
            pillars.append(pillar)
        %HurtBox.set_deferred("monitoring", false)
        %HurtBox.set_deferred("monitorable", false)
        shield_mesh.visible = true
    else:
        for p: Entity in pillars:
            if is_instance_valid(p):
                return

        transition_2_done.emit()
        state = State.Phase3
        %HurtBox.set_deferred("monitoring", true)
        %HurtBox.set_deferred("monitorable", true)
        shield_mesh.visible = false
        pillars.clear()
        $Timer.start()


func process_phase3() -> void:
    look_at(player.global_position)
    rotation.x = 0
    rotation.z = 0
    rotation_degrees.y += 180
    for a: String in phase1_abilities:
        ability_container.activate_one(ability_map[a])


func _on_boss_area_1_body_entered(body:Node3D) -> void:
    if body is Player:
        state = State.Phase1
        EventBus.boss_fight_started.emit(self)


func _on_timer_timeout() -> void:
    for i in range(4):
        var hellfire: MeleeBase = hellfire_scene.instantiate()
        add_child(hellfire)
        hellfire.global_position = global_position + Vector3(randf_range(-12.0, 12.0), 5, randf_range(-9.0, 9.0))
