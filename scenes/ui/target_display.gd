# scenes/ui/target_display.gd
@tool # Allows preview in editor and ensures Constants are loaded
class_name TargetDisplay
extends Control

const LevelData = preload("res://scr/resources/level_data.gd")

## The LevelData resource containing the target colors to display.
@export var level_data: LevelData: set = _set_level_data

## Size of each cell in pixels.
@export var cell_size := Vector2i(Constants.CELL_SIZE_INT, Constants.CELL_SIZE_INT): set = _set_cell_size # Example size, adjust as needed
## Spacing between cells in pixels.
@export var cell_spacing: int = 4: set = _set_cell_spacing

func _set_level_data(new_data: LevelData):
	if level_data != new_data:
		level_data = new_data
		# Trigger redraw if the node is ready
		if is_inside_tree():
			_update_minimum_size()
			queue_redraw()

func _set_cell_size(new_size: Vector2i):
	if cell_size != new_size:
		cell_size = new_size
		if is_inside_tree():
			_update_minimum_size()
			queue_redraw()

func _set_cell_spacing(new_spacing: int):
	if cell_spacing != new_spacing:
		cell_spacing = new_spacing
		if is_inside_tree():
			_update_minimum_size()
			queue_redraw()

func _draw():
	if not level_data:
		# Draw placeholder if no data
		draw_rect(Rect2(Vector2.ZERO, size), Color.DARK_GRAY, true)
		return

	var draw_pos := Vector2.ZERO
	for y in range(Constants.GRID_HEIGHT):
		draw_pos.x = 0
		for x in range(Constants.GRID_WIDTH):
			var color = level_data.get_color(x, y)
			var rect = Rect2(draw_pos, cell_size)
			draw_rect(rect, color, true)
			draw_pos.x += cell_size.x + cell_spacing
		draw_pos.y += cell_size.y + cell_spacing

func _ready():
	# Initial draw and size calculation when ready
	_update_minimum_size()
	queue_redraw()

## Updates the control's minimum size based on cell size and spacing.
func _update_minimum_size():
	var total_width = Constants.GRID_WIDTH * cell_size.x + max(0, Constants.GRID_WIDTH - 1) * cell_spacing
	var total_height = Constants.GRID_HEIGHT * cell_size.y + max(0, Constants.GRID_HEIGHT - 1) * cell_spacing
	custom_minimum_size = Vector2(total_width, total_height)
