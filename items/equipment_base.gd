class_name EquipmentBase extends ItemBase

@export_category("Stats")
@export var stats: Array[AttributeEffect] = []
var effect: GameplayEffect:
	get:
		var _effect: GameplayEffect = GameplayEffect.new()
		_effect.attributes_affected = stats
		return _effect
var antieffect: GameplayEffect:
	get:
		var _effect: GameplayEffect = GameplayEffect.new()
		for stat: AttributeEffect in stats:
			var _stat: AttributeEffect = stat.duplicate() as AttributeEffect
			_stat.minimum_value *= -1
			_stat.maximum_value *= -1
			_effect.attributes_affected.append(_stat)
		return _effect

@export var required_level: int = 0

func _can_equip(_equipment: Equipment) -> bool:
	return (_equipment.owner as Player).level >= required_level
