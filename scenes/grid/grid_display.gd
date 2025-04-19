## Visually represents the game grid using ColorRect nodes within a GridContainer.
class_name GridDisplay
extends Control

## Emitted when a grid cell is clicked by the player.
signal grid_clicked(grid_pos: Vector2i)

# Reference to the GridContainer node that will hold the cell visuals
@onready var grid_container: GridContainer = %GridContainer
@onready var discard_button: TextureButton = %TextureButton
@onready var target_container: GridContainer = %TargetContainer
@onready var turn_label: Label = %TurnLabel
@onready var confirmation_dialog :ConfirmationDialog = %ConfirmationDialog
@onready var submit_button:Button = %SubmitButton
@onready var scoring_panel:Control = %ScoringPanel
@onready var score_label: Label = %ScoreLabel
@onready var grid_containers: HBoxContainer = %GridContainers
@onready var back_button : Button = %BackButton
@onready var hearts : Array[Node] = (%HeartContainer).get_children()
# Size for each cell's ColorRect
var CELL_SIZE: Vector2 = Vector2(Constants.CELL_SIZE_INT, Constants.CELL_SIZE_INT) # Adjust as needed for desired visual size

# 2D array to hold references to the ColorRect nodes for easy access
var _cell_rects: Array[Array] = []

# --- Hover Animation Variables ---
var _hovered_grid_pos: Vector2i = Vector2i(-1, -1) # Stores the last grid cell the mouse hovered over
var _currently_animated_cells: Array[Vector2i] = [] # Stores grid positions of cells currently animated
var _current_selected_shape_coords: Array[Vector2i] = [] # Placeholder: Relative coords of the selected shape. Needs to be updated externally.
var _original_cell_scale: Vector2 = Vector2.ONE
var _hover_animation_scale: Vector2 = Vector2(0.8, 0.8) # Target scale for shrinking
var _hover_animation_duration: float = 0.15 # Duration of the tween
var _active_tweens: Dictionary = {} # Stores active tweens, keyed by Vector2i cell position
var _selected_color: Color = Color(1, 1, 1, 0) # Current color for preview, default transparent white
# ---------------------------------

var in_game : bool = false
signal back

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure the GridContainer is ready
	if not grid_container:
		push_error("GridContainer node not found or not assigned in GridDisplay!")
		return

	# Configure the GridContainer
	grid_container.columns = Constants.GRID_WIDTH

	# Create the visual cells
	_create_cells()

	# Ensure this control node can receive input events
	mouse_filter = Control.MOUSE_FILTER_STOP # Stop input from propagating further
	confirmation_dialog.confirmed.connect(_on_submit_image)
	confirmation_dialog.canceled.connect(_on_cancel_dialog)
	submit_button.pressed.connect(_on_show_dialog)
	back_button.pressed.connect(_on_back_button)
	
func _on_back_button():
	back.emit()

func _on_submit_image():
	confirmation_dialog.visible = false
	scoring_panel.visible = true
	start_scoring()
	
func _on_cancel_dialog():
	confirmation_dialog.visible = false
	
func _on_show_dialog():
	confirmation_dialog.visible = true

func sum_array(array):
	var sum = 0.0
	for element in array:
		sum += element
	return sum
	
func start_scoring():
	back_button.visible = false
	var current_score = 0
	var target_display = (target_container.get_child(0) as TargetDisplay)
	var max_score =  sum_array(target_display.level_data.cell_scores)
	score_label.text = "%.d" % current_score
	for y in range(Constants.GRID_HEIGHT):
		for x in range(Constants.GRID_WIDTH):
			var cell_score =0
			target_display._set_current_highlight(Vector2i(x,y))
			var cell_data:CellData = _grid_data[y][x]
			var z : int = (y * Constants.GRID_WIDTH) + x
			var target_color = target_display.level_data.target_colors[z]
			if cell_data and _are_colors_same(cell_data.display_color, target_color):
				cell_score = target_display.level_data.cell_scores[z]
			current_score += cell_score
			score_label.text = "%.d" % current_score
			_update_hearts(current_score, max_score)
			await get_tree().create_timer(0.05).timeout
	back_button.visible = true
	(target_container.get_child(0) as TargetDisplay)._set_current_highlight(Vector2i(-1,-1))

func _are_colors_same(a:Color, b:Color) -> bool:
	var threshold = 0.05
	return (a.r - b.r) < threshold and (a.g - b.g) < threshold and(a.b - b.b) < threshold

