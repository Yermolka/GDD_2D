@tool
class_name SkillAoe extends SkillProjectile

func _ready() -> void:
	super._ready()

	remove_effects_on_apply = false
	remove_self_on_apply = false

	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 1.0
	timer.timeout.connect(func() -> void: queue_free())
	add_child(timer)

func _physics_process(_delta: float) -> void:
	pass


func should_apply_effect(node: Node3D) -> bool:
	return node.is_in_group(target_group)

