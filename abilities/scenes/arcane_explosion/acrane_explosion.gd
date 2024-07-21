class_name ArcaneExplosion extends MeleeBase


func _ready() -> void:
	super._ready()

	reparent(get_tree().root)
	($AnimationPlayer as AnimationPlayer).animation_finished.connect(
		func (_x: StringName) -> void:
			queue_free()
	)
