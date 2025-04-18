# Plan: Task 12 - Target Image Loading, Processing, and Display

This plan outlines the steps to implement the functionality for loading target images, processing them into 7x9 level blocks with mapped colors, and displaying the current target block in the UI.

**Goals:**

1. Define a Godot Resource (`LevelData`) to store processed 7x9 level target data.
2. Create an image processing utility to load images, break them into 7x9 blocks, map colors to the game's palette, and save them as `LevelData` resources.
3. Create a dedicated UI scene (`TargetDisplay`) to visualize a `LevelData` resource.
4. Integrate the loading and display of a random `LevelData` target into the main game flow.

**Assumptions:**

* Input images will be placed in `assets/levels/`.
* The game uses the `GameColorPalette` resource (`res://resources/default_palette.tres`) to define the 3 primary colors.
* The effective color palette for mapping consists of 9 colors: White, Primary 1, Primary 2, Primary 3, Blend(P1,P2), Blend(P1,P3), Blend(P2,P3), Blend(P1,P2,P3), and Black.
* Color mapping will use the closest color based on HSV distance (primarily hue).
* The `TargetDisplay` scene will be manually added by the user to a horizontal container within the existing `grid_display` scene or similar UI structure.

**Plan Details:**

**Step 1: Define `LevelData` Resource**

* Create a new script: `scr/resources/level_data.gd`
* Define the script:

    ```gdscript
    # scr/resources/level_data.gd
    class_name LevelData
    extends Resource

    ## Stores the 7x9 grid of target colors after palette mapping.
    ## Stored as a flat array (row-major order) for simplicity.
    @export var target_colors: Array[Color] = []

    ## Optional: Store original image path and block index for reference
    # @export var source_image_path: String = ""
    # @export var source_block_index: int = -1

    func _init():
        # Ensure array is initialized with the correct size (7x9 = 63)
        if target_colors.size() != Constants.GRID_WIDTH * Constants.GRID_HEIGHT:
            target_colors.resize(Constants.GRID_WIDTH * Constants.GRID_HEIGHT)
            # Optional: Initialize with a default color like white?
            # target_colors.fill(Color.WHITE)

    # Helper function to get color at specific coordinates
    func get_color(x: int, y: int) -> Color:
        if x >= 0 and x < Constants.GRID_WIDTH and y >= 0 and y < Constants.GRID_HEIGHT:
            var index = y * Constants.GRID_WIDTH + x
            if index < target_colors.size():
                return target_colors[index]
        return Color.MAGENTA # Error color
    ```

* *(No file system changes in this step, just defining the class)*

**Step 2: Create Image Processor Resource**

