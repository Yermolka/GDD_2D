class_name QuestContainer extends Control


var quest_map: Dictionary


func _ready() -> void:
    Questify.quest_started.connect(_update_quests)
    Questify.quest_turned_in.connect(_update_quests)
    Questify.quest_objective_added.connect(_update_objective)
    Questify.quest_objective_completed.connect(_update_objective)


func _update_quests(quest: QuestResource) -> void:
    if quest not in quest_map:
        var quest_vbox: VBoxContainer = VBoxContainer.new()
        add_child(quest_vbox)
        quest_map[quest] = quest_vbox
        var quest_name: Label = Label.new()
        quest_vbox.add_child(quest_name)
        quest_name.text = quest.name
    else:
        remove_child(quest_map[quest])
        quest_map.erase(quest)


func _update_objective(quest: QuestResource, objective: QuestObjective) -> void:
    pass
