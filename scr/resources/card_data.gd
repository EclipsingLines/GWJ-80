## Defines the data structure for a single game card.
## Use this resource to create specific card types (e.g., red_o_card.tres).
class_name CardData
extends Resource

## Enum defining the possible shapes a card can represent.
enum Shape {
	O, # Perimeter of a 3x3 square
	PLUS, # Standard 3x3 plus sign
	XLine, # Horizontal 3-cell line
	YLine, # Vertical 3-cell line
	XShape, # Corners of a 3x3 square plus the center
	DOT # Single pixel
}

## The shape this card represents (e.g., O or PLUS).
@export var shape: Shape = Shape.O

## The primary color associated with this card.
@export var color: Color = Color.WHITE
