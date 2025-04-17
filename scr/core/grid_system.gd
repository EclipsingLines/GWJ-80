## Manages the state of the 16x9 game grid.
class_name GridSystem
extends Node

# Signal emitted when grid cell data changes
signal grid_updated


# The core data structure holding the state of each cell
var grid_data: Array[Array] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_grid()


## Creates the 16x9 grid array and populates it with default CellData objects.
func initialize_grid() -> void:
	grid_data.clear() # Ensure it's empty before initializing
	grid_data.resize(Constants.GRID_HEIGHT)
	for y in range(Constants.GRID_HEIGHT):
		grid_data[y] = []
		grid_data[y].resize(Constants.GRID_WIDTH)
		for x in range(Constants.GRID_WIDTH):
			grid_data[y][x] = CellData.new()
	print("GridSystem: Initialized %d x %d grid." % [Constants.GRID_WIDTH, Constants.GRID_HEIGHT])


## Returns the CellData for a specific coordinate.
## Returns null if coordinates are out of bounds.
func get_cell_data(x: int, y: int) -> CellData:
	if x >= 0 and x < Constants.GRID_WIDTH and y >= 0 and y < Constants.GRID_HEIGHT:
		return grid_data[y][x]
	else:
		push_warning("Attempted to access grid cell out of bounds: (%d, %d)" % [x, y])
		return null


## Sets the CellData for a specific coordinate.
## Use this carefully, prefer methods that modify existing CellData.
func set_cell_data(x: int, y: int, cell_data: CellData) -> void:
	if x >= 0 and x < Constants.GRID_WIDTH and y >= 0 and y < Constants.GRID_HEIGHT:
		grid_data[y][x] = cell_data
	else:
		push_warning("Attempted to set grid cell out of bounds: (%d, %d)" % [x, y])


## Returns the entire grid data structure.
func get_grid_data() -> Array[Array]:
	return grid_data


## Calculates the absolute grid coordinates affected by a card shape placed at a center point.
## Returns an array of Vector2i coordinates, filtering out any that are off-grid.
func get_affected_coordinates(shape: CardData.Shape, center_x: int, center_y: int) -> Array[Vector2i]:
	var affected_coords: Array[Vector2i] = []

	# Get relative offsets from the helper class
	var relative_offsets: Array[Vector2i] = ShapeDefinitions.get_offsets(shape)

	if relative_offsets.is_empty() and shape != CardData.Shape.O: # Allow empty for potentially valid shapes if needed later
		# Warning already pushed by ShapeDefinitions
		return affected_coords

	# Calculate absolute coordinates and check boundaries
	for offset in relative_offsets:
		var absolute_coord := Vector2i(center_x + offset.x, center_y + offset.y)

		# Check if the coordinate is within the grid bounds
		if absolute_coord.x >= 0 and absolute_coord.x < Constants.GRID_WIDTH and \
		   absolute_coord.y >= 0 and absolute_coord.y < Constants.GRID_HEIGHT:
			affected_coords.append(absolute_coord)

	return affected_coords


## Applies a card's color to the grid based on its shape and position.
## For Task 5, this overwrites existing colors.
## Emits grid_updated signal upon completion.
## Returns true if application was successful (at least one cell affected).
func apply_card(card: CardData, center_x: int, center_y: int) -> bool:
	if not card:
		push_warning("apply_card: Invalid CardData provided.")
		return false

	var affected_coords := get_affected_coordinates(card.shape, center_x, center_y)

	if affected_coords.is_empty():
		# Card placed entirely off-grid or shape is invalid
		return false # Or maybe push a warning/error?

	var change_made := false
	for coord in affected_coords:
		var cell_data: CellData = get_cell_data(coord.x, coord.y)
		if cell_data:
			# --- Task 5 Logic: Overwrite ---
			if cell_data.color != card.color: # Only mark change if color actually changes
				cell_data.color = card.color
				cell_data.blend_count = 1 # Reset blend count on overwrite for now
				change_made = true
			# --- End Task 5 Logic ---

	if change_made:
		grid_updated.emit()
		return true
	else:
		# No actual change occurred (e.g., applying same color)
		return false
