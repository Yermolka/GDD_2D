class_name Enemy extends CharacterBody2D

@onready var drop: Drop = $Drop
@onready var attribute_map: GameplayAttributeMap = $GameplayAttributeMap

func _ready() -> void:
	add_to_group("enemies")
	attribute_map.attribute_changed.connect(
		func (attr: AttributeSpec) -> void:
			if attr.attribute_name == "health" and attr.current_buffed_value == 0:
				drop.drop_items()
				print("dead")
				call_deferred("queue_free")
	)
