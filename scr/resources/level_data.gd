# scr/resources/level_data.gd
class_name LevelData
extends Resource

## Stores the 7x9 grid of target colors after palette mapping.
## Stored as a flat array (row-major order) for simplicity.
@export var target_colors: Array[Color] = []
@export var complexity:float = -1
@export var cell_scores:Array[int] = []
@export var source_block_index: int = -1

func _init():
	# Ensure array is initialized with the correct size (7x9 = 63)
	if target_colors.size() != Constants.GRID_WIDTH * Constants.GRID_HEIGHT:
		target_colors.resize(Constants.GRID_WIDTH * Constants.GRID_HEIGHT)
		# Initialize with white as a default
		target_colors.fill(Color.WHITE)

# Helper function to get color at specific coordinates
func get_color(x: int, y: int) -> Color:
	if x >= 0 and x < Constants.GRID_WIDTH and y >= 0 and y < Constants.GRID_HEIGHT:
		var index = y * Constants.GRID_WIDTH + x
		if index < target_colors.size():
			return target_colors[index]
	push_warning("LevelData: Tried to get color outside bounds (%d, %d)" % [x, y])
	return Color.MAGENTA # Error color
