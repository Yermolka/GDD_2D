extends Node


signal cutscene_started
signal cutscene_finished

@onready var camera: CutsceneCamera = $CutsceneCamera


# func _ready() -> void:
#     FadeOut.transition()


func start_cutscene(scr: CutsceneScript) -> void:
    var old_camera: Camera3D = get_viewport().get_camera_3d()
    camera.current = true
    cutscene_started.emit()

    for action: CutsceneScriptAction in scr.action_list:
        await _process_action(action)

    cutscene_finished.emit()
    old_camera.current = true


func _process_action(action: CutsceneScriptAction) -> void:
    await get_tree().physics_frame


    print(action.action)
    match action.action:
        CutsceneScript.ACTIONS.CAMERA_SET_POS:
            camera.global_position = action.param_vector
        CutsceneScript.ACTIONS.CAMERA_MOVE_TO:
            if action.param_float != -1.0:
                camera.move_to(action.param_vector, action.param_float)
            else:
                camera.move_to(action.param_vector)
        CutsceneScript.ACTIONS.CAMERA_MOVE_BY:
            if action.param_float != -1.0:
                camera.move_by(action.param_vector, action.param_float)
            else:
                camera.move_by(action.param_vector)
        CutsceneScript.ACTIONS.WAIT_CAMERA_MOVE_FINISHED:
            if camera.process_mode != PROCESS_MODE_DISABLED:
                await camera.movement_finished
        CutsceneScript.ACTIONS.CAMERA_SET_LOOK_AT:
            camera.set_look_at(action.param_vector)
        CutsceneScript.ACTIONS.FADE_OUT:
            FadeOut.transition()
        CutsceneScript.ACTIONS.WAIT_FADE_TO_BLACK:
            await FadeOut.transition_to_black_finished
        CutsceneScript.ACTIONS.WAIT_FADE_FINISHED:
            await FadeOut.transition_finished
        CutsceneScript.ACTIONS.SHOW_DIALOG:
            pass
        CutsceneScript.ACTIONS.WAIT_DIALOG_FINISHED:
            pass
