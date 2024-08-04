@tool
class_name SkillMiddleNode extends SkillNode

var requirements: int = 0
var unlocks: int = 0
var skill: GDDSkill:
    set(value):
        skill = value
        %SkillName.text = value.ui_name
        %SkillIcon.texture = value.ui_icon

func _on_add_unlock_button_pressed() -> void:
    var unlock_label: Label = Label.new()
    unlock_label.text = "SkillName"
    add_child(unlock_label)
    unlocks += 1

    set_slot(3 + requirements + unlocks, false, 0, Color.WHITE, true, 0, Color.GREEN)


func _on_add_requirement_button_pressed() -> void:
    var requirement_label: Label = Label.new()
    requirement_label.text = "SkillName"
    add_child(requirement_label)

    # move label right before unlock container
    move_child(requirement_label, %UnlockContainer.get_index())
    requirements += 1

    set_slot(2 + requirements, true, 0, Color.RED, false, 0, Color.GREEN)

    if unlocks > 0:
        set_slot(%UnlockContainer.get_index() - 1, false, 0, Color.RED, false, 0, Color.GREEN)
        set_slot(get_child_count() - 2, false, 0, Color.RED, true, 0, Color.GREEN)


func _on_load_skill_dialog_file_selected(path:String) -> void:
    var resource: Resource = load(path)
    if resource is GDDSkill:
        print_debug("loaded ", resource.ui_name)
        skill = resource


func _on_select_skill_button_pressed() -> void:
    %LoadSkillDialog.show()


func _on_remove_unlock_button_pressed() -> void:
    if unlocks > 0:
        remove_child(get_children().back())
        unlocks -= 1


func _on_remove_requirement_button_pressed() -> void:
    if requirements > 0:
        remove_child(get_child(%UnlockContainer.get_index() - 1))
        requirements -= 1

        set_slot(%UnlockContainer.get_index() - 1, false, 0, Color.RED, false, 0, Color.GREEN)

        if unlocks > 0:
            set_slot(%UnlockContainer.get_index(), false, 0, Color.RED, false, 0, Color.GREEN)
            set_slot(get_child_count() - 2, false, 0, Color.RED, true, 0, Color.GREEN)

