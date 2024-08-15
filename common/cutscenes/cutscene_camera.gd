class_name CutsceneCamera extends Camera3D


signal movement_finished


var speed: float = 5
var target_pos: Vector3
var target_look_at: Vector3


func move_to(pos: Vector3, _speed: float = 5) -> void:
    target_pos = pos
    speed = _speed
    process_mode = Node.PROCESS_MODE_INHERIT


func move_by(dir: Vector3, _speed: float = 5) -> void:
    target_pos = global_position + dir
    speed = _speed
    process_mode = Node.PROCESS_MODE_INHERIT


func _physics_process(delta: float) -> void:
    var dir: Vector3 = (target_pos - global_position).normalized()
    global_position += dir * speed * delta
    if target_look_at != Vector3.ZERO:
        look_at(target_look_at)
    if global_position.distance_to(target_pos) < 0.1:
        global_position = target_pos
        movement_finished.emit()
        process_mode = Node.PROCESS_MODE_DISABLED


func set_look_at(target: Vector3) -> void:
    target_look_at = target
