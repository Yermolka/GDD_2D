class_name HpBar3D extends Node3D

@onready var hp_sprite: Sprite3D = $Sprite3D
@onready var hp_label: Label3D = $Label3D


func _ready() -> void:
	await get_tree().physics_frame
	var enemy: Enemy = get_parent() as Enemy
	var hp_attr: AttributeSpec = enemy.attribute_map.get_attribute_by_name("health")
	hp_label.text = str(hp_attr.current_buffed_value) + "/" + str(hp_attr.maximum_value)

	enemy.attribute_map.attribute_changed.connect(
		func (attribute: AttributeSpec) -> void:
			if attribute.attribute_name == "health":
				var _scale: float = attribute.current_buffed_value / attribute.maximum_value
				hp_sprite.scale = Vector3(_scale, _scale, _scale)
				hp_label.text = str(attribute.current_buffed_value) + "/" + str(attribute.maximum_value)
	)


func _physics_process(delta: float) -> void:
	hp_label.look_at(get_viewport().get_camera_3d().global_position)
