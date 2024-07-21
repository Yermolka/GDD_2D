class_name ItemTooltip extends Control

@onready var item_name: Label = $VBoxContainer/ItemName
@onready var item_type: Label = $VBoxContainer/ItemType
@onready var required_level: Label = $VBoxContainer/RequiredLevel
@onready var stat_tooltip: HBoxContainer = $VBoxContainer/StatTooltipContainer
@onready var effect_info: Label = $VBoxContainer/EffectInfo
@onready var stack_info: Label = $VBoxContainer/StackInfo
var item: ItemBase


func _ready() -> void:
	item_name.text = item.name
	if item is EquipmentBase:
		item = item as EquipmentBase
		item_type.text = item.tags.filter(func (x: String) -> bool: return x.begins_with("equipment."))[0].split(".")[1]
		item_type.text[0] = item_type.text[0].to_upper()
		required_level.text = "Required level: " + str(item.required_level)
		var i: int = 0
		for s: AttributeEffect in item.stats:
			var new_stat: HBoxContainer = stat_tooltip.duplicate()
			$VBoxContainer.add_child(new_stat)
			$VBoxContainer.move_child(new_stat, 3 + i)
			i += 1

			new_stat.get_children()[0].text = s.attribute_name
			new_stat.get_children()[0].text[0] = new_stat.get_children()[0].text[0].to_upper()
			new_stat.get_children()[1].text = str(int(s.get_current_value()))
		effect_info.visible = false
		stack_info.visible = false

	elif item is Potion:
		item_type.text = "Potion"
		required_level.visible = false
		stat_tooltip.visible = false
		effect_info.text = item.desription
		if item.can_stack:
			stack_info.text = str(item.quantity_current) + "/" + str(item.quantity_max)
		else:
			stack_info.visible = false

	else:
		item_type.visible = false
		stat_tooltip.visible = false
		required_level.visible = false
		stat_tooltip.visible = false
		effect_info.visible = false
		stack_info.visible = false


func set_item(_item: ItemBase) -> void:
	item = _item
	



