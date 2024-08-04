@tool
class_name SkillTreeEditorView extends Control

const skill_tree_nodes = [
    {label = "Skill", scene = preload("res://addons/skilltreeeditor/skill_node/skill_root_node.tscn")},
    {label = "Skill Upgrade", scene = preload("res://addons/skilltreeeditor/skill_node/skill_middle_node.tscn")},
    {label = "Passive", scene = null}
]


@onready var skill_graph_editor: SkillGraphEditor = %SkillGraph as SkillGraphEditor
@onready var new_button: Button = %NewButton as Button
@onready var open_button: Button = %OpenButton as Button
@onready var save_button: Button = %SaveButton as Button
@onready var add_skill_button: Button = %AddSkillButton as Button
@onready var save_file_dialog: FileDialog = $SaveFileDialog as FileDialog
@onready var load_file_dialog: FileDialog = $LoadFileDialog as FileDialog
@onready var add_node_popup_menu: PopupMenu = $AddNodePopupMenu as PopupMenu


var current_file_path: String = ""


func _ready() -> void:
    new_button.icon = get_theme_icon("New", "EditorIcons")
    open_button.icon = get_theme_icon("Load", "EditorIcons")
    save_button.icon = get_theme_icon("Save", "EditorIcons")
    add_skill_button.icon = get_theme_icon("Add", "EditorIcons")

    add_node_popup_menu.clear()
    for item in skill_tree_nodes:
        add_node_popup_menu.add_item(item.label)


func apply_changes() -> void:
    if skill_graph_editor.get_child_count() > 0:
        save_changes()


func save_changes() -> void:
    if current_file_path.is_empty():
        save_file_dialog.popup()
    else:
        save_file(current_file_path)


func save_file(path: String) -> void:
    var error := skill_graph_editor.save(path)
    if error == OK:
        current_file_path = path
        EditorInterface.get_resource_filesystem().scan()
        return

    printerr(error)


func load_file(path: String) -> void:
    skill_graph_editor.load(path)
    current_file_path = path


func load_resource(resource: SkillTreeData) -> void:
    load_file(resource.resource_path)


func _on_add_skill_button_pressed() -> void:
    skill_graph_editor.add_node(skill_tree_nodes[0].scene.instantiate(), skill_graph_editor.get_local_mouse_position())


func _on_add_arrow_button_pressed() -> void:
    skill_graph_editor.add_node(skill_tree_nodes[1].scene.instantiate(), skill_graph_editor.get_local_mouse_position())


func _on_popup_menu_index_pressed(index:int) -> void:
    skill_graph_editor.add_node(skill_tree_nodes[index].scene.instantiate(), skill_graph_editor.get_local_mouse_position())


func _on_new_button_pressed() -> void:
    skill_graph_editor.clear()
    current_file_path = ""


func _on_skill_graph_popup_request(position:Vector2) -> void:
    add_node_popup_menu.popup_on_parent(Rect2(get_global_mouse_position(), Vector2.ZERO))


func _on_save_file_dialog_file_selected(path:String) -> void:
    save_file(path)


func _on_save_button_pressed() -> void:
    save_changes()


func _on_load_file_dialog_file_selected(path:String) -> void:
    load_file(path)


func _on_open_button_pressed() -> void:
    load_file_dialog.popup()
