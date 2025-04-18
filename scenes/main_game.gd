## Main script for the primary game scene.
## Orchestrates core game systems like the grid.
extends Node3D

# Reference to the grid data management system
@onready var grid_system: GridSystem = $GridSystem
# Reference to the grid visual display system (assuming it's under ui_root)
# Adjust path if GridDisplay is placed elsewhere in the scene tree.
@onready var grid_display: GridDisplay = $ui_root/GridDisplay
# Reference to the player hand UI
@onready var hand_ui: HandUI = $ui_root/HandUI

const TargetDisplayScene = preload("res://scenes/ui/target_display.tscn")
const LevelData = preload("res://scr/resources/level_data.gd") # Preload LevelData
var available_levels: Array[LevelData] = []
var current_level_data: LevelData = null
# --- End Target Display ---

var discard_button: TextureButton
# Player's current hand
var _player_hand: Array[CardData] = []

# Deck of cards
var _deck: Array[CardData] = []

# State for card placement
var _selected_card_data: CardData = null
var _selected_card_index: int = -1

# Turn counter
var turns_remaining: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure dependencies are ready
	if not grid_system:
		push_error("MainGame: GridSystem node not found or not assigned!")
		return
	if not grid_display:
		# Try finding it if the path was slightly off (e.g., if ui_root structure changes)
		grid_display = find_child("GridDisplay", true, false) # Recursive search
		if not grid_display:
			push_error("MainGame: GridDisplay node not found or not assigned!")
			return
	discard_button = grid_display.discard_button
	if not hand_ui:
		hand_ui = find_child("HandUI", true, false) # Recursive search
		if not hand_ui:
			push_error("MainGame: HandUI node not found or not assigned!")
			return
			
	# GridSystem initializes itself in its _ready function.
	# Now, update the display with the initial grid state.
	# Wait a frame to ensure GridDisplay has also run its _ready and created cells.
	# Connect signal AFTER ensuring both nodes are ready
	if grid_system and grid_display:
		if not grid_system.is_connected("grid_updated", Callable(self, "_on_grid_updated")):
			grid_system.grid_updated.connect(_on_grid_updated)
	if hand_ui:
		if not hand_ui.is_connected("card_selected", Callable(self, "_on_hand_card_selected")):
			hand_ui.card_selected.connect(_on_hand_card_selected)
	if grid_display:
		if not grid_display.is_connected("grid_clicked", Callable(self, "_on_grid_display_clicked")):
			grid_display.grid_clicked.connect(_on_grid_display_clicked)
			
	discard_button.disabled = true
	discard_button.pressed.connect(_on_discard_selected_card)
	
	turns_remaining = Constants.INITIAL_DECK_SIZE
	grid_display.turn_label.text = "%1.0d" % turns_remaining
	# Initial display update after nodes are ready
	await get_tree().process_frame # Wait a frame ensures GridDisplay/HandUI also ran _ready
	_on_grid_updated() # Call handler directly for initial grid display
	_create_and_shuffle_deck() # Prepare the deck first
	_initialize_player_hand() # Setup initial hand
	_load_available_levels() # Load level data
	_start_new_level() # Select and display initial target level
	
# --- Level Loading and Display ---

