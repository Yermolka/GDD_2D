extends MeleeBase


func _ready() -> void:
    super._ready()
    $AnimationPlayer.animation_finished.connect(
        func (x: String) -> void:
            if x == "targeting":
                $AnimationPlayer.play("attack")
            elif x == "attack":
                queue_free()
    )

    position = Vector3(0, 2.6, 3.6)
    reparent(get_tree().root)
