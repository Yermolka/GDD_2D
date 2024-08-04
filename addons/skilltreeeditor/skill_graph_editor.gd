@tool
class_name SkillGraphEditor extends GraphEdit


### Util ###

const ALPHABET := "useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict"
const DEFAULT_LENGTH := 21


func generate(length := DEFAULT_LENGTH) -> String:
    var id: String = ""
    for i in range(length):
        id += ALPHABET[randi() % ALPHABET.length()]
    return id

######


var load_requestor: SkillNode
var loaded_resource: SkillTreeData = null


func add_node(new_node: SkillNode, position_offset: Vector2) -> void:
    if new_node.id.is_empty():
        new_node.id = generate(10)
    new_node.position_offset = position_offset
    if not new_node.has_loaded_position:
        new_node.position_offset += scroll_offset
        new_node.position_offset /= zoom
    add_child(new_node)


func _on_connection_request(from_node:StringName, from_port:int, to_node:StringName, to_port:int) -> void:
    print("Connection request: %s %d to %s %d" % from_node, from_port, to_node, to_port)
    connect_node(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node:StringName, from_port:int, to_node:StringName, to_port:int) -> void:
    disconnect_node(from_node, from_port, to_node, to_port)


func _on_delete_nodes_request(nodes:Array[StringName]) -> void:
    var connections := get_connection_list()
    var connections_to_remove: Array[Dictionary] = []
    var nodes_to_remove: Array[SkillNode] = []

    for node in nodes:
        connections_to_remove.append_array(connections.filter(
            func(connection): return connection.from_node == node or connection.to_node == node
        ))
        nodes_to_remove.append(get_node(NodePath(node)))

    _delete_nodes(nodes_to_remove, connections_to_remove)
    

func _delete_nodes(nodes: Array[SkillNode], connections: Array[Dictionary]) -> void:
    for connection in connections:
        disconnect_node(connection.from_node, connection.from_port, connection.to_node, connection.to_port)
    for node in nodes:
        node.selected = false
        remove_child(node)


func remove_node_connections(node: StringName) -> void:
    var connections := get_connection_list()
    var connections_to_remove: Array[Dictionary] = []

    connections_to_remove.append_array(connections.filter(
        func(connection): return connection.from_node == node or connection.to_node == node
    ))
    
    _delete_nodes([], connections_to_remove)


func request_file_load(node: SkillNode) -> void:
    load_requestor = node
    %LoadSkillDialog.show()


func _on_load_skill_dialog_file_selected(path: String) -> void:
    load_requestor.load_resource(path)
    load_requestor = null


func clear() -> void:
    clear_connections()
    for child in get_children():
        child.queue_free()


func save(path: String) -> int:
    var data := _serialize_nodes()
    if data != null:
        var error := ResourceSaver.save(data, path)
        return error
        
    return ERR_CANT_CREATE


func _serialize_nodes() -> SkillTreeData:
    var nodes := get_children()
    var connections := get_connection_list()

    var nodes_data: Array[Dictionary] = []
    var position_offset := Vector2.ZERO
    position_offset.x = INF
    
    for node: SkillRootNode in nodes:
        position_offset.x = min(position_offset.x, node.position.x)
        position_offset.y = max(position_offset.y, node.position.y)

    for node: SkillRootNode in nodes:
        var data := SkillData.new()
        data.id = node.id
        data.position = node.position - position_offset
        data.graph_editor_position = node.position
        data.graph_editor_size = node.size
        data.skill = node.skill
        data.node_name = node.name
        data.connections_to.assign(connections.filter(
            func(connection) -> bool: return connection.from_node == node.name
        ).map(func(connection) -> String: return get_node(NodePath(connection.to_node)).id))

        nodes_data.append(data.serialize())

    var skill_tree_data := SkillTreeData.new()
    skill_tree_data.nodes = nodes_data
    skill_tree_data.connections = connections

    return skill_tree_data
    

func load(path: String) -> SkillTreeData:
    var resource := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
    load_resource(resource)
    loaded_resource = resource
    return resource


func load_resource(resource: SkillTreeData) -> void:
    _deserialize_resource(resource)


func _deserialize_resource(resource: SkillTreeData) -> void:
    clear()
    var node_names: Dictionary = {}

    for node in resource.nodes:
        var graph_node := load("res://addons/skilltreeeditor/skill_node/skill_root_node.tscn").instantiate() as SkillRootNode
        graph_node.id = node.id
        graph_node.position = node.graph_editor_position
        add_node(graph_node, node.graph_editor_position)
        graph_node.size = node.graph_editor_size
        graph_node.load_resource(node.skill)
        node_names[node.node_name] = graph_node.name

    for conn in resource.connections:
        connect_node(node_names[conn.from_node], conn.from_port, node_names[conn.to_node], conn.to_port)

