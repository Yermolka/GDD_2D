class_name InGameBar extends Control


@onready var health: ProgressBar = $HealthMana/Health
@onready var mana: ProgressBar = $HealthMana/Mana
@onready var skill_1: SelectedSkillButton = $SelectedSkills/Skill0
@onready var skill_2: SelectedSkillButton = $SelectedSkills/Skill1
@onready var skill_3: SelectedSkillButton = $SelectedSkills/Skill2
@onready var cast_bar: ProgressBar = $CastBar

func _set_progress_bar(bar: ProgressBar, attribute_spec: AttributeSpec) -> void:
	if attribute_spec == null:
		return

	bar.min_value = attribute_spec.minimum_value
	bar.max_value = attribute_spec.maximum_value
	bar.value = attribute_spec.current_value


func activate_ability_on_slot(slot_number: int) -> void:
	match slot_number:
		1: skill_1.activate()
		2: skill_2.activate()
		3: skill_3.activate()


func _process(delta: float) -> void:
	if cast_bar.visible:
		cast_bar.value += delta


func handle_ability_activated(_ability: Ability, _event: ActivationEvent) -> void:
	pass


func handle_cast_started(ability: ActiveSkill) -> void:
	cast_bar.show()
	cast_bar.max_value = ability.cast_time
	cast_bar.value = 0


func handle_cast_ended(_ability: ActiveSkill, _success: bool) -> void:
	cast_bar.hide()


func handle_ability_granted(_skill: ActiveSkill) -> void:
	if skill_1.ability == null:
		skill_1.ability = _skill
	elif skill_2.ability == null:
		skill_2.ability = _skill
	elif skill_3.ability == null:
		skill_3.ability = _skill
	else:
		printerr("Adding too many abilities!")

func handle_ability_revoked(_skill: ActiveSkill) -> void:
	if skill_1.ability == _skill:
		skill_1.ability = null
	elif skill_2.ability == _skill:
		skill_2.ability = null
	elif skill_3.ability == _skill:
		skill_3.ability = null
	else:
		printerr("Trying to revoke non existent ability!")

func handle_cooldown_started(ability: ActiveSkill) -> void:
	if skill_1.ability == ability:
		skill_1.start_cooldown()
	elif skill_2.ability == ability:
		skill_2.start_cooldown()
	elif skill_3.ability == ability:
		skill_3.start_cooldown()

func handle_cooldown_ended(ability: ActiveSkill) -> void:
	pass


func setup_ability_container(ability_container: AbilityContainer) -> void:
	print(ability_container)
	for child: SelectedSkillButton in $SelectedSkills.get_children():
		child.ability_container = ability_container

	ability_container.ability_activated.connect(handle_ability_activated)
	ability_container.ability_granted.connect(handle_ability_granted)
	ability_container.ability_revoked.connect(handle_ability_revoked)
	ability_container.cooldown_started.connect(handle_cooldown_started)
	ability_container.cooldown_ended.connect(handle_cooldown_ended)
	ability_container.cast_started.connect(handle_cast_started)
	ability_container.cast_ended.connect(handle_cast_ended)


	# TODO: load player's selected abilities
	if ability_container.granted_abilities.size() > 0:
		skill_1.ability = ability_container.granted_abilities[0]
	
	if ability_container.granted_abilities.size() > 1:
		skill_2.ability = ability_container.granted_abilities[1]
	
	if ability_container.granted_abilities.size() > 2:
		skill_3.ability = ability_container.granted_abilities[2]


func setup_gameplay_attribute_map(gameplay_attribute_map: GameplayAttributeMap) -> void:
	const health_attribute_name: String = "health"
	const mana_attribute_name: String = "mana"

	gameplay_attribute_map.attribute_changed.connect(func (attribute_spec: AttributeSpec) -> void:
		match attribute_spec.attribute_name:
			health_attribute_name:
				_set_progress_bar(health, attribute_spec)
			mana_attribute_name:
				_set_progress_bar(mana, attribute_spec)
	)

	# initial setup
	_set_progress_bar(health, gameplay_attribute_map.get_attribute_by_name(health_attribute_name))
	_set_progress_bar(mana, gameplay_attribute_map.get_attribute_by_name(mana_attribute_name))


# func _ready() -> void:
# 	Globals.game_loaded.connect(
# 		func() -> void:
# 			await get_tree().process_frame
# 			skill_1.ability = skill_1.ability_container.granted_abilities[0]
# 	)
