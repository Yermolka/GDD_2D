@tool
class_name SkillRootNode extends SkillNode

var unlocks: int = 0
var requirements: int = 0
var skill: Resource:
    set(value):
        skill = value
        if value:
            %SkillName.text = value.ui_name
            %SkillIcon.texture = value.ui_icon
        else:
            %SkillName.text = "SkillName"
            %SkillIcon.texture = null

var skill_grant_tag: String


func load_resource(path: String) -> void:
    var resource: Resource = load(path)
    if resource is GDDSkill or resource is GDDSkillUpgrade:
        get_parent().remove_node_connections(name)
        print_debug("loaded ", resource.ui_name)
        skill = resource

        clear_all_slots()
        for i in range(unlocks):
            remove_child(get_children()[-1])
        
        for i in range(requirements):
            remove_child(get_children()[-1])

        unlocks = 0
        requirements = 0

        # Generate requirement ports
        for tag: String in resource.grant_tags_required:
            if tag.begins_with("ability.") or tag.begins_with("upgrade."):
                var requirement_label: Label = Label.new()
                requirement_label.text = tag.split(".", true, 1)[1]
                add_child(requirement_label)
                requirements += 1

                var idx: int = get_child_count() - 1
                # set_slot(idx, true, get_number_from_string(requirement_label.text), Color.RED, false, 0, Color.GREEN)
                set_slot(idx, true, 0, Color.RED, false, 0, Color.GREEN)

        # Generate output ports
        for tag: String in resource.grant_tags:
            if tag.begins_with("ability.") or tag.begins_with("upgrade."):
                skill_grant_tag = tag.split(".", true, 1)[1]
                var unlock_label: Label = Label.new()
                unlock_label.text = skill_grant_tag
                add_child(unlock_label)
                unlocks += 1

                var idx: int = get_child_count() - 1
                # set_slot(idx, false, 0, Color.RED, true, get_number_from_string(skill_grant_tag), Color.GREEN)
                set_slot(idx, false, 0, Color.RED, true, 0, Color.GREEN)
      

func _on_select_skill_button_pressed() -> void:
    get_parent().request_file_load(self)
