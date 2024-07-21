class_name KeybindButton extends Button

@export var action_name: StringName
signal keybind_button_pressed(btn: KeybindButton)

func _ready() -> void:
	pressed.connect(func () -> void: keybind_button_pressed.emit(self))
