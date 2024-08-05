class_name CombatText extends Control

var text: String:
    get:
        return $Label.text
    set(value):
        $Label.text = value

var text_owner: Node3D

func _ready() -> void:
    visibility_changed.connect(
        func () -> void:
            if visible:
                process_mode = Node.PROCESS_MODE_INHERIT
                $AnimationPlayer.play("main")
            else:
                process_mode = Node.PROCESS_MODE_DISABLED
    )


func _process(delta: float) -> void:
    if text_owner:
        position = get_viewport().get_camera_3d().unproject_position(text_owner.global_position)
