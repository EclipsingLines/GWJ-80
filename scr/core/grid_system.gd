## Manages the state of the 16x9 game grid.
class_name GridSystem
extends Node

const GameColorPalette = preload("res://scr/resources/color_palette.gd")
const CellData = preload("res://scr/resources/cell_data.gd") # Preload CellData too
const Constants = preload("res://scr/utils/constants.gd") # Preload Constants
const ShapeDefinitions = preload("res://scr/utils/shape_definitions.gd") # Preload ShapeDefinitions
const CardData = preload("res://scr/resources/card_data.gd") # Preload CardData

# Signal emitted when grid cell data changes
signal grid_updated


# The core data structure holding the state of each cell
var grid_data: Array[Array] = []

## The active color palette resource used for blending calculations.
@export var palette: GameColorPalette


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if palette:
		# Connect signal if not already connected
		if not palette.is_connected("palette_updated", Callable(self, "_on_palette_updated")):
			palette.palette_updated.connect(_on_palette_updated)
		# Initial grid setup depends on palette, ensure palette is ready
		palette.call_deferred("_update_primary_colors") # Ensure colors are calculated initially
		call_deferred("initialize_grid") # Defer grid init slightly
	else:
		push_error("GridSystem requires a GameColorPalette assigned in the editor!")
		initialize_grid() # Initialize with default white anyway


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
	# Ensure cells start with correct default based on potential palette updates
	_on_palette_updated() # Force initial calculation/redraw


## Returns the CellData for a specific coordinate.
## Returns null if coordinates are out of bounds.
func get_cell_data(x: int, y: int) -> CellData:
	if x >= 0 and x < Constants.GRID_WIDTH and y >= 0 and y < Constants.GRID_HEIGHT:
		# Ensure grid_data and its sub-array are valid before accessing
		if y < grid_data.size() and x < grid_data[y].size():
			return grid_data[y][x]
		else:
			push_error("GridSystem: Grid data structure inconsistent at (%d, %d)" % [x, y])
			return null
	else:
		#push_warning("Attempted to access grid cell out of bounds: (%d, %d)" % [x, y]) # Reduce noise
		return null


## Sets the CellData for a specific coordinate.
## Use this carefully, prefer methods that modify existing CellData.
func set_cell_data(x: int, y: int, cell_data: CellData) -> void:
	if x >= 0 and x < Constants.GRID_WIDTH and y >= 0 and y < Constants.GRID_HEIGHT:
		# Ensure grid_data and its sub-array are valid before accessing
		if y < grid_data.size() and x < grid_data[y].size():
			grid_data[y][x] = cell_data
		else:
			push_error("GridSystem: Grid data structure inconsistent during set at (%d, %d)" % [x, y])
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

	# Calculate absolute coordinates and check boundaries
	for offset in relative_offsets:
		var absolute_coord := Vector2i(center_x + offset.x, center_y + offset.y)

		# Check if the coordinate is within the grid bounds
		if absolute_coord.x >= 0 and absolute_coord.x < Constants.GRID_WIDTH and \
		   absolute_coord.y >= 0 and absolute_coord.y < Constants.GRID_HEIGHT:
			affected_coords.append(absolute_coord)

	return affected_coords