func _update_hearts(score:int,max_score:int):
	var normalized = (score as float) / (max_score as float)
	print("score: " + str(score) + " max: " + str(max_score) + " normalized: " + str(normalized))
	(hearts[0] as Control).visible = normalized > 0
	(hearts[1] as Control).visible = normalized > 0.25
	(hearts[2] as Control).visible = normalized > 0.5
	(hearts[3] as Control).visible = normalized > 0.75
	(hearts[4] as Control).visible = normalized > 0.99

## Creates and adds ColorRect nodes for each grid cell to the GridContainer.
func _create_cells() -> void:
	_cell_rects.clear()
	_cell_rects.resize(Constants.GRID_HEIGHT)

	for y in range(Constants.GRID_HEIGHT):
		_cell_rects[y] = []
		_cell_rects[y].resize(Constants.GRID_WIDTH)
		for x in range(Constants.GRID_WIDTH):
			var cell_rect := ColorRect.new()
			cell_rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			cell_rect.mouse_filter = Control.MOUSE_FILTER_PASS
			cell_rect.custom_minimum_size = CELL_SIZE
			cell_rect.color = Color.WHITE # Start transparent
			cell_rect.name = "Cell_%d_%d" % [x, y] # Optional: for debugging
			grid_container.add_child(cell_rect)
			_cell_rects[y][x] = cell_rect
			# Ensure pivot is centered for scaling animation
			cell_rect.pivot_offset = CELL_SIZE / 2.0
			# Adjust position to account for pivot offset (needed if GridContainer doesn't handle it automatically)
			# This might require tweaking based on how GridContainer positions children
			cell_rect.position += CELL_SIZE / 2.0
			
			cell_rect.mouse_entered.connect(_on_mouse_enter)
			cell_rect.mouse_exited.connect(_on_mouse_exit)

var _grid_data = null

## Updates the color of each visual cell based on the provided grid data.
## Expects grid_data to be an Array[Array] containing CellData objects (or similar).
func update_display(grid_data: Array) -> void:
	_grid_data = grid_data
	var data_height = grid_data.size()
	if data_height == 0: # Handle empty grid data case
		push_warning("GridDisplay: Received empty grid_data.")
		return
	# Ensure grid_data[0] exists before accessing its size
	if data_height > 0:
		var data_width = grid_data[0].size()
		if data_height != Constants.GRID_HEIGHT or data_width != Constants.GRID_WIDTH:
			push_warning("GridDisplay: Received grid_data with incorrect dimensions.")
			return
	else: # If data_height is 0, width check is irrelevant, but dimensions are wrong
		push_warning("GridDisplay: Received grid_data with incorrect dimensions (height 0).")
		return


	if _cell_rects.size() != Constants.GRID_HEIGHT or (_cell_rects.size() > 0 and _cell_rects[0].size() != Constants.GRID_WIDTH):
		push_warning("GridDisplay: Cell visuals not initialized correctly.")
		return

	for y in range(Constants.GRID_HEIGHT):
		for x in range(Constants.GRID_WIDTH):
			# Check bounds before accessing grid_data
			if y < grid_data.size() and x < grid_data[y].size():
				var cell_data: CellData = grid_data[y][x]
				if is_instance_valid(_cell_rects[y][x]): # Check if rect is valid
					if cell_data: # Check if it has a color property
						_cell_rects[y][x].color = cell_data.display_color
					else:
						# Fallback or error handling if data is missing/invalid
						_cell_rects[y][x].color = Color.MAGENTA # Use magenta to indicate an error
						# push_warning("GridDisplay: Invalid or missing cell data at (%d, %d)" % [x, y])
			else:
				push_warning("GridDisplay: Attempted to access grid_data out of bounds at (%d, %d)" % [x, y])

func _on_mouse_enter():
	is_within_bounds = true

func _on_mouse_exit():
	is_within_bounds = false
	
var is_within_bounds :=false

