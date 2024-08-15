extends MeleeBase


var first_ball_velocity: Vector3 = Vector3(0, 10, 7)
var ball_velocities: Array[Vector3] = [
    Vector3(-2, 5, 2),
    Vector3(2, 5, 2),
    Vector3(2, 5, -2),
    Vector3(-2, 5, -2)
]
@onready var balls: Array[Node3D] = [$Ball1, $Ball2, $Ball3, $Ball4]


func _ready() -> void:
    super._ready()
    reparent(get_tree().root)


func _physics_process(delta: float) -> void:
    if $FirstBall.visible:
        $FirstBall.position += first_ball_velocity * delta
        first_ball_velocity -= Vector3(0, 20, 0) * delta

    for i in range(4):
        if balls[i].visible:
            balls[i].position += ball_velocities[i] * delta
            ball_velocities[i] -= Vector3(0, 20, 0) * delta


func _on_first_ball_body_entered(body: Node3D) -> void:
    $FirstBall.visible = false
    var collision_pos: Vector3 = $FirstBall.global_position

    global_position = collision_pos
    for i in range(4):
        balls[i].visible = true
    set_deferred("monitorable", true)
    set_deferred("monitoring", true)
    get_tree().create_timer(2.0).timeout.connect(func () -> void: queue_free())
