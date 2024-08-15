extends MeleeBase


func _ready() -> void:
    super._ready()
    reparent(get_tree().root)
    print("HELLFIRE")


func _physics_process(delta: float) -> void:
    $CollisionShape3D.global_position += Vector3(0, -20, 0) * delta
    if $CollisionShape3D.global_position.y <= -0.5:
        queue_free()


func should_apply_effect(node: Node3D) -> bool:
    node = node as Entity
    if not node:
        return false

    return node.is_in_group("player")
