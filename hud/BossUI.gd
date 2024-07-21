class_name BossUI extends Control

@onready var progress_bar: TextureProgressBar = $TextureProgressBar


func _ready() -> void:
	EventBus.boss_fight_started.connect(
		func (boss: Enemy) -> void:
			show()
			var hp: AttributeSpec = boss.attribute_map.get_attribute_by_name("health")
			progress_bar.max_value = hp.maximum_value
			progress_bar.value = hp.current_buffed_value
			boss.attribute_map.attribute_changed.connect(
				func (attr: AttributeSpec) -> void:
					if attr.attribute_name == "health":
						progress_bar.value = attr.current_buffed_value
			)
	)

	EventBus.boss_fight_ended.connect(
		func (boss: Enemy) -> void:
			hide()
	)
