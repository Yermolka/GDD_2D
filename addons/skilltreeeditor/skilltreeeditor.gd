@tool
extends EditorPlugin

const SkillTreeEditor = preload("res://addons/skilltreeeditor/skill_tree_editor.tscn")

var editor


func _enter_tree() -> void:
    editor = preload("res://addons/skilltreeeditor/skill_tree_editor.tscn").instantiate()

    get_editor_interface().get_editor_main_screen().add_child(editor)
    
    get_undo_redo()


func _exit_tree() -> void:
    if is_instance_valid(editor):
        editor.queue_free()


func _has_main_screen() -> bool:
    return true


func _make_visible(visible: bool) -> void:
    if is_instance_valid(editor):
        editor.visible = visible


func _get_plugin_name() -> String:
    return 'SkillTreeEditor'


# func _handles(object: Object) -> bool:
#     return object is SkillTreeData


# func _edit(object: Object) -> void:
#     if object is SkillTreeData and is_instance_valid(editor):
#         editor.files.open_file(object.resource_path)


# func _save_external_data() -> void:
#     if is_instance_valid(editor):
#         editor.files.save_all()
