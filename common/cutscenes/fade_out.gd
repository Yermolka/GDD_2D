extends CanvasLayer

signal transition_begin
signal transition_finished
signal transition_to_black_finished


@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
    color_rect.visible = false
    anim_player.animation_finished.connect(
        func (anim_name: String) -> void:
            if anim_name == "fade_to_black":
                anim_player.play("fade_to_normal")
                transition_to_black_finished.emit()
            elif anim_name == "fade_to_normal":
                color_rect.visible = false
                transition_finished.emit()
    )


func transition() -> void:
    transition_begin.emit()
    color_rect.visible = true
    anim_player.play("fade_to_black")