## Scans the 'res://resources/levels/' directory and loads all LevelData resources.
func _load_available_levels() -> void:
	available_levels.clear()
	var level_dir_path = "res://resources/levels/"
	var dir := DirAccess.open(level_dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var file_path = level_dir_path.path_join(file_name)
				var loaded_resource = load(file_path)
				if loaded_resource is LevelData:
					available_levels.append(loaded_resource)
				else:
					push_warning("MainGame: Found non-LevelData resource in levels directory: %s" % file_path)
			file_name = dir.get_next()
		dir.list_dir_end()
		print("MainGame: Loaded %d available levels." % available_levels.size())
	else:
		push_error("MainGame: Could not open levels directory: %s" % level_dir_path)


## Selects a new random level and updates the target display.
func _start_new_level() -> void:
	var target_display_container:GridContainer = grid_display.target_container
	if available_levels.is_empty():
		push_warning("MainGame: No levels loaded, cannot start new level.")
		current_level_data = null
		# Optionally clear the target display container
		if target_display_container:
			for child in target_display_container.get_children():
				child.queue_free()
		return

	# Select a random level
	current_level_data = available_levels.pick_random()
	print("MainGame: Starting level with target data from: %s" % current_level_data.resource_path)

	# Update the target display
	if not target_display_container:
		push_error("MainGame: Target Display Container node not assigned in the editor!")
		return

	# Clear previous target display
	for child in target_display_container.get_children():
		child.queue_free()

	# Instantiate and add new target display
	var target_instance := TargetDisplayScene.instantiate()
	target_instance.level_data = current_level_data
	target_display_container.add_child(target_instance)

# --- End Level Loading and Display ---


func _on_discard_selected_card():
	print("Discarding card at: " + String.num(_selected_card_index))
	if _selected_card_index >= 0 and _selected_card_index < _player_hand.size():
		_player_hand.remove_at(_selected_card_index)
	else:
		push_error("MainGame: Invalid selected card index %d after successful placement!" % _selected_card_index)
	# Reset selection state
	_selected_card_data = null
	_selected_card_index = -1
	discard_button.disabled = true
	# Update the hand UI
	if hand_ui:
		hand_ui.display_hand(_player_hand)
	else:
		push_error("MainGame: HandUI node not available to update after card placement.")

	if grid_display:
		grid_display.set_selected_shape([])
		# Reset selected color preview
		grid_display.set_selected_color(Color(1, 1, 1, 0)) # Use transparent white
	else:
		push_error("MainGame: GridDisplay node not available to update after card placement.")

	# Draw a new card (Task 7 placeholder)
	turns_remaining = turns_remaining - 1
	grid_display.turn_label.text = "%1.0d" % turns_remaining
	_draw_card_for_turn()

func _on_grid_updated():
	if grid_display and grid_system:
		var current_grid_data = grid_system.get_grid_data()
		if current_grid_data and not current_grid_data.is_empty():
			grid_display.update_display(current_grid_data)
		else:
			push_error("MainGame: GridSystem data is empty or invalid, cannot update display on signal.")
	else:
		push_error("MainGame: Cannot update display on grid_updated signal due to missing nodes.")


# --- Hand Management ---

func _create_and_shuffle_deck() -> void:
	_deck.clear()
	# Define the colors and shapes to include in the deck
	# TODO: Refine deck composition based on game balance needs
	var palette: GameColorPalette = grid_system.palette
	var colors = [palette.get_primary_1(), palette.get_primary_2(), palette.get_primary_3()]
	var shapes = CardData.Shape.keys() # Get all defined shapes
	for i in range(Constants.INITIAL_DECK_SIZE + Constants.INITIAL_HAND_SIZE):
		var card = CardData.new()
		card.shape = CardData.Shape[shapes.pick_random()]
		card.color = colors.pick_random()
		_deck.append(card)

	# Shuffle the deck
	_deck.shuffle()
	print("Deck created with %d cards." % _deck.size())


func _draw_card() -> CardData:
	if _deck.is_empty():
		push_warning("Attempted to draw from an empty deck.")
		# TODO: Handle deck reshuffling or game end condition?
		return null
	return _deck.pop_front() # Take from the "top" (front) of the shuffled deck


func _initialize_player_hand() -> void:
	_player_hand.clear()
	for i in range(Constants.INITIAL_HAND_SIZE):
		var drawn_card = _draw_card()
		if drawn_card:
			_player_hand.append(drawn_card)
		else:
			# Stop drawing if the deck runs out during initial draw
			push_warning("Deck ran out during initial hand draw.")
			break

	if hand_ui:
		hand_ui.display_hand(_player_hand)
	else:
		push_error("MainGame: HandUI node not available to display initial hand.")


func _draw_card_for_turn() -> void:
	var new_card = _draw_card()
	if new_card:
		_player_hand.append(new_card)
		if hand_ui:
			hand_ui.display_hand(_player_hand) # Update UI
	else:
		push_warning("Could not draw card for turn (deck empty?).")


func _on_hand_card_selected(card_data: CardData, index: int) -> void:
	# Store the selected card data and its index
	_selected_card_data = card_data
	_selected_card_index = index
	print("MainGame: Card selected - Shape: %s, Color: %s, Index: %d" % [CardData.Shape.keys()[card_data.shape], card_data.color, index])
	if grid_display:
		grid_display.set_selected_shape(ShapeDefinitions.get_offsets(card_data.shape))
		# Also set the selected color for preview
		grid_display.set_selected_color(card_data.color)
	else:
		push_error("MainGame: GridDisplay node not available to update after card selected.")
	if discard_button:
		discard_button.disabled = false
## Handles clicks on the grid display.
func _on_grid_display_clicked(grid_pos: Vector2i) -> void:
	print("MainGame: Grid clicked at %s" % grid_pos)

	if _selected_card_data == null:
		print("MainGame: Grid clicked, but no card selected.")
		return # No card selected, do nothing

	# Attempt to apply the selected card to the grid system
	if grid_system.apply_card(_selected_card_data, grid_pos.x, grid_pos.y):
		print("MainGame: Card applied successfully.")
		# Card was successfully applied, remove it from hand
		_on_discard_selected_card()

	else:
		print("MainGame: Card application failed (e.g., off-grid, no change).")
		# Optional: Provide feedback to the player that placement failed?
		# For now, just deselect the card if placement fails
		# _selected_card_data = null
		# _selected_card_index = -1
		# TODO: Decide if failed placement should deselect the card.