* Modify the script `scr/utils/image_processor.gd` to be a `@tool` script extending `Resource`.
* Define the script:

    ```gdscript
    # scr/utils/image_processor.gd
    @tool
    class_name ImageProcessor
    extends Resource

    const LevelData = preload("res://scr/resources/level_data.gd")
    const Constants = preload("res://scr/utils/constants.gd")
    const GameColorPalette = preload("res://scr/resources/color_palette.gd") # Assuming this path

    ## The source image texture to process.
    @export var source_texture: Texture2D
    ## The color palette to use for mapping.
    @export var palette: GameColorPalette
    ## The directory where generated LevelData resources will be saved.
    @export_dir var output_directory: String = "res://resources/levels/"

    # --- Processing Trigger ---

    ## Call this function via the button in the Inspector to generate levels.
    @button("Generate Level Resources")
    func generate_level_resources():
        if not source_texture:
            push_error("ImageProcessor: Source Texture not set.")
            return
        if not palette:
            push_error("ImageProcessor: Palette not set.")
            return
        if output_directory.is_empty() or not output_directory.begins_with("res://"):
            push_error("ImageProcessor: Output Directory must be a valid 'res://' path.")
            return

        # Ensure output directory exists
        var dir_access := DirAccess.open("res://")
        var err := dir_access.make_dir_recursive(output_directory)
        if err != OK:
            push_error("ImageProcessor: Failed to create output directory '%s'. Error: %s" % [output_directory, error_string(err)])
            return

        # Get the Image data from the Texture2D
        var source_image: Image = source_texture.get_image()
        if not source_image or source_image.is_empty():
            push_error("ImageProcessor: Could not get valid Image data from Source Texture.")
            return

        var img_width := source_image.get_width()
        var img_height := source_image.get_height()

        # Calculate number of blocks needed (can overlap)
        var num_blocks_x := int(ceil(img_width / float(Constants.GRID_WIDTH))) if img_width > 0 else 0
        var num_blocks_y := int(ceil(img_height / float(Constants.GRID_HEIGHT))) if img_height > 0 else 0

        print("Processing texture '%s' (%dx%d) into %dx%d blocks..." % [source_texture.resource_path, img_width, img_height, num_blocks_x, num_blocks_y])

        var block_count = 0
        var palette_colors := _get_palette_colors(palette) # Pre-calculate palette colors

        if palette_colors.is_empty():
            push_error("ImageProcessor: Failed to calculate palette colors.")
            return

        for block_y in range(num_blocks_y):
            for block_x in range(num_blocks_x):
                var start_x := block_x * Constants.GRID_WIDTH
                var start_y := block_y * Constants.GRID_HEIGHT

                # Define the extraction region
                var extraction_rect := Rect2i(start_x, start_y, Constants.GRID_WIDTH, Constants.GRID_HEIGHT)

                # Extract the block (Godot clamps the region automatically)
                var image_block := source_image.get_region(extraction_rect)

                if not image_block or image_block.is_empty():
                    push_warning("ImageProcessor: Extracted empty or invalid image block at (%d, %d)." % [block_x, block_y])
                    continue

                # Process the potentially smaller image block
                var mapped_colors := _process_image_block(image_block, palette_colors)
                if mapped_colors.is_empty():
                    push_warning("ImageProcessor: Failed to process image block at (%d, %d)." % [block_x, block_y])
                    continue # Skip saving if processing failed

                # Create and save the LevelData resource
                var level_data := LevelData.new()
                level_data.target_colors = mapped_colors

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


    # --- Helper Functions (Internal) ---

    func _get_palette_colors(palette_res: GameColorPalette) -> Array[Color]:
        # [Implementation as before]
        if not palette_res: return []
        var p1 := palette_res.get_primary_1()
        var p2 := palette_res.get_primary_2()
        var p3 := palette_res.get_primary_3()
        var blend12 := _calculate_blend_color([p1, p2])
        var blend13 := _calculate_blend_color([p1, p3])
        var blend23 := _calculate_blend_color([p2, p3])
        var blend123 := _calculate_blend_color([p1, p2, p3])
        return [Color.WHITE, p1, p2, p3, blend12, blend13, blend23, blend123, Color.BLACK]


    func _find_closest_palette_color(pixel_color: Color, palette_colors_arr: Array[Color]) -> Color:
        # [Implementation as before]
        if palette_colors_arr.is_empty(): return Color.MAGENTA
        if pixel_color.a < 0.9: pixel_color = Color.WHITE
        if pixel_color == Color.WHITE: return Color.WHITE
        if pixel_color == Color.BLACK: return Color.BLACK
        for p_color in palette_colors_arr:
            if pixel_color.is_equal_approx(p_color): return p_color

        var min_dist: float = INF
        var closest_color: Color = palette_colors_arr[0]
        var pixel_h: float = pixel_color.h
        var pixel_s: float = pixel_color.s
        var pixel_v: float = pixel_color.v

        for p_color in palette_colors_arr:
            if p_color == Color.WHITE or p_color == Color.BLACK: continue
            var p_h: float = p_color.h
            var p_s: float = p_color.s
            var p_v: float = p_color.v
            var hue_diff = abs(pixel_h - p_h)
            var hue_dist = min(hue_diff, 1.0 - hue_diff)
            var dist = hue_dist * 0.8 + abs(pixel_s - p_s) * 0.1 + abs(pixel_v - p_v) * 0.1
            if dist < min_dist:
                min_dist = dist
                closest_color = p_color

        var white_dist = abs(pixel_v - Color.WHITE.v) + abs(pixel_s - Color.WHITE.s) * 0.2
        var black_dist = abs(pixel_v - Color.BLACK.v) + abs(pixel_s - Color.BLACK.s) * 0.2

        if white_dist < min_dist and white_dist < black_dist: closest_color = Color.WHITE
        elif black_dist < min_dist and black_dist < white_dist: closest_color = Color.BLACK
        return closest_color


    func _process_image_block(image_block: Image, palette_colors_arr: Array[Color]) -> Array[Color]:
        # [Implementation as before, using palette_colors_arr directly]
        if not image_block or image_block.is_empty(): return []
        if palette_colors_arr.is_empty(): return []

        var mapped_white := _find_closest_palette_color(Color.WHITE, palette_colors_arr)
        var result_colors: Array[Color] = []
        result_colors.resize(Constants.GRID_WIDTH * Constants.GRID_HEIGHT)
        result_colors.fill(mapped_white)
        var block_width = image_block.get_width()
        var block_height = image_block.get_height()

        for y in range(block_height):
            for x in range(block_width):
                if x >= Constants.GRID_WIDTH or y >= Constants.GRID_HEIGHT: continue
                var pixel_color := image_block.get_pixel(x, y)
                var mapped_color := _find_closest_palette_color(pixel_color, palette_colors_arr)
                var index = y * Constants.GRID_WIDTH + x
                result_colors[index] = mapped_color
        return result_colors


    func _calculate_blend_color(colors_to_blend: Array[Color]) -> Color:
        # [Implementation as before]
        if colors_to_blend.is_empty(): return Color.WHITE
        var sum_color := Color(0, 0, 0, 1)
        for c in colors_to_blend: sum_color += c
        var count = float(colors_to_blend.size())
        if count > 0: return Color(sum_color.r / count, sum_color.g / count, sum_color.b / count, 1.0)
        else: return Color.WHITE
    ```

