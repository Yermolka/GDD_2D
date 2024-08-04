class_name SkillData extends Resource


var id: String
var node_name: StringName
var position: Vector2
var graph_editor_position: Vector2
var graph_editor_size: Vector2
var connections_to: Array[String]

### GDDSkill or GDDSkillUpgrade
var skill: Resource 


func serialize() -> Dictionary:
    return {
        "id": id,
        "position": position,
        "graph_editor_position": graph_editor_position,
        "graph_editor_size": graph_editor_size,
        "connections_to": connections_to,
        "skill": skill.resource_path,
        "node_name": node_name,
    }


func deserialize(data: Dictionary) -> void:
    id = data.id
    position = data.position
    connections_to = data.connections_to
    skill = load(data.skill)
    graph_editor_position = data.graph_editor_position
    graph_editor_size = data.graph_editor_size
    node_name = data.node_name
