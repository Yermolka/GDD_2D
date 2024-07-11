extends Node

var player_level: int:
	get:
		var player: Player = get_tree().get_first_node_in_group("player")
		if player:
			return player.level
		else:
			return 0

var global_state: Dictionary = {}
