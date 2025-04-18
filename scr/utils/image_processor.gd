# scr/utils/image_processor.gd
# @tool Resource script to process a source Texture2D into LevelData resources.
@tool
class_name ImageProcessor
extends Resource

# --- Exports ---
var main_level_scene = preload("res://scenes/main_game.tscn")
## The source image texture to process.
@export var source_texture: Texture2D
## The color palette to use for mapping.
@export var palette: GameColorPalette
## The directory where generated LevelData resources will be saved.
@export_dir var output_directory: String = "res://resources/levels/"

# --- Processing Trigger---
@export_tool_button("Process IMG", "Callable") var generate: Callable = _generate_level_resources_internal

## Internal function called by the setter to perform the generation.
func _generate_level_resources_internal():
	# --- Input Validation ---
	if not source_texture:
		push_error("ImageProcessor: Source Texture not set.")
		return
	if not palette:
		push_error("ImageProcessor: Palette not set.")
		return
	if output_directory.is_empty() or not output_directory.begins_with("res://"):
		push_error("ImageProcessor: Output Directory must be a valid 'res://' path.")
		return

	# --- Ensure Output Directory ---
	var dir_access := DirAccess.open("res://")
	var err := dir_access.make_dir_recursive(output_directory)
	if err != OK and err != ERR_ALREADY_EXISTS: # Allow if directory already exists
		push_error("ImageProcessor: Failed to create/access output directory '%s'. Error: %s" % [output_directory, error_string(err)])
		return

	# --- Get Image Data ---
	var source_image: Image = source_texture.get_image()
	if not source_image or source_image.is_empty():
		push_error("ImageProcessor: Could not get valid Image data from Source Texture.")
		return

	var img_width := source_image.get_width()
	var img_height := source_image.get_height()

	# --- Calculate Blocks ---
	var num_blocks_x := int(ceil(img_width / float(Constants.GRID_WIDTH))) if img_width > 0 else 0
	var num_blocks_y := int(ceil(img_height / float(Constants.GRID_HEIGHT))) if img_height > 0 else 0

	print("Processing texture '%s' (%dx%d) into %dx%d blocks..." % [source_texture.resource_path, img_width, img_height, num_blocks_x, num_blocks_y])

	# --- Pre-calculate Palette Colors ---
	var palette_colors := _get_palette_colors(palette)
	if palette_colors.is_empty():
		push_error("ImageProcessor: Failed to calculate palette colors.")
		return

	# --- Process Each Block ---
	var block_count = 0
	for block_y in range(num_blocks_y):
		for block_x in range(num_blocks_x):
			var start_x := block_x * Constants.GRID_WIDTH
			var start_y := block_y * Constants.GRID_HEIGHT

			# Define and extract the block region
			var extraction_rect := Rect2i(start_x, start_y, Constants.GRID_WIDTH, Constants.GRID_HEIGHT)
			var image_block := source_image.get_region(extraction_rect) # Godot clamps automatically

			if not image_block or image_block.is_empty():
				push_warning("ImageProcessor: Extracted empty or invalid image block at (%d, %d)." % [block_x, block_y])
				continue

			# Process the block (potentially smaller than 7x9)
			var mapped_colors := _process_image_block(image_block, palette_colors)
			if mapped_colors.is_empty():
				push_warning("ImageProcessor: Failed to process image block at (%d, %d)." % [block_x, block_y])
				continue

			# --- Create and Save LevelData Resource ---
			var level_data := LevelData.new()
			level_data.target_colors = mapped_colors
			level_data.source_block_index = block_count
			var block_complexity = 0
			var cell_score:Array[int] = []
			for color in mapped_colors:
				if color == Color.WHITE:
					cell_score.append(3)
					continue
				elif color == palette.get_primary_1() or color == palette.get_primary_2() or color == palette.get_primary_3():
					cell_score.append(15)
					block_complexity += 1
				elif color == Color.BLACK:
					cell_score.append(42)
					block_complexity += 15
				else:
					cell_score.append(33)
					block_complexity += 10
			level_data.complexity = block_complexity
			level_data.cell_scores = cell_score

			var base_filename := source_texture.resource_path.get_file().get_basename()
			var output_filename := "%s_block_%d_%d.tres" % [base_filename, block_x, block_y]
			var output_path := output_directory.path_join(output_filename)

			# Use ResourceSaver.save with flags to ensure editor updates
			err = ResourceSaver.save(level_data, output_path, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
			if err != OK:
				push_error("ImageProcessor: Failed to save LevelData resource to '%s'. Error: %s" % [output_path, error_string(err)])
			else:
				block_count += 1
				

	print("Finished processing '%s'. Saved %d level blocks to '%s'." % [source_texture.resource_path, block_count, output_directory])
	# Optional: Force a scan of the filesystem to make sure the editor sees the new files immediately
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
		notify_property_list_changed()


# --- Helper Functions (Internal - marked with underscore) ---

## Calculates and returns the 9 effective palette colors.
func _get_palette_colors(palette_res: GameColorPalette) -> Array[Color]:
	if not palette_res: return [] # Basic check
	var p1 := palette_res.get_primary_1()
	var p2 := palette_res.get_primary_2()
	var p3 := palette_res.get_primary_3()
	var blend12 := _calculate_blend_color([p1, p2])
	var blend13 := _calculate_blend_color([p1, p3])
	var blend23 := _calculate_blend_color([p2, p3])
	var blend123 := _calculate_blend_color([p1, p2, p3])
	return [Color.WHITE, p1, p2, p3, blend12, blend13, blend23, blend123, Color.BLACK]


## Finds the closest color in the provided palette array using HSV distance.
func _find_closest_palette_color(pixel_color: Color, palette_colors_arr: Array[Color]) -> Color:
	if palette_colors_arr.is_empty(): return Color.MAGENTA # Error color

	# Handle transparency -> White
	if pixel_color.a < 0.9: pixel_color = Color.WHITE

	# Check exact common cases first
	if pixel_color == Color.WHITE: return Color.WHITE
	if pixel_color == Color.BLACK: return Color.BLACK
	for p_color in palette_colors_arr:
		if pixel_color.is_equal_approx(p_color): return p_color

	# HSV Comparison
	var min_dist: float = INF
	var closest_color: Color = palette_colors_arr[0] # Default
	var pixel_h: float = pixel_color.h
	var pixel_s: float = pixel_color.s
	var pixel_v: float = pixel_color.v

	for p_color in palette_colors_arr:
		if p_color == Color.WHITE or p_color == Color.BLACK: continue # Skip unstable hues

		var p_h: float = p_color.h
		var p_s: float = p_color.s
		var p_v: float = p_color.v

		# Hue distance (circular)
		var hue_diff = abs(pixel_h - p_h)
		var hue_dist = min(hue_diff, 1.0 - hue_diff)

		# Weighted distance (adjust weights if needed)
		var dist = hue_dist * 0.8 + abs(pixel_s - p_s) * 0.1 + abs(pixel_v - p_v) * 0.1
		if dist < min_dist:
			min_dist = dist
			closest_color = p_color

	# Final check against White/Black based on Value/Saturation distance
	var white_dist = abs(pixel_v - Color.WHITE.v) + abs(pixel_s - Color.WHITE.s) * 0.2
	var black_dist = abs(pixel_v - Color.BLACK.v) + abs(pixel_s - Color.BLACK.s) * 0.2

	if white_dist < min_dist and white_dist < black_dist: closest_color = Color.WHITE
	elif black_dist < min_dist and black_dist < white_dist: closest_color = Color.BLACK

	return closest_color


## Processes a single image block (potentially smaller than 7x9) into a 63-element color array.
func _process_image_block(image_block: Image, palette_colors_arr: Array[Color]) -> Array[Color]:
	if not image_block or image_block.is_empty(): return []
	if palette_colors_arr.is_empty(): return []

	# Pad with mapped White
	var mapped_white := _find_closest_palette_color(Color.WHITE, palette_colors_arr)
	var result_colors: Array[Color] = []
	result_colors.resize(Constants.GRID_WIDTH * Constants.GRID_HEIGHT)
	result_colors.fill(mapped_white)

	var block_width = image_block.get_width()
	var block_height = image_block.get_height()

	# Iterate within actual block bounds
	for y in range(block_height):
		for x in range(block_width):
			# Safety check against target grid size (shouldn't be needed with get_region)
			if x >= Constants.GRID_WIDTH or y >= Constants.GRID_HEIGHT: continue

			var pixel_color := image_block.get_pixel(x, y)
			var mapped_color := _find_closest_palette_color(pixel_color, palette_colors_arr)
			var index = y * Constants.GRID_WIDTH + x
			result_colors[index] = mapped_color
	return result_colors


## Calculates the average RGB color of the input colors.
func _calculate_blend_color(colors_to_blend: Array[Color]) -> Color:
	if colors_to_blend.is_empty(): return Color.WHITE
	var sum_color := Color(0, 0, 0, 1)
	for c in colors_to_blend: sum_color += c
	var count = float(colors_to_blend.size())
	if count > 0: return Color(sum_color.r / count, sum_color.g / count, sum_color.b / count, 1.0)
	else: return Color.WHITE # Should not happen
