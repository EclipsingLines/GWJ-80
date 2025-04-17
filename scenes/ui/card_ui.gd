extends Control
class_name CardUI

## Emitted when the card's button is pressed by the player.
## Passes the card data associated with this UI element.
signal card_pressed(card_data: CardData)

## The data defining the card's appearance and properties.
## When set, triggers the display update.
@export var card_data: CardData:
	set(value):
		card_data = value
		if is_inside_tree(): # Avoid errors if not ready
			update_display()

# Preload CardData for type hinting
const CardData = preload("res://scr/resources/card_data.gd")

# Node references (assuming standard names from the plan)
@onready var button: Button = $Button
@onready var grid_container: GridContainer = $GridContainer

# Define the visual patterns for each shape on a 3x3 grid
# True = active cell (use card_data.color), False = inactive cell (use theme background)
const SHAPE_PATTERNS = {
	CardData.Shape.O: [
		true, true, true,
		true, false, true,
		true, true, true
	],
	CardData.Shape.PLUS: [
		false, true, false,
		true, true, true,
		false, true, false
	],
	CardData.Shape.XLine: [
		false, false, false,
		true, true, true,
		false, false, false
	],
	CardData.Shape.YLine: [
		false, true, false,
		false, true, false,
		false, true, false
	],
	CardData.Shape.XShape: [
		true, false, true,
		false, true, false,
		true, false, true
	]
}


func _ready() -> void:
	# Ensure the button signal is connected
	if button:
		button.pressed.connect(_on_button_pressed)
	else:
		push_error("CardUI: Button node not found or not ready.")

	# Initial display update if card_data was set before _ready
	if card_data:
		update_display()


## Updates the visual representation of the card based on its card_data.
func update_display() -> void:
	if not card_data:
		push_warning("CardUI: Cannot update display, card_data is null.")
		# Optionally hide or show a placeholder state
		return

	if not grid_container:
		push_error("CardUI: GridContainer node not found.")
		return

	if grid_container.get_child_count() != 9:
		push_error("CardUI: GridContainer does not have exactly 9 children (ColorRects).")
		return

	# Get the pattern for the current shape
	var pattern: Array = SHAPE_PATTERNS.get(card_data.shape, [])
	if pattern.is_empty():
		push_error("CardUI: No pattern defined for shape %s." % CardData.Shape.keys()[card_data.shape])
		return

	# Get theme colors (adjust names if your theme uses different ones)
	var inactive_color = get_theme_color("background_color", "Panel") # Example: Use Panel's background
	var active_color = card_data.color

	# Apply pattern to grid cells
	for i in range(grid_container.get_child_count()):
		var cell: ColorRect = grid_container.get_child(i) as ColorRect
		if cell:
			if pattern[i]:
				cell.color = active_color
			else:
				cell.color = inactive_color
		else:
			push_warning("CardUI: Child %d in GridContainer is not a ColorRect." % i)

	# Update tooltip (optional)
	if button:
		button.tooltip_text = "Shape: %s\nColor: %s" % [CardData.Shape.keys()[card_data.shape], card_data.color.to_html(false)]


## Called when the internal button is pressed. Emits the card_pressed signal.
func _on_button_pressed() -> void:
	if card_data:
		emit_signal("card_pressed", card_data)
	else:
		push_warning("CardUI: Button pressed but card_data is null.")
