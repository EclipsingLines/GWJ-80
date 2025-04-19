class_name LevelSelect extends Control
@export var level_container : FlowContainer
@export var block_preview_prototype : BlockPreviewButton

var selected_index = -1
signal level_selected

func update_available_levels(level_array:Array[LevelData]):
	for child in level_container.get_children():
		child.queue_free()
	var index = 0
	for level_data in level_array:
		var preview :BlockPreviewButton= block_preview_prototype.duplicate()
		preview.set_level_data(level_data)
		level_container.add_child(preview)
		preview.pressed.connect(_on_level_selected.bind(index))
		preview.visible = true
		index+=1

func _on_level_selected(index:int):
	selected_index = index
	level_selected.emit(index)
