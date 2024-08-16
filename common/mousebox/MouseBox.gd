class_name MouseBox extends Area3D


var center_point: Vector3:
    get:
        return $CollisionShape3D.global_position


@export var meshes_to_highlight: Array[MeshInstance3D] = []
var shader_materials: Array[ShaderMaterial] = []


func _ready() -> void:
    for m: MeshInstance3D in meshes_to_highlight:
        var mat: Material = m.mesh.surface_get_material(0)
        while mat != null:
            if mat is ShaderMaterial and (mat as ShaderMaterial).shader.resource_path.contains("outline.gdshader"):
                (mat as ShaderMaterial).set_shader_parameter("outline_width", 0.0)
                shader_materials.append(mat)

            mat = mat.next_pass

    print("FOUND ", shader_materials.size(), " SHADERS")


func _on_mouse_entered() -> void:
    for m: ShaderMaterial in shader_materials:
        m.set_shader_parameter("outline_width", 1.0)


func _on_mouse_exited() -> void:
    for m: ShaderMaterial in shader_materials:
        m.set_shader_parameter("outline_width", 0.0)
