class_name Potion extends ItemBase

@export var effects: Array[AttributeEffect] = []
@export var duration: float = 0.0

var effect: GameplayEffect:
	get:
		var _effect: GameplayEffect = GameplayEffect.new()
		_effect.attributes_affected = effects
		return _effect

var antieffect: GameplayEffect:
	get:
		var _effect: GameplayEffect = GameplayEffect.new()
		for stat: AttributeEffect in effects:
			var _stat: AttributeEffect = stat.duplicate() as AttributeEffect
			_stat.minimum_value *= -1
			_stat.maximum_value *= -1
			_effect.attributes_affected.append(_stat)
		return _effect

func _activate(_activation_event: ItemActivationEvent) -> void:
	var player: Player = _activation_event.owner as Player
	player.attribute_map.apply_effect(effect)

	if duration != 0.0:
		player.helper(duration, antieffect)
