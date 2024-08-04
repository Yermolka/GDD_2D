@tool
class_name SelectedSkillButton extends TextureButton

@export_category("Skill button")
@export var ability: ActiveSkill = null:
	get:
		return ability
	set(value):
		ability = value
		draw_ability()
		
@export_enum("1", "2", "3", "4", "5", "_movement") var skill_number: String = "1"


@onready var label: Label = $Label
@onready var time_label: Label = $Counter/Value
@onready var timer: Timer = $Sweep/Timer
@onready var cd_bar: TextureProgressBar = $Sweep
var ability_container: AbilityContainer:
	get:
		return ability_container
	set(value):
		ability_container = value
		ability_container.gcd_started.connect(_handle_gcd)

func _on_pressed() -> void:
	activate()


func _handle_gcd(time: float) -> void:
	if ability != null and ability.tags_block.has("gcd"):
		if timer.is_stopped():
			start_cooldown(time)
		elif timer.time_left < time:
			timer.start(time)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var events: Array[InputEvent] = InputMap.action_get_events("ability" + skill_number)
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
		if ability != null:
			texture_normal = ability.ui_icon
	)
	

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		label.text = str(skill_number)
		draw_ability()
	else:
		if not timer.is_stopped() and ability != null:
			time_label.text = "%3.1f" % timer.time_left
			cd_bar.value = int((timer.time_left / timer.wait_time) * 100)
		if Input.is_action_just_pressed("ability" + skill_number):
			activate()


func activate() -> void:
	if ability != null and ability_container != null:
		ability_container.activate_one(ability)


func draw_ability() -> void:
	if ability != null:
		texture_normal = ability.ui_icon
		cd_bar.texture_progress = texture_normal
		cd_bar.value = 0
	else:
		texture_normal = null


func start_cooldown(time: float) -> void:
	time_label.show()
	timer.start(time)
	disabled = true
	texture_normal = null
