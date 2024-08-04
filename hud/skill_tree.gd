class_name SkillTree extends Control


@export var data: SkillTreeData = null:
    get:
        return data
    set(value):
        data = value
        _create_nodes()
        _draw_items()
var ability_container: AbilityContainer = null
@export var available_points: int = 0:
    get:
        return available_points
    set(value):
        available_points = value
        _draw_items()
        if points_label:
            points_label.text = str(available_points)
@onready var skill_tree_slot: PackedScene = preload("res://hud/skill_tree_node.tscn")
@onready var points_label: Label = $Points
@onready var panel: Panel = $Panel
@onready var btn_scene: PackedScene = load("res://hud/skill_trees/unlock_skill_button.tscn")
var player: Player:
    get:
        return get_tree().get_first_node_in_group("player")


func _ready() -> void:
    visibility_changed.connect(_draw_items)
    hide()

    await get_tree().physics_frame

    var player: Player = get_tree().get_first_node_in_group("player")
    for eqb: EquipmentBase in player.equipment.equipped_items:
        if eqb is Weapon:
            data = eqb.skill_tree
            available_points = eqb.skill_points


func _create_nodes() -> void:
    for c: Node in panel.get_children():
        panel.remove_child(c)
        c.queue_free()

    for node in data.nodes:
        var btn := btn_scene.instantiate() as UnlockSkillButton
        panel.add_child(btn)
        var res := load(node.skill)
        if res is GDDSkill:
            btn.skill = res
        else:
            btn.upgrade = res
        
        btn.position = node.position
        btn.position.y += panel.size.y - btn.size.y
        btn.unlock_skill_btn_pressed.connect(_handle_btn_pressed)

    # TODO: Add arrows
    update_buttons()
    var weapon: Weapon = player.equipment.slots.filter(func (x: EquipmentSlot) -> bool: return x.name == "weapon")[0].equipped
    available_points = weapon.skill_points
	

func update_buttons() -> void:
    for b: UnlockSkillButton in panel.get_children():
        if b.skill:
            if player.ability_container.granted_abilities.has(b.skill):
                b.disabled = false
            else:
                b.disabled = not (available_points > 0 and player.ability_container.can_grant(b.skill))

            if not b.disabled:
                print("Can click ", b.skill.ui_name)
            else:
                print("Can not click ", b.skill.ui_name)
        else:
            b.disabled = not (available_points > 0 and b.upgrade.unlocked(player.ability_container))
            if not b.disabled:
                print("Can click ", b.upgrade.ui_name)
            else:
                print("Can not click ", b.upgrade.ui_name)

        

func _draw_items() -> void:
    if not visible:
        return

    if not data:
        return

    update_buttons()
	

func can_remove_upgrade(_upgrade: GDDSkillUpgrade) -> bool:
    for tier: SkillTreeTierData in data.tiers:
        for upgrade: GDDSkillUpgrade in tier.skills:
            if not upgrade.learned:
                continue
                
            for tag: String in _upgrade.grant_tags:
                if upgrade.grant_tags_required.has(tag):
                    return false
    return true


func _handle_btn_pressed(btn: UnlockSkillButton) -> void:
    print("Pressed ", btn)
    if btn.skill:
        if player.ability_container.granted_abilities.has(btn.skill):
            for b: UnlockSkillButton in panel.get_children():
                if b.skill and player.ability_container.granted_abilities.has(b.skill):
                    for tag: String in b.skill.grant_tags_required:
                        if tag in btn.skill.grant_tags:
                            return
                elif b.upgrade and b.upgrade.learned:
                    for tag: String in b.upgrade.grant_tags_required:
                        if tag in btn.skill.grant_tags:
                            return

            player.ability_container.revoke(btn.skill)
            available_points += 1
            print("Unlearned ", btn.skill.ui_name)
        else:
            player.ability_container.grant(btn.skill)
            available_points -= 1
            print("Learned ", btn.skill.ui_name)
    else:
        if btn.upgrade.learned:
            for b: UnlockSkillButton in panel.get_children():
                if b.skill and player.ability_container.granted_abilities.has(b.skill):
                    for tag: String in b.skill.grant_tags_required:
                        if tag in btn.upgrade.grant_tags:
                            return
                elif b.upgrade and b.upgrade.learned:
                    for tag: String in b.upgrade.grant_tags:
                        if tag in b.upgrade.grant_tags_required:
                            if tag in btn.upgrade.grant_tags:
                                return

            btn.upgrade.remove(player.ability_container)
            available_points += 1
            print("Unlearned upgrade ", btn.upgrade)
        else:
            btn.upgrade.apply(player.ability_container)
            available_points -= 1
            print("Learned upgrade ", btn.upgrade.ui_name)
    _draw_items()


func setup_ability_container(ac: AbilityContainer) -> void:
    ability_container = ac


func _handle_skill_points_changed(value: int) -> void:
    available_points = value
    update_buttons()


func setup_equipment(eq: Equipment) -> void:
    eq.equipped.connect(
        func(_item: Item, _slot: EquipmentSlot) -> void:
            var item: Weapon = _item as Weapon
            if not item:
                return
            
            data = item.skill_tree
            available_points = item.skill_points

            if item.skill_points_changed.is_connected(_handle_skill_points_changed):
                item.skill_points_changed.disconnect(_handle_skill_points_changed)
            item.skill_points_changed.connect(_handle_skill_points_changed)
    )

    eq.unequipped.connect(
        func(_item: Item, _slot: EquipmentSlot) -> void:
            var item: Weapon = _item as Weapon
            if not item:
                return

            data = null
            available_points = 0

            if item.skill_points_changed.is_connected(_handle_skill_points_changed):
                item.skill_points_changed.disconnect(_handle_skill_points_changed)
    )


func _on_close_button_pressed() -> void:
    visible = false
