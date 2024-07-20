class_name GlobalSignal extends ActionLeaf

@export var signal_name: String

func tick(actor: Node, blackboard: Blackboard) -> int:
	EventBus.emit_signal(signal_name, actor)
	return SUCCESS
