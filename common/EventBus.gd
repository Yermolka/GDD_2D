extends Node

signal onTargetSelected(target: CharacterBody2D)

func _enter_tree() -> void:
	onTargetSelected.connect(func (t: CharacterBody2D) -> void:
		print(t.name)
	)
