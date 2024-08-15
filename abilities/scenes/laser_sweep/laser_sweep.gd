extends MeleeBase


func _ready() -> void:
    super._ready()
    $AnimationPlayer.animation_finished.connect(
        func (x: String) -> void:
            if x == "attack":
                queue_free()
    )

    reparent(get_tree().root)