* **Usage:**
    1. Create a new resource in the FileSystem dock (Right-click -> New Resource...).
    2. Search for `ImageProcessor` and create it (e.g., `res://image_processors/my_level_processor.tres`).
    3. Select the created resource file.
    4. In the Inspector, assign your source `Texture2D` (e.g., from `assets/levels/`), the `GameColorPalette` resource (`res://resources/default_palette.tres`), and verify the `Output Directory`.
    5. Click the "Generate Level Resources" button that appears in the Inspector.
    6. Check the `res://resources/levels/` directory (or your specified output) for the generated `_block_X_Y.tres` files.

**Step 3: Create Target Display Scene**

* Create a new scene: `scenes/ui/target_display.tscn`
* Set the root node type to `Control`.
* Add a script to the root node: `scenes/ui/target_display.gd`
* Define the script:

    ```gdscript
    # scenes/ui/target_display.gd
    @tool # Optional: To see preview in editor
    class_name TargetDisplay
    extends Control

    @export var level_data: LevelData: set = _set_level_data

    # Configure cell size based on Constants or export vars
    @export var cell_size := Vector2i(10, 10) # Example size, adjust as needed
    @export var cell_spacing: int = 1

    func _set_level_data(new_data: LevelData):
        level_data = new_data
        # Trigger redraw if the node is ready
        if is_inside_tree():
            queue_redraw()

    func _draw():
        if not level_data:
            # Draw placeholder if no data
            draw_rect(Rect2(Vector2.ZERO, size), Color.DARK_GRAY, true)
            return

        var draw_pos := Vector2.ZERO
        for y in range(Constants.GRID_HEIGHT):
            draw_pos.x = 0
            for x in range(Constants.GRID_WIDTH):
                var color = level_data.get_color(x, y)
                var rect = Rect2(draw_pos, cell_size)
                draw_rect(rect, color, true)
                draw_pos.x += cell_size.x + cell_spacing
            draw_pos.y += cell_size.y + cell_spacing

        # Optional: Update minimum size based on calculated grid size
        var total_width = Constants.GRID_WIDTH * cell_size.x + (Constants.GRID_WIDTH - 1) * cell_spacing
        var total_height = Constants.GRID_HEIGHT * cell_size.y + (Constants.GRID_HEIGHT - 1) * cell_spacing
        custom_minimum_size = Vector2(total_width, total_height)

    func _ready():
        # Initial draw when ready
        queue_redraw()

    ```

