class_name CellData extends Resource

var color: Color = Color.WHITE # Current color of the cell
var blend_count: int = 0 # How many times a color has been blended onto this cell

func _init(p_color: Color = Color.WHITE, p_blend_count: int = 0):
	color = p_color
	blend_count = p_blend_count
