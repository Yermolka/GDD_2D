extends Node

signal onTargetSelected(target: Entity)
signal startDialogue(data: DialogueData, start: String)
signal dialogueSignal(value: String)
signal dialogueSetVariable(key: String, value: Variant)
signal enemyKilled(enemy: Enemy)
signal boss_fight_started(boss: Enemy)
signal boss_fight_ended()


func _enter_tree() -> void:
	onTargetSelected.connect(func (t: Entity) -> void:
		print("Targeted: ", t.name)
	)
