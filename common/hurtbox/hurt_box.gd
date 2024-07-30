class_name HurtBox extends Area3D


func _ready() -> void:
	var owner_entity: Entity = owner as Entity
	if not owner_entity:
		printerr("Hurtbox owner is not an Entity! ", owner)