func _process(delta: float) -> void:
	if not in_game:
		return
	var current_hover_pos = _get_grid_coordinate()

	# Check if the mouse is actually within the grid container's bounds


	if not is_within_bounds:
		current_hover_pos = Vector2i(-1, -1) # Treat as off-grid

	# Update hover effect if position changed
	# Also check if the node is visible
	if is_visible_in_tree() and (current_hover_pos != _hovered_grid_pos):
		# Reset previously animated cells that are NOT part of the new hover effect
		var new_affected_cells: Array[Vector2i] = []
		if is_within_bounds and current_hover_pos.x >= 0 and _current_selected_shape_coords.size() > 0:
			new_affected_cells = _get_affected_cells(current_hover_pos, _current_selected_shape_coords)

		var cells_to_reset: Array[Vector2i] = []
		for cell_pos in _currently_animated_cells:
			if not cell_pos in new_affected_cells:
				cells_to_reset.append(cell_pos)
		
		if cells_to_reset.size() > 0:
			_reset_cell_animations(cells_to_reset)

		# Animate newly affected cells
		var cells_to_animate: Array[Vector2i] = []
		for cell_pos in new_affected_cells:
			if not cell_pos in _currently_animated_cells:
				cells_to_animate.append(cell_pos)

		for cell_pos in cells_to_animate:
			_animate_cell_hover(cell_pos)

		# Update the list of currently animated cells
		_currently_animated_cells = new_affected_cells

		_hovered_grid_pos = current_hover_pos
		
	(target_container.get_child(0) as TargetDisplay)._set_current_highlight(current_hover_pos)


func _get_grid_coordinate() -> Vector2i:
	# Need to account for the grid_container's position within the GridDisplay control
	var relative_mouse_pos = grid_container.get_local_mouse_position()

	# Refined calculation considering potential theme overrides for separation
	var h_separation = grid_container.get_theme_constant("h_separation")
	var v_separation = grid_container.get_theme_constant("v_separation")

	var cell_width_with_sep = CELL_SIZE.x + h_separation
	var cell_height_with_sep = CELL_SIZE.y + v_separation

	# Prevent division by zero if cell size is zero
	if cell_width_with_sep <= 0 or cell_height_with_sep <= 0:
		return Vector2i(-1, -1)

	var col = floori(relative_mouse_pos.x / cell_width_with_sep)
	var row = floori(relative_mouse_pos.y / cell_height_with_sep)

	# Clamp values to be within grid bounds
	col = clamp(col, 0, Constants.GRID_WIDTH - 1)
	row = clamp(row, 0, Constants.GRID_HEIGHT - 1)

	# Check if the calculated position is actually over a cell vs over spacing
	var cell_rect_in_container = Rect2(col * cell_width_with_sep, row * cell_height_with_sep, CELL_SIZE.x, CELL_SIZE.y)
	if not cell_rect_in_container.has_point(relative_mouse_pos):
		return Vector2i(-1, -1) # Mouse is over spacing, not a cell

	return Vector2i(col, row)

## Handles GUI input events within the bounds of this control.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Calculate the grid cell coordinates using the refined function
		var grid_pos = _get_grid_coordinate() # Use local mouse pos for coord calc

		# Check if the click is within the valid grid bounds (0 to width/height - 1)
		if grid_pos.x >= 0: # _get_grid_coordinate now returns -1 if not on a valid cell
			emit_signal("grid_clicked", grid_pos) # Already Vector2i
			get_viewport().set_input_as_handled() # Consume the event


# --- Hover Animation Functions ---

## Calculates the absolute grid positions affected by a shape at a given hover position.
func _get_affected_cells(hover_pos: Vector2i, shape_coords: Array[Vector2i]) -> Array[Vector2i]:
	var affected: Array[Vector2i] = []
	if shape_coords.is_empty() or hover_pos.x < 0: # Don't calculate if no shape or off-grid
		return affected

	for relative_pos in shape_coords:
		var absolute_pos = hover_pos + relative_pos
		# Check grid boundaries
		if absolute_pos.x >= 0 and absolute_pos.x < Constants.GRID_WIDTH and \
		   absolute_pos.y >= 0 and absolute_pos.y < Constants.GRID_HEIGHT:
			affected.append(absolute_pos)
	return affected

