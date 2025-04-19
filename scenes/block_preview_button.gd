class_name BlockPreviewButton extends Button

@export var preview_panel:GridContainer
@export var heart_container:FlowContainer

var level_data:LevelData

func set_level_data(data:LevelData):
	level_data = data
	preview_panel.columns = Constants.GRID_WIDTH
	for child in preview_panel.get_children():
		child.queue_free()
	for color in level_data.target_colors:
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(10,10)
		rect.color = color
		rect.mouse_filter = Control.MOUSE_FILTER_PASS
		preview_panel.add_child(rect)
