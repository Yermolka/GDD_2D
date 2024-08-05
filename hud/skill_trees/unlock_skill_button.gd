@tool
class_name UnlockSkillButton extends TextureButton

signal unlock_skill_btn_pressed(btn: UnlockSkillButton)

@export var skill: GDDSkill:
    get:
        return skill
    set(value):
        skill = value
        if skill == null:
            texture_normal = null
        else:
            texture_normal = skill.ui_icon
            _update_tooltip()
            _update_arrows()
@export var upgrade: GDDSkillUpgrade:
    get:
        return upgrade
    set(value):
        upgrade = value
        if upgrade == null:
            texture_normal = null
        else:
            texture_normal = upgrade.ui_icon
            _update_tooltip()
            _update_arrows()
@onready var arrows: Array = get_children()
var player: Player:
    get:
        return get_tree().get_first_node_in_group("player")
var __setup: bool = true


func _ready() -> void:
    pressed.connect(
        func() -> void:
            if skill:
                print(skill.ui_name)
            else:
                print(upgrade.ui_name)
            unlock_skill_btn_pressed.emit(self)
    )
    __setup = false


func _update_arrows() -> void:
    if Engine.is_editor_hint() or __setup:
        return

    if skill in player.ability_container.granted_abilities:
        arrows.map(func (x: UITreeArrow) -> void: x.texture = x.active_texture)
    else:
        arrows.map(func (x: UITreeArrow) -> void: x.texture = x.not_active_texture)


func _update_tooltip() -> void:
    if skill or upgrade:
        tooltip_text = "1"
    else:
        tooltip_text = ""


func set_disable(value: bool) -> void:
    disabled = value
    if disabled:
        $Unavailable.show()
        $Available.hide()
    else:
        $Unavailable.hide()
        $Available.show()


func _make_custom_tooltip(for_text: String) -> Object:
    var new_tooltip: SpellTooltip = load("res://hud/in_game_bar/spell_tooltip.tscn").instantiate()
    new_tooltip.visible = true
    if skill:
        new_tooltip.set_spell(skill)
    elif upgrade:
        new_tooltip.set_upgrade(upgrade)
    return new_tooltip
