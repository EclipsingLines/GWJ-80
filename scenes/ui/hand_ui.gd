extends Control
class_name HandUI

## Emitted when a card UI element is clicked by the player.
## Passes the card data and its index in the hand array.
signal card_selected(card_data: CardData, index: int)

@onready var card_container: HBoxContainer = $CardContainer

# Preload the CardData resource script to use its type hint
const CardData = preload("res://scr/resources/card_data.gd")

# Preload the CardUI script for type hinting
const CardUI = preload("res://scenes/ui/card_ui.gd")
# Preload the new Card UI scene
const CardUIScene = preload("res://scenes/ui/card_ui.tscn")

# Store the current hand data
var _current_hand: Array[CardData] = []

# --- Public Methods ---

## Clears the current hand display and shows the new cards.
func display_hand(cards: Array[CardData]) -> void:
	_current_hand = cards
	_clear_display()
	_populate_display()

# --- Private Methods ---

## Removes all existing card nodes from the container.
func _clear_display() -> void:
	for child in card_container.get_children():
		child.queue_free()

## Creates UI nodes for each card in the current hand.
func _populate_display() -> void:
	for i in range(_current_hand.size()):
		var card_data: CardData = _current_hand[i]
		if card_data:
			var card_node = _create_card_node(card_data, i)
			card_container.add_child(card_node)

## Creates an instance of the CardUI scene for the given card data.
func _create_card_node(card_data: CardData, index: int) -> Control: # Keep index for now if needed elsewhere
	if not CardUIScene:
		push_error("HandUI: CardUIScene is not preloaded.")
		return Control.new() # Return empty control on error

	var card_node = CardUIScene.instantiate() as CardUI
	if not card_node:
		push_error("HandUI: Failed to instantiate CardUIScene.")
		return Control.new()

	# Set the data, which triggers the CardUI's update_display
	card_node.card_data = card_data

	# Connect the card's specific signal to our handler
	# We pass the card_data itself, as the CardUI knows its own data
	card_node.card_pressed.connect(_on_card_selected)

	return card_node


## Handles the press event emitted from a CardUI instance.
func _on_card_selected(selected_card_data: CardData) -> void:
	# Find the index of the selected card in the current hand
	var index = _current_hand.find(selected_card_data)

	if index != -1:
		print("Card selected: ", selected_card_data.shape, " ", selected_card_data.color, " at index ", index)
		# Emit the original signal, including the index
		emit_signal("card_selected", selected_card_data, index)
	else:
		# This case might happen if the hand changes rapidly or there's a data mismatch
		push_warning("HandUI: Selected card data not found in the current hand.")
