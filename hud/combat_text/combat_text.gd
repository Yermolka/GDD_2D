class_name CombatText extends Control

var text: String:
    get:
        return $Label.text
    set(value):
        $Label.text = value

var text_owner: Node3D
var crit: bool = false

func _ready() -> void:
    visibility_changed.connect(
        func () -> void:
            if visible:
                process_mode = Node.PROCESS_MODE_INHERIT
                if crit:
                    $AnimationPlayer.play(["main_crit", "main_left_crit"][randi_range(0, 1)])
                else:
                    $AnimationPlayer.play(["main", "main_left"][randi_range(0, 1)])
                scale = Vector2.ONE * randf_range(0.8, 1.5)
            else:
                process_mode = Node.PROCESS_MODE_DISABLED
    )


func _process(delta: float) -> void:
    if is_instance_valid(text_owner):
        position = get_viewport().get_camera_3d().unproject_position(text_owner.global_position)