## Resets the scale and color modulation animation for a list of cells.
func _reset_cell_animations(cells: Array[Vector2i]) -> void:
	for cell_pos in cells:
		# Check bounds before trying to access _cell_rects
		if cell_pos.x >= 0 and cell_pos.x < Constants.GRID_WIDTH and \
		   cell_pos.y >= 0 and cell_pos.y < Constants.GRID_HEIGHT:
			# Additional check for _cell_rects initialization
			if cell_pos.y < _cell_rects.size() and cell_pos.x < _cell_rects[cell_pos.y].size():
				var cell_rect: ColorRect = _cell_rects[cell_pos.y][cell_pos.x]
				if is_instance_valid(cell_rect):
					# Kill existing tween for this cell, if any
					if _active_tweens.has(cell_pos):
						var existing_tween: Tween = _active_tweens[cell_pos]
						if is_instance_valid(existing_tween):
							existing_tween.kill()
						# Don't erase here yet, let the new tween overwrite or finished signal clean up

					# Create a new tween to smoothly return to original state
					var tween: Tween = create_tween().set_parallel(true) # Scale and modulate can be parallel
					_active_tweens[cell_pos] = tween # Store the new tween
					# Tween scale back to normal
					tween.tween_property(cell_rect, "scale", _original_cell_scale, _hover_animation_duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					# Tween modulate back to white (no color overlay)
					tween.tween_property(cell_rect, "modulate", Color.WHITE, _hover_animation_duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
					# Remove tween from dict when finished
					tween.finished.connect(_on_tween_finished.bind(cell_pos))

## Applies the shrinking and color modulation animation to a single cell.
func _animate_cell_hover(cell_pos: Vector2i) -> void:
	# Check bounds before trying to access _cell_rects
	if cell_pos.x >= 0 and cell_pos.x < Constants.GRID_WIDTH and \
	   cell_pos.y >= 0 and cell_pos.y < Constants.GRID_HEIGHT:
		# Additional check for _cell_rects initialization
		if cell_pos.y < _cell_rects.size() and cell_pos.x < _cell_rects[cell_pos.y].size():
			var cell_rect: ColorRect = _cell_rects[cell_pos.y][cell_pos.x]
			if is_instance_valid(cell_rect):
				# Kill existing tween for this cell, if any
				if _active_tweens.has(cell_pos):
					var existing_tween: Tween = _active_tweens[cell_pos]
					if is_instance_valid(existing_tween):
						existing_tween.kill()
					# Don't erase here yet, let the new tween overwrite or finished signal clean up

				# Create a new tween for the shrink and color animation
				var tween: Tween = create_tween().set_parallel(true) # Scale and modulate can be parallel
				_active_tweens[cell_pos] = tween # Store the new tween
				# Tween scale for shrinking effect
				tween.tween_property(cell_rect, "scale", _hover_animation_scale, _hover_animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				# Apply color modulation if a valid color is selected (alpha > 0)
				var preview_color = Color.WHITE # Default to no modulation
				if _selected_color.a > 0:
					preview_color = _selected_color
				# Tween modulate to the preview color
				tween.tween_property(cell_rect, "modulate", preview_color, _hover_animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				# Remove tween from dict when finished
				tween.finished.connect(_on_tween_finished.bind(cell_pos))

## Public function to update the currently selected shape (call this from your game logic)
func set_selected_shape(shape_coords: Array[Vector2i]) -> void:
	# Check if the shape data has actually changed
	var changed = false
	if _current_selected_shape_coords.size() != shape_coords.size():
		changed = true
	else:
		# Simple comparison assuming order matters and coords are unique within shape
		for i in shape_coords.size():
			if _current_selected_shape_coords[i] != shape_coords[i]:
				changed = true
				break

	if changed:
		_current_selected_shape_coords = shape_coords.duplicate() # Store a copy
		# Force reset and re-evaluation of hover effect when shape changes
		# Reset all currently animated cells when shape changes
		_reset_cell_animations(_currently_animated_cells)
		# Clear the list immediately after starting reset tweens
		_currently_animated_cells.clear()
		# Force an update in the next process frame by invalidating hover pos
		_hovered_grid_pos = Vector2i(-2, -2) # Use a value guaranteed to be different

## Public function to update the currently selected color for preview.
## Pass Color(1,1,1,0) or similar transparent color to disable color preview.
func set_selected_color(color: Color) -> void:
	if _selected_color != color:
		_selected_color = color
		# Force an update in the next process frame by invalidating hover pos
		# This ensures the color preview updates immediately if the mouse isn't moving
		_hovered_grid_pos = Vector2i(-2, -2)

## Cleans up finished tweens from the dictionary.
func _on_tween_finished(cell_pos: Vector2i) -> void:
	# Check if the tween completing is still the one stored (it might have been replaced)
	# This check is technically redundant if kill() is always called before creating a new one,
	# but adds a layer of safety.
	if _active_tweens.has(cell_pos):
		# We don't have a direct reference to the specific tween instance here easily,
		# so we assume if a tween exists for this pos, it's the one that finished.
		# A more robust way might involve passing the tween itself, but bind() makes that tricky.
		_active_tweens.erase(cell_pos)
