class_name SkillTreeData extends Resource

### {id, position, connections_to[], skill: path}
@export var nodes: Array[Dictionary] = []

### {from_port, from_node, to_port, to_node}
@export var connections: Array[Dictionary] = []

# IDs of nodes
@export var learned_skills: Array[int] = []

