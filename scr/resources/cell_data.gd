# scr/resources/cell_data.gd
class_name CellData
extends Resource

## Sequence of base colors (e.g., calculated primary colors) applied to this cell.
var applied_colors: Array[Color] = []
## The calculated color to display based on the applied_colors sequence and the active palette.
var display_color: Color = Color.WHITE
## Flag indicating if the cell has turned black due to 4 blends.
var is_blacked_out: bool = false

func _init(p_applied_colors: Array[Color] = [], p_display_color: Color = Color.WHITE, p_is_blacked_out: bool = false):
	# Use duplicate() for arrays to avoid shared references if default is modified
	applied_colors = p_applied_colors.duplicate(true) # Deep copy
	display_color = p_display_color
	is_blacked_out = p_is_blacked_out

## Optional: Helper to reset the cell state
func reset():
	applied_colors.clear()
	display_color = Color.WHITE
	is_blacked_out = false
