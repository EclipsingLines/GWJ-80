# Plan: Task 5 & 10 - Color Application and Blending Logic

This plan covers both the initial basic color application (Task 5) and the refined combinatorial blending logic (Task 10), acknowledging that Task 5 is a simplified placeholder.

## Task 5: Implement Basic Color Application (Overwrite/Initial Blend)

### 1. Goal (Task 5)

Implement a function in `GridSystem` that takes a `CardData` resource and a target grid coordinate, calculates the affected cells using the shape logic (Task 4), and applies the card's *basic* color to those cells. For this initial task, the application will **overwrite** any existing color.

### 2. Proposed Implementation (Task 5)

- **Modify `GridSystem` (`grid_system.gd`):**
  - **Add Signal:** Define a signal `grid_updated` to notify listeners (like `GridDisplay`) when cell data changes.

        ```gdscript
        signal grid_updated
        ```

  - **Add Function:** Create a new function `apply_card`.

        ```gdscript
        ## Applies a card's color to the grid based on its shape and position.
        ## For Task 5, this overwrites existing colors.
        ## Emits grid_updated signal upon completion.
        ## Returns true if application was successful (at least one cell affected).
        func apply_card(card: CardData, center_x: int, center_y: int) -> bool:
            if not card:
                push_warning("apply_card: Invalid CardData provided.")
                return false

            var affected_coords := get_affected_coordinates(card.shape, center_x, center_y)

            if affected_coords.is_empty():
                # Card placed entirely off-grid or shape is invalid
                return false

            var change_made := false
            for coord in affected_coords:
                var cell_data: CellData = get_cell_data(coord.x, coord.y)
                if cell_data:
                    # --- Task 5 Logic: Overwrite ---
                    cell_data.color = card.color
                    cell_data.blend_count = 1 # Simple count for now
                    # --- End Task 5 Logic ---
                    change_made = true

            if change_made:
                emit_signal("grid_updated")
                return true
            else:
                # Should not happen if affected_coords wasn't empty and coords were valid
                push_warning("apply_card: No changes made despite valid coordinates.")
                return false
        ```

- **Modify `main_game.gd`:**
  - Connect the `GridSystem.grid_updated` signal to the `GridDisplay.update_display` function.

        ```gdscript
        func _ready():
            # ... (existing code) ...
            if grid_system and grid_display:
                # Connect signal AFTER ensuring both nodes are ready
                if not grid_system.is_connected("grid_updated", Callable(self, "_on_grid_updated")):
                    grid_system.grid_updated.connect(_on_grid_updated)
            # ... (existing code for initial update) ...

        func _on_grid_updated():
            if grid_display and grid_system:
                grid_display.update_display(grid_system.get_grid_data())
            else:
                 push_error("MainGame: Cannot update display on grid_updated signal.")

        ```

        *(Note: The `await get_tree().process_frame` in `main_game.gd`'s `_ready` might need adjustment depending on signal timing, but let's start with this.)*

### 3. Testing (Task 5)

