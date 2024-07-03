extends Node

signal onTargetSelected(target: CharacterBody2D)
signal startDialogue(data: DialogueData, start: String)
signal dialogueSignal(value: String)

func _enter_tree() -> void:
	onTargetSelected.connect(func (t: CharacterBody2D) -> void:
		print(t.name)
	)
