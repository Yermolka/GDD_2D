class_name SettingsScreen extends Control


@export var buttons_container: Control
var selected_button: KeybindButton

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()
	for btn: KeybindButton in buttons_container.get_children():
		btn.keybind_button_pressed.connect(handle_keybind_btn_pressed)
		var events: Array[InputEvent] = InputMap.action_get_events(btn.action_name)
		if events.size() > 0:
			if events[0] is InputEventKey:
				btn.text = events[0].as_text_physical_keycode()
			else:
				if events[0].button_index == MOUSE_BUTTON_LEFT:
					btn.text = "LMB"
				elif events[0].button_index == MOUSE_BUTTON_RIGHT:
					btn.text = "RMB"
				elif events[0].button_index == MOUSE_BUTTON_MIDDLE:
					btn.text = "MMB"
		else:
			btn.text = ""

	Globals.game_loaded.connect(_load_keybinds)


func _load_keybinds() -> void:
	for key: String in Globals.keybinds:
		InputMap.action_erase_events(key)
		var e: InputEvent
		if Globals.keybinds[key] == null:
			for btn: KeybindButton in buttons_container.get_children():
				if btn.action_name == key:
					btn.text = "UNBOUND"
					Globals.keybind_changed.emit(btn.action_name, null)
			continue

		if Globals.keybinds[key]["type"] == "key":
			e = InputEventKey.new()
			e.physical_keycode = Globals.keybinds[key]["btn"]
			e.pressed = true
			InputMap.action_add_event(key, e)
		else:
			e = InputEventMouseButton.new()
			e.button_index = Globals.keybinds[key]["btn"]
			e.pressed = true
			InputMap.action_add_event(key, e)
		for btn: KeybindButton in buttons_container.get_children():
			if btn.action_name == key:
				if Globals.keybinds.get(key) != null:
					Globals.keybind_changed.emit(btn.action_name, e)
					if e is InputEventKey:
						btn.text = e.as_text_physical_keycode()
					else:
						if e.button_index == MOUSE_BUTTON_LEFT:
							btn.text = "LMB"
						elif e.button_index == MOUSE_BUTTON_RIGHT:
							btn.text = "RMB"
						elif e.button_index == MOUSE_BUTTON_MIDDLE:
							btn.text = "MMB"
				else:
					btn.text = "UNBOUND"


func handle_keybind_btn_pressed(btn: KeybindButton) -> void:
	selected_button = btn


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		var closed_ui: bool = false
		for c: Node in get_parent().get_children():
			if c is DialogueBox and c.visible:
				break

			if c.get_script() == null or c is InGameBar:
				continue

			if c == self:
				continue
			
			if c.visible:
				c.visible = false
				closed_ui = true
			
		if closed_ui:
			return

		if selected_button == null:
			_toggle()
		else:
			selected_button = null
	elif event is InputEventKey and event.pressed and selected_button != null:
		event = event as InputEventKey

		InputMap.action_erase_events(selected_button.action_name)
		InputMap.action_add_event(selected_button.action_name, event)
		Globals.keybind_changed.emit(selected_button.action_name, event)

		selected_button.text = event.as_text_physical_keycode()
		_update_keybind_buttons(event)
		Globals.keybinds[selected_button.action_name] = {"type": "key", "btn": event.physical_keycode}
		selected_button = null
	elif event is InputEventMouseButton and event.pressed and selected_button != null:
		event = event as InputEventMouseButton

		InputMap.action_erase_events(selected_button.action_name)
		InputMap.action_add_event(selected_button.action_name, event)
		Globals.keybind_changed.emit(selected_button.action_name, event)

		if event.button_index == MOUSE_BUTTON_LEFT:
			selected_button.text = "LMB"
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			selected_button.text = "RMB"
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			selected_button.text = "MMB"
		_update_keybind_buttons(event)
		Globals.keybinds[selected_button.action_name] = {"type": "mouse", "btn": event.button_index}
		selected_button = null


func _update_keybind_buttons(event: InputEvent) -> void:
	for btn: KeybindButton in buttons_container.get_children():
		if btn == selected_button:
			continue

		var btn_events: Array[InputEvent] = InputMap.action_get_events(btn.action_name)
		if btn_events.size() == 0:
			continue

		var input_event: InputEvent = btn_events[0]
		if not (event is InputEventKey and input_event is InputEventKey or event is InputEventMouseButton and input_event is InputEventMouseButton):
			continue

		if event is InputEventKey and input_event.physical_keycode == event.physical_keycode:
			InputMap.action_erase_events(btn.action_name)
			btn.text = "UNBOUND"
			Globals.keybinds[btn.action_name] = null
			Globals.keybind_changed.emit(selected_button.action_name, event)
		elif event is InputEventMouseButton and input_event.button_index == event.button_index:
			InputMap.action_erase_events(btn.action_name)
			btn.text = "UNBOUND"
			Globals.keybinds[btn.action_name] = null
			Globals.keybind_changed.emit(selected_button.action_name, event)


func _on_close_button_pressed() -> void:
	_toggle()


func _toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		mouse_filter = Control.MOUSE_FILTER_PASS
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
