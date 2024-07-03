@icon("res://addons/godot_gameplay_systems/attributes_and_abilities/assets/AttributeEffect.svg")

class_name ChanceAttributeEffect extends AttributeEffect

@export var proc_chance: float = 10.0

var proc: bool:
	get:
		return randi_range(0, 100) < proc_chance