* *(This creates `target_display.tscn` and `target_display.gd`)*

**Step 4: Integrate into Game**

* Identify the main game scene/script (e.g., `scenes/main_game.gd`).
* **Add Level Loading Logic:**
  * In `_ready()` or a dedicated level setup function:
    * Scan the `res://resources/levels/` directory for `.tres` files.
    * Load each valid `LevelData` resource found using `load()`.
    * Store these loaded `LevelData` resources in an array (e.g., `available_levels`).
* **Add Level Selection Logic:**
  * When starting a new level/round:
    * Check if `available_levels` is not empty.
    * Select a random `LevelData` from the `available_levels` array. Store it in a variable (e.g., `current_level_data`).
* **Add Target Display Instantiation:**
  * Preload the `TargetDisplay` scene: `const TargetDisplayScene = preload("res://scenes/ui/target_display.tscn")`
  * Get a reference to the container node where the target display should be added (user needs to ensure this container exists, e.g., `@onready var target_display_container = $Path/To/HBoxContainer`).
  * Clear any previous target display from the container.
  * Instantiate the `TargetDisplayScene`: `var target_instance = TargetDisplayScene.instantiate()`
  * Set the loaded level data: `target_instance.level_data = current_level_data`
  * Add the instance to the container: `target_display_container.add_child(target_instance)`

**Mermaid Diagram:**

```mermaid
graph TD
    subgraph Pre-processing [Image Pre-processing (Editor Resource)]
        A(ImageProcessor Resource *.tres) --> B[@tool Script scr/utils/image_processor.gd];
        A -- Has Exports --> C[source_texture: Texture2D];
        A -- Has Exports --> D[palette: GameColorPalette];
        A -- Has Exports --> E[output_directory: String];
        A -- Has Inspector Button --> F[generate_level_resources()];
        F -- Uses --> C;
        F -- Uses --> D;
        F -- Uses --> E;
        F -- Gets Image --> G[source_image: Image];
        G --> H{Break into 7x9 Blocks};
        H --> I{For each Block};
        I --> J[Map Pixels to Palette (HSV)];
        J --> K[Create LevelData Resource];
        K -- Saves --> L[LevelData.tres in output_directory];
        I --> L;
    end

    subgraph Gameplay [Gameplay Logic (e.g., main_game.gd)]
        G[Scan & Load LevelData.tres from resources/levels/] --> H{Select Random LevelData};
        H --> I[Instantiate TargetDisplay Scene];
        I --> J[Set level_data Export Variable];
        J --> K[Add TargetDisplay to UI Container];
    end

    subgraph TargetDisplay [TargetDisplay Scene (target_display.tscn)]
        L(Control Root Node) -- Contains --> M(target_display.gd Script);
        M -- Has Export --> N[level_data: LevelData];
        M -- Reads --> N;
        M -- Draws --> O(7x9 Visual Grid);
    end

    subgraph Resources
        P(level_data.gd) -- Defines --> Q(LevelData Resource);
        Q -- Stores --> R[Array[Color] (7x9)];
        S(ImageProcessor Resource *.tres) -- Triggers --> T{Processing Logic via @button};
    end

    L --> G;
    N -.-> Q;
```

**Next Steps:**

1. Review this plan.
2. Confirm if this plan aligns with your expectations.
3. If approved, I will request to switch to "Code" mode to implement these steps.