## Applies a card's color to the grid based on its shape and position.
## For Task 5, this overwrites existing colors. (Will be updated in next step)
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
			# --- New Blending Logic (Step 5) ---
			if cell_data.is_blacked_out:
				continue # Skip blacked-out cells

			# Ensure palette is available
			if not palette:
				push_error("Apply Card: Palette not set in GridSystem!")
				continue # Skip this cell if palette is missing

			var current_sequence_size = cell_data.applied_colors.size()

			if current_sequence_size < 4: # Allow up to 3 blends before blackout on the 4th
				var card_primary_color: Color # Store the primary this card represents
				var is_valid_primary = false
				var p1 = palette.get_primary_1()
				var p2 = palette.get_primary_2()
				var p3 = palette.get_primary_3()

				# Identify which primary the card's color matches (use approximate comparison)
				if card.color.is_equal_approx(p1):
					card_primary_color = p1
					is_valid_primary = true
				elif card.color.is_equal_approx(p2):
					card_primary_color = p2
					is_valid_primary = true
				elif card.color.is_equal_approx(p3):
					card_primary_color = p3
					is_valid_primary = true

				if is_valid_primary:
					if current_sequence_size < 3: # Apply normally (0, 1, or 2 colors present)
						cell_data.applied_colors.append(card_primary_color) # Store the identified primary
						cell_data.display_color = _calculate_display_color(cell_data.applied_colors)
						change_made = true
					else: # This is the 4th application (current_sequence_size == 3)
						# cell_data.applied_colors.append(card_primary_color) # Optional: Store 4th color?
						cell_data.display_color = Color.BLACK
						cell_data.is_blacked_out = true
						# cell_data.applied_colors.clear() # Optional: Clear sequence?
						change_made = true
				else:
					push_warning("Attempted to apply non-primary color: %s. Expected one of %s, %s, %s" % [card.color, p1, p2, p3])
			# --- End New Blending Logic ---

	# Emit signal only if a change was actually made across any affected cell
	if change_made:
		grid_updated.emit()

	return change_made # Return true if any cell was successfully updated


## Handles the palette_updated signal from the GameColorPalette resource.
## Recalculates all cell display colors based on the new palette.
func _on_palette_updated():
	# Recalculate all cell display colors based on the new palette
	print("GridSystem: Palette updated, recalculating grid colors...")
	var change_made := false
	# Ensure grid_data is initialized before proceeding
	if grid_data.is_empty():
		push_warning("GridSystem: _on_palette_updated called before grid initialized.")
		return

	for y in range(Constants.GRID_HEIGHT):
		for x in range(Constants.GRID_WIDTH):
			var cell: CellData = get_cell_data(x, y)
			if cell and not cell.is_blacked_out:
				# Recalculate display color based on existing applied_colors sequence
				var new_display_color = _calculate_display_color(cell.applied_colors)
				if not cell.display_color.is_equal_approx(new_display_color):
					cell.display_color = new_display_color
					change_made = true
	if change_made:
		grid_updated.emit() # Signal UI to redraw


## Calculates the display color by averaging the RGB values of the unique primary colors
## present in the applied sequence, based on the active palette.
func _calculate_display_color(applied_sequence: Array[Color]) -> Color:
	if not palette:
		push_error("GridSystem: No GameColorPalette assigned!")
		return Color.MAGENTA # Error color

	if applied_sequence.is_empty():
		return Color.WHITE

	var unique_primaries: Array[Color] = []
	var p1 = palette.get_primary_1()
	var p2 = palette.get_primary_2()
	var p3 = palette.get_primary_3()

	# Identify which unique primaries are in the sequence using approximate comparison
	var has_p1 = false
	var has_p2 = false
	var has_p3 = false

	for color_in_sequence in applied_sequence:
		if not has_p1 and color_in_sequence.is_equal_approx(p1):
			unique_primaries.append(p1)
			has_p1 = true
		elif not has_p2 and color_in_sequence.is_equal_approx(p2):
			unique_primaries.append(p2)
			has_p2 = true
		elif not has_p3 and color_in_sequence.is_equal_approx(p3):
			unique_primaries.append(p3)
			has_p3 = true # Optimization: stop checking once all 3 found?

	if unique_primaries.is_empty():
		# This might happen if the sequence contains colors not matching the current palette primaries
		# push_warning("No valid primary colors identified in sequence: %s" % applied_sequence)
		return Color.WHITE # Return white if no valid primaries found (e.g., during init)

	# Calculate the average RGB color
	var sum_color := Color(0, 0, 0, 1)
	for primary_color in unique_primaries:
		sum_color += primary_color

	# Average the color components
	var count = float(unique_primaries.size())
	var avg_color = Color(sum_color.r / count, sum_color.g / count, sum_color.b / count, 1.0)

	return avg_color
