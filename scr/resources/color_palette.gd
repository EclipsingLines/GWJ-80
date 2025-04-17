# scr/resources/color_palette.gd
@tool
class_name GameColorPalette # Renamed from ColorPalette to avoid conflict
extends Resource

@export_color_no_alpha var base_color :
	set(value):
		start_hue = (value as Color).h
		base_color = value
		
## Starting hue for the first primary color (0.0 to 1.0).
@export var start_hue: float = 0.0: set = _set_start_hue
## Saturation for the primary colors (0.0 to 1.0).
@export var saturation: float = 1.0: set = _set_saturation
## Value (brightness) for the primary colors (0.0 to 1.0).
@export var value: float = 1.0: set = _set_value

# Store the calculated primary colors internally
var _primary_1: Color = Color.WHITE
var _primary_2: Color = Color.WHITE
var _primary_3: Color = Color.WHITE

# Signal emitted when palette colors change
signal palette_updated

func _init():
	# Defer the update slightly to ensure export vars are set if loaded from .tres
	call_deferred("_update_primary_colors")

# Setters to trigger updates when exported vars change in editor
func _set_start_hue(new_hue: float):
	start_hue = fposmod(new_hue, 1.0) # Ensure hue wraps around
	if Engine.is_editor_hint(): # Avoid redundant calls during scene load
		call_deferred("_update_primary_colors") # Update in editor
	else:
		_update_primary_colors() # Update immediately in game

func _set_saturation(new_saturation: float):
	saturation = clampf(new_saturation, 0.0, 1.0)
	if Engine.is_editor_hint():
		call_deferred("_update_primary_colors")
	else:
		_update_primary_colors()

func _set_value(new_value: float):
	value = clampf(new_value, 0.0, 1.0)
	if Engine.is_editor_hint():
		call_deferred("_update_primary_colors")
	else:
		_update_primary_colors()

## Recalculates the three primary colors based on HSV parameters.
func _update_primary_colors():
	# Calculate hues equidistant on the color wheel
	var hue1 = fposmod(start_hue, 1.0)
	var hue2 = fposmod(start_hue + (1.0 / 3.0), 1.0)
	var hue3 = fposmod(start_hue + (2.0 / 3.0), 1.0)

	var p1 = Color.from_hsv(hue1, saturation, value)
	var p2 = Color.from_hsv(hue2, saturation, value)
	var p3 = Color.from_hsv(hue3, saturation, value)

	# Check if colors actually changed before updating and emitting signal
	if not _primary_1.is_equal_approx(p1) or \
	   not _primary_2.is_equal_approx(p2) or \
	   not _primary_3.is_equal_approx(p3):
		_primary_1 = p1
		_primary_2 = p2
		_primary_3 = p3
		print("Palette Updated: P1:", _primary_1, " P2:", _primary_2, " P3:", _primary_3) # Debug output
		palette_updated.emit()


## Returns the calculated first primary color.
func get_primary_1() -> Color:
	return _primary_1

## Returns the calculated second primary color.
func get_primary_2() -> Color:
	return _primary_2

## Returns the calculated third primary color.
func get_primary_3() -> Color:
	return _primary_3
