class_name CutsceneScript extends Resource

enum ACTIONS {
    CAMERA_SET_POS,
    CAMERA_MOVE_TO,
    CAMERA_MOVE_BY,
    WAIT_CAMERA_MOVE_FINISHED,
    CAMERA_SET_LOOK_AT,
    FADE_OUT,
    WAIT_FADE_TO_BLACK,
    WAIT_FADE_FINISHED,
    SHOW_DIALOG,
    WAIT_DIALOG_FINISHED,
    WAIT_TIME,
}

@export var action_list: Array[CutsceneScriptAction]
