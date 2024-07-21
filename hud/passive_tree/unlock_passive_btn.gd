@tool
class_name UnlockPassiveButton extends TextureButton

signal unlock_passive_btn_pressed(btn: UnlockPassiveButton)

@export var passive: PassiveSkill:
	get:
		return passive
	set(value):
		passive = value
		if passive == null:
			texture_normal = null
		else:
			texture_normal = passive.ui_icon
			_update_arrows()

@onready var arrows: Array = get_children()


func _ready() -> void:
	pressed.connect(
		func () -> void:
			unlock_passive_btn_pressed.emit(self)
	)
	passive.applied_changed.connect(_update_arrows)


func _update_arrows() -> void:
	if Engine.is_editor_hint():
		return
		
	if passive.applied:
		arrows.map(func (x: UITreeArrow) -> void: x.texture = x.active_texture)
	else:
		arrows.map(func (x: UITreeArrow) -> void: x.texture = x.not_active_texture)