- Temporarily add code (e.g., in `main_game.gd`'s `_ready` or triggered by a key press) to call `grid_system.apply_card` with a sample card and position.
- Verify that the corresponding cells in the `GridDisplay` change to the card's color.

## Task 10: Refine Color Blending Logic (Implement 5-blend rule -> black)

### 1. Goal (Task 10)

Replace the simple overwrite logic in `apply_card` with the full combinatorial blending logic, where the resulting color depends on the composition of basic colors applied, and the 5th blend turns the cell black (resulting in a 36-color palette including White and Black).

### 2. Proposed Implementation (Task 10)

- **Refactor `CellData` (in `grid_system.gd`):**
  - Change `CellData` to store the count of each basic color applied, instead of just `color` and `blend_count`.

        ```gdscript
        class CellData:
            var r_count: int = 0 # Count of Red applications
            var g_count: int = 0 # Count of Green applications
            var b_count: int = 0 # Count of Blue applications
            var current_color: Color = Color.TRANSPARENT # Store calculated color for display

            func _init():
                 # Start transparent, counts are 0 by default
                 current_color = Color.TRANSPARENT

            func get_total_blends() -> int:
                 return r_count + g_count + b_count

            # Optional: Helper to get composition string key, e.g., "2R1G0B"
            func get_composition_key() -> String:
                 return "%dR%dG%dB" % [r_count, g_count, b_count]
        ```

- **Create `ColorBlender` Utility (`scr/utils/color_blender.gd`):**
  - **Palette Definition:** Define the 36-color palette. This is the most complex part. We need a mapping from composition (e.g., "0R0G0B", "1R0G0B", "2R1G0B") to the actual `Color` value.
    - Proposal: Use a static `Dictionary` within `ColorBlender`. The keys will be composition strings ("%dR%dG%dB"), and values will be `Color` objects.
    - **Crucial Sub-Task:** Define the 36 specific `Color` values for White, the 3 primaries, 6 secondaries, 10 tertiaries, 15 quaternaries, and Black. This requires careful color design. For the plan, we'll assume this dictionary `PALETTE` exists.
  - **Blending Function:** Create a static function `blend_color`.

        ```gdscript
        class_name ColorBlender
        extends RefCounted

        # --- Palette Definition (Crucial Sub-Task: Define these 36 colors!) ---
        const PALETTE: Dictionary = {
            "0R0G0B": Color.WHITE, # White (Blend 0)
            # Blend 1 (3 colors)
            "1R0G0B": Color(1, 0, 0), # Example: Pure Red
            "0R1G0B": Color(0, 1, 0), # Example: Pure Green
            "0R0G1B": Color(0, 0, 1), # Example: Pure Blue
            # Blend 2 (6 colors)
            "2R0G0B": Color(1, 0.2, 0.2), # Example: Lighter Red?
            "0R2G0B": Color(0.2, 1, 0.2),
            "0R0G2B": Color(0.2, 0.2, 1),
            "1R1G0B": Color(1, 1, 0), # Example: Yellow
            "1R0G1B": Color(1, 0, 1), # Example: Magenta
            "0R1G1B": Color(0, 1, 1), # Example: Cyan
            # Blend 3 (10 colors) - Need definitions
            "3R0G0B": Color.GRAY, "0R3G0B": Color.GRAY, "0R0G3B": Color.GRAY,
            "2R1G0B": Color.GRAY, "2R0G1B": Color.GRAY, "1R2G0B": Color.GRAY,
            "0R2G1B": Color.GRAY, "1R0G2B": Color.GRAY, "0R1G2B": Color.GRAY,
            "1R1G1B": Color.GRAY, # Example: White/Gray?
            # Blend 4 (15 colors) - Need definitions
            "4R0G0B": Color.DARK_GRAY, # ... many more ...
            "2R1G1B": Color.DARK_GRAY, # ...
            # Blend 5+ -> Black (Implicitly handled by check below)
        }
        const BLACK_COLOR = Color.BLACK

        ## Calculates the new color and composition after adding a basic color.
        ## Returns a Dictionary: {"new_comp_key": String, "new_color": Color}
        static func blend_color(r_count: int, g_count: int, b_count: int, added_color: Color) -> Dictionary:
            var new_r = r_count
            var new_g = g_count
            var new_b = b_count

            # Determine which basic color was added (needs robust check)
            if added_color == PALETTE["1R0G0B"]: # Assuming pure R card color matches palette
                new_r += 1
            elif added_color == PALETTE["0R1G0B"]:
                new_g += 1
            elif added_color == PALETTE["0R0G1B"]:
                new_b += 1
            else:
                push_warning("ColorBlender: Added color is not a recognized basic color.")
                # Return current state or handle error
                return {"new_comp_key": "%dR%dG%dB" % [r_count, g_count, b_count], "new_color": PALETTE.get("%dR%dG%dB" % [r_count, g_count, b_count], BLACK_COLOR)}

            total_blends = new_r + new_g + new_b

            if total_blends >= 5:
                # Return black, composition doesn't matter beyond this point for color
                return {"new_comp_key": "BLACK", "new_color": BLACK_COLOR}
            else:
                var new_key = "%dR%dG%dB" % [new_r, new_g, new_b]
                var new_color = PALETTE.get(new_key, BLACK_COLOR) # Default to black if key missing
                if new_color == BLACK_COLOR and new_key != "BLACK":
                     push_warning("ColorBlender: Composition key '%s' not found in PALETTE." % new_key)
                return {"new_comp_key": new_key, "new_color": new_color, "r": new_r, "g": new_g, "b": new_b}

        ```

- **Refactor `GridSystem.apply_card`:**
  - Modify the loop to use the `ColorBlender`.

        ```gdscript
        # Inside the loop in apply_card:
        var cell_data: CellData = get_cell_data(coord.x, coord.y)
        if cell_data:
            # --- Task 10 Logic: Combinatorial Blend ---
            var blend_result = ColorBlender.blend_color(cell_data.r_count, cell_data.g_count, cell_data.b_count, card.color)

            # Update CellData state
            cell_data.r_count = blend_result.get("r", cell_data.r_count) # Update counts if provided
            cell_data.g_count = blend_result.get("g", cell_data.g_count)
            cell_data.b_count = blend_result.get("b", cell_data.b_count)
            cell_data.current_color = blend_result["new_color"]
            # --- End Task 10 Logic ---
            change_made = true
        ```

- **Refactor `GridDisplay.update_display`:**
  - Update it to read `cell_data.current_color` instead of `cell_data.color`.

### 3. Testing (Task 10)

- Requires the 36-color `PALETTE` in `ColorBlender` to be fully defined.
- Test applying sequences of basic colors to a single cell and verify the resulting color matches the expected progression through the palette, eventually turning black on the 5th blend.
- Test applying cards over different existing colors.

## 4. Next Steps

1. Review this combined plan for Task 5 and Task 10.
2. Approve the plan or suggest modifications.
3. Once approved, I will request to switch to 'code' mode to implement Task 5 first. Task 10 implementation will follow later, likely after other core mechanics are in place, due to the complexity of defining the 36-color palette.
