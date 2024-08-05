class_name SpellTooltip extends Control

@onready var spell_name: Label = $VBoxContainer/SpellName
@onready var spell_description: Label = $VBoxContainer/SpellDescription
@onready var spell_cast_time: Label = $VBoxContainer/HBoxContainer/SpellCastTime
@onready var spell_cd: Label = $VBoxContainer/HBoxContainer2/SpellCD
var spell: GDDSkill
var upgrade: GDDSkillUpgrade
var passive: PassiveSkill


func _ready() -> void:
    if spell:
        spell_name.text = spell.ui_name
        spell_description.text = spell.ui_description
        spell_cast_time.text = str(spell.cast_time) + "s"
        spell_cd.text = str(spell.cooldown_duration) + "s"
    elif upgrade:
        spell_name.text = upgrade.ui_name
        spell_description.text = upgrade.ui_description
        $VBoxContainer/HBoxContainer.visible = false
        $VBoxContainer/HBoxContainer2.visible = false
    elif passive:
        spell_name.text = passive.ui_name
        spell_description.text = passive.ui_description
        $VBoxContainer/HBoxContainer.visible = false
        $VBoxContainer/HBoxContainer2.visible = false


func set_spell(_spell: GDDSkill) -> void:
    spell = _spell


func set_upgrade(_upgrade: GDDSkillUpgrade) -> void:
    upgrade = _upgrade


func set_passive(_passive: PassiveSkill) -> void:
    passive = _passive
