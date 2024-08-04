@tool
class_name SkillNode extends GraphNode


@export var label_color: Color = Color.WHITE


var id: String
var has_loaded_position: float = false


func _ready() -> void:
    var title_label: Label = get_titlebar_hbox().get_children()[0]
    title_label.add_theme_color_override("font_color", label_color)

    var delete_button: Button = Button.new()
    var node_name_array: Array[StringName] = [name]
    delete_button.icon = get_theme_icon("Close", "EditorIcons")
    delete_button.pressed.connect(get_parent()._on_delete_nodes_request.bind(node_name_array))
    delete_button.size_flags_horizontal = SIZE_SHRINK_END
    get_titlebar_hbox().add_child(delete_button)


func get_number_from_string(text: String) -> int:
    return absi(hash(text))


func load_resource(path: String) -> void:
    pass
