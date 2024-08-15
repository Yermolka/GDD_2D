extends Node3D


func _ready() -> void:
    await get_tree().physics_frame

    var q: QuestResource = load("res://quests/dungeon-01-quest.tres")
    q = q.instantiate()
    Questify.register_quest(q)
    Questify.start_quest(q)

    print(Questify.get_active_quests(), q)

    # CutsceneScriptManager.start_cutscene(load("res://common/cutscenes/action_scripts/test_cutscene.tres"))
    Globals.last_save_position = $SpawnPoint.global_position
    ($BossArea1/MeshInstance3D/StaticBody3D as StaticBody3D).process_mode = Node.PROCESS_MODE_DISABLED
    $Player.death.connect(func () -> void: ($BossArea1/MeshInstance3D/StaticBody3D as StaticBody3D).process_mode = Node.PROCESS_MODE_DISABLED)


func _on_boss_area_1_body_entered(body:Node3D) -> void:
    if body is Player:
        ($BossArea1/MeshInstance3D/StaticBody3D as StaticBody3D).process_mode = PROCESS_MODE_INHERIT
