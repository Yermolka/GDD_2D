class_name HpBar extends Control

@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var label: Label = $Label
@onready var enemy: Enemy = get_parent()
@onready var camera: CameraController = get_viewport().get_camera_3d()

@export var head_point: Node3D


func _ready() -> void:
    await get_tree().physics_frame
    var hp_attr: AttributeSpec = enemy.attribute_map.get_attribute_by_name("health")
    label.text = str(hp_attr.current_buffed_value) + "/" + str(hp_attr.maximum_value)
    progress_bar.value = hp_attr.current_buffed_value / hp_attr.maximum_value * 100

    enemy.attribute_map.attribute_changed.connect(
        func (attribute: AttributeSpec) -> void:
            if attribute.attribute_name == "health":
                var _scale: float = attribute.current_buffed_value / attribute.maximum_value
                progress_bar.value = _scale * 100
                label.text = str(attribute.current_buffed_value) + "/" + str(attribute.maximum_value)
    )


func _physics_process(delta: float) -> void:
    position = camera.unproject_position(head_point.global_position)
