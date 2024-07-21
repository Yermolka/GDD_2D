class_name PassiveTree extends Control

@export var available_points: int = 0:
	get:
		return available_points
	set(value):
		available_points = value
		update_buttons()

var buttons: Array[UnlockPassiveButton]
var player: Player:
	get:
		return get_tree().get_first_node_in_group("player")


func setup(player: Player) -> void:
	buttons.assign($Panel.get_children())
	for b: UnlockPassiveButton in buttons:
		b.unlock_passive_btn_pressed.connect(_handle_btn_pressed)

	update_buttons()
	visibility_changed.connect(func() -> void: update_buttons())
	player.level_changed.connect(
		func (value: int) -> void: 
			var total_spent: int = buttons.map(func (x: UnlockPassiveButton) -> bool: return x.passive.applied).count(true)
			available_points = value - total_spent
			update_buttons()
	)


func update_buttons() -> void:
	for b: UnlockPassiveButton in buttons:
		if not b.passive.applied:
			b.disabled = not (available_points > 0 and b.passive.can_activate(player))
		else:
			b.disabled = false
		

func _handle_btn_pressed(btn: UnlockPassiveButton) -> void:
	if btn.passive.applied:
		for b: UnlockPassiveButton in buttons:
			if b.passive.applied and btn.passive.ui_name in b.passive.required_passives:
				return
	
		btn.passive.deactivate(player)
		available_points += 1
		print("Deactivate ", btn.passive.ui_name)
	else:
		btn.passive.activate(player)
		available_points -= 1
		print("Activate ", btn.passive.ui_name)
