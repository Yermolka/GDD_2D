@tool
class_name SelectedSkillButton extends TextureButton

@export_category("Skill button")
@export var ability: ActiveSkill = null:
	get:
		return ability
	set(value):
		ability = value
		draw_ability()
		
@export_range(1, 4) var skill_number: int = 1


@onready var label: Label = $Label
@onready var time_label: Label = $Counter/Value
@onready var timer: Timer = $Sweep/Timer
@onready var cd_bar: TextureProgressBar = $Sweep
var ability_container: AbilityContainer

func _on_pressed() -> void:
	activate()


func _ready() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events("ability" + str(skill_number))
	if events.size() > 0:
		label.text = events[0].as_text().split(" ")[0]
	else:
		label.text = ""
	Globals.keybind_changed.connect(
		func (action_name: StringName, event: InputEvent) -> void:
			if action_name == "ability" + str(skill_number):
				if event != null:
					if event is InputEventKey:
						label.text = event.as_text_physical_keycode()
					else:
						if event.button_index == MOUSE_BUTTON_LEFT:
							label.text = "LMB"
						elif event.button_index == MOUSE_BUTTON_RIGHT:
							label.text = "RMB"
						elif event.button_index == MOUSE_BUTTON_MIDDLE:
							label.text = "MMB"
				else:
					label.text = ""
	)
	pressed.connect(_on_pressed)
	time_label.hide()
	timer.timeout.connect(func () -> void:
		cd_bar.value = 0
		time_label.hide()
		disabled = false
		texture_normal = ability.ui_icon
	)
	

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		label.text = str(skill_number)
		draw_ability()
	else:
		if not timer.is_stopped():
			time_label.text = "%3.1f" % timer.time_left
			cd_bar.value = int((timer.time_left / ability.cooldown_duration) * 100)
		if Input.is_action_just_pressed("ability" + str(skill_number)):
			activate()


func activate() -> void:
	if ability != null and ability_container != null:
		if ability is TargetedSkill:
			ability.set_target(get_tree().get_first_node_in_group("selected"))
		ability_container.activate_one(ability)


func draw_ability() -> void:
	if ability != null:
		texture_normal = ability.ui_icon
		cd_bar.texture_progress = texture_normal
		cd_bar.value = 0
	else:
		texture_normal = null


func start_cooldown() -> void:
	time_label.show()
	timer.start(ability.cooldown_duration)
	disabled = true
	texture_normal = null
