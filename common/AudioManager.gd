extends Node


func _ready() -> void:
    for i in range(20):
        var instance: AudioStreamPlayer = AudioStreamPlayer.new()
        add_child(instance)


func play_sound(stream: AudioStream) -> void:
    if stream == null:
        return
        
    var instance := _free_instance()
    instance.stream = stream
    instance.play()


func _free_instance() -> AudioStreamPlayer:
    for c: AudioStreamPlayer in get_children():
        if not c.playing:
            return c

    var instance: AudioStreamPlayer = AudioStreamPlayer.new()
    add_child(instance)
    return instance
    