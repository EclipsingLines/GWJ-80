# Revised Plan for Task 10: Implement Mathematically Derived Combinatorial Blending

This plan details the steps to implement a combinatorial color blending system where three primary colors are mathematically derived from base HSV parameters. Blended colors are calculated by averaging the RGB values of the unique primaries applied. Up to 3 colors can be blended; the 4th application turns the cell black.

## 1. Define Dynamic Color Palette Resource (`ColorPalette.gd`)

* **Action:** Modify the script `scr/resources/color_palette.gd`.
* **Purpose:** To define base parameters (hue, saturation, value) from which three primary colors are mathematically derived, allowing easy palette tuning.
* **Revised Script Content:**

    ```gdscript
    # scr/resources/color_palette.gd
    class_name ColorPalette
    extends Resource

    ## Starting hue for the first primary color (0.0 to 1.0).
    export var start_hue: float = 0.0: set = _set_start_hue
    ## Saturation for the primary colors (0.0 to 1.0).
    export var saturation: float = 1.0: set = _set_saturation
    ## Value (brightness) for the primary colors (0.0 to 1.0).
    export var value: float = 1.0: set = _set_value

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
    ```

* **Action:** Update the `resources/palettes/default_palette.tres` instance in the Godot editor. Set desired initial `start_hue`, `saturation`, `value`.

## 2. Modify Cell Data Resource (`CellData.gd`)

* *(No changes needed from the previous plan)*. The structure with `applied_colors: Array[Color]`, `display_color: Color`, and `is_blacked_out: bool` remains suitable. `applied_colors` will store the actual calculated primary colors applied.

## 3. Update Grid System (`GridSystem.gd`) - Palette Handling

* **Action:** Ensure `export var palette: ColorPalette` exists at the top of `scr/core/grid_system.gd`.
* **Action (User):** Assign `resources/palettes/default_palette.tres` to the `GridSystem` node's `Palette` property in the editor.
* **Action:** Connect to the palette's `palette_updated` signal in `_ready()` to trigger grid recalculation if the palette changes dynamically.

    ```gdscript
    # scr/core/grid_system.gd

    # ... (other variables) ...
    export var palette: ColorPalette

    func _ready() -> void:
        if palette:
            # Connect signal if not already connected
            if not palette.is_connected("palette_updated", Callable(self, "_on_palette_updated")):
                 palette.palette_updated.connect(_on_palette_updated)
            # Initial grid setup depends on palette, ensure palette is ready
            palette.call_deferred("_update_primary_colors") # Ensure colors are calculated initially
            call_deferred("initialize_grid") # Defer grid init slightly
        else:
            push_error("GridSystem requires a ColorPalette assigned in the editor!")
            initialize_grid() # Initialize with default white anyway

    func initialize_grid() -> void:
        # ... (rest of initialization) ...
        # Ensure cells start with correct default based on potential palette updates
        _on_palette_updated() # Force initial calculation/redraw


    func _on_palette_updated():
        # Recalculate all cell display colors based on the new palette
        print("GridSystem: Palette updated, recalculating grid colors...")
        var change_made = false
        # Ensure grid_data is initialized before proceeding
        if grid_data.is_empty():
             push_warning("GridSystem: _on_palette_updated called before grid initialized.")
             return

        for y in range(Constants.GRID_HEIGHT):
            for x in range(Constants.GRID_WIDTH):
                var cell: CellData = get_cell_data(x, y)
                if cell and not cell.is_blacked_out:
                    # Recalculate display color based on existing applied_colors sequence
                    var new_display_color = _calculate_display_color(cell.applied_colors)
                    if not cell.display_color.is_equal_approx(new_display_color):
                        cell.display_color = new_display_color
                        change_made = true
        if change_made:
            grid_updated.emit() # Signal UI to redraw
    ```

## 4. Revise Color Calculation Logic (`_calculate_display_color` in `GridSystem.gd`)

* **Action:** Replace the `_calculate_display_color` function in `scr/core/grid_system.gd`.
* **Purpose:** To calculate the display color by averaging the RGB values of the unique primary colors present in the sequence.
* **Revised Function:**

    ```gdscript
    ## Calculates the display color by averaging the RGB values of the unique primary colors
    ## present in the applied sequence, based on the active palette.
    func _calculate_display_color(applied_sequence: Array[Color]) -> Color:
        if not palette:
            push_error("GridSystem: No ColorPalette assigned!")
            return Color.MAGENTA # Error color

        if applied_sequence.is_empty():
            return Color.WHITE

        var unique_primaries: Array[Color] = []
        var p1 = palette.get_primary_1()
        var p2 = palette.get_primary_2()
        var p3 = palette.get_primary_3()

        # Identify which unique primaries are in the sequence using approximate comparison
        var has_p1 = false
        var has_p2 = false
        var has_p3 = false

        for color_in_sequence in applied_sequence:
            if not has_p1 and color_in_sequence.is_equal_approx(p1):
                unique_primaries.append(p1)
                has_p1 = true
            elif not has_p2 and color_in_sequence.is_equal_approx(p2):
                unique_primaries.append(p2)
                has_p2 = true
            elif not has_p3 and color_in_sequence.is_equal_approx(p3):
                unique_primaries.append(p3)
                has_p3 = true # Optimization: stop checking once all 3 found?

        if unique_primaries.is_empty():
             push_warning("No valid primary colors identified in sequence: %s" % applied_sequence)
             return Color.GRAY # Fallback color

        # Calculate the average RGB color
        var sum_color := Color(0, 0, 0, 1)
        for primary_color in unique_primaries:
            sum_color += primary_color

        # Average the color components
        var count = float(unique_primaries.size())
        var avg_color = Color(sum_color.r / count, sum_color.g / count, sum_color.b / count, 1.0)

        return avg_color
    ```

## 5. Revise `apply_card` Function (in `GridSystem.gd`)

* **Action:** Modify the logic within the `for coord in affected_coords:` loop in `scr/core/grid_system.gd`.
* **Purpose:** To use the dynamically calculated primary colors for comparison and apply the 3-blend/4th-blackout rule.
* **Revised Logic Snippet:**

    ```gdscript
    # Inside the loop in apply_card(card, center_x, center_y)
    var cell_data: CellData = get_cell_data(coord.x, coord.y)
    if cell_data:
        if cell_data.is_blacked_out:
            continue # Skip blacked-out cells

        # Ensure palette is available
        if not palette:
            push_error("Apply Card: Palette not set in GridSystem!")
            continue

        var current_sequence_size = cell_data.applied_colors.size()

        if current_sequence_size < 4: # Allow up to 3 blends before blackout
            var card_primary_color: Color # Store the primary this card represents
            var is_valid_primary = false
            var p1 = palette.get_primary_1()
            var p2 = palette.get_primary_2()
            var p3 = palette.get_primary_3()

            # Identify which primary the card's color matches (use approximate comparison)
            if card.color.is_equal_approx(p1):
                card_primary_color = p1
                is_valid_primary = true
            elif card.color.is_equal_approx(p2):
                card_primary_color = p2
                is_valid_primary = true
            elif card.color.is_equal_approx(p3):
                card_primary_color = p3
                is_valid_primary = true

            if is_valid_primary:
                if current_sequence_size < 3: # Apply normally (0, 1, or 2 colors present)
                    cell_data.applied_colors.append(card_primary_color) # Store the identified primary
                    cell_data.display_color = _calculate_display_color(cell_data.applied_colors)
                    change_made = true
                else: # This is the 4th application (current_sequence_size == 3)
                    # cell_data.applied_colors.append(card_primary_color) # Optional: Store 4th color?
                    cell_data.display_color = Color.BLACK
                    cell_data.is_blacked_out = true
                    # cell_data.applied_colors.clear() # Optional: Clear sequence?
                    change_made = true
            else:
                push_warning("Attempted to apply non-primary color: %s. Expected one of %s, %s, %s" % [card.color, p1, p2, p3])
    ```

## 6. Update Card Definitions

* **Requirement:** The system now relies on `CardData` resources having their `color` property set to one of the *exact calculated primary colors* from the active palette.
* **Action (User/Separate Task):** Review and update any scripts or resources responsible for creating/defining cards (e.g., deck lists, card database). Ensure they fetch the current primary colors from the palette (`palette.get_primary_1()`, etc.) when assigning colors to cards.

## 7. Testing

* Test applying the 3 primary color cards individually.
* Test blending two different primaries (e.g., P1 then P2) - check if the color is the RGB average.
* Test blending three different primaries (P1, P2, P3) - check if the color is the RGB average.
* Test applying the same primary multiple times (e.g., P1, P1) - check if the display color remains P1.
* Test the 4th blend turning the cell black.
* Test applying a 5th color to a black cell (should have no effect).
* Test changing the `start_hue`, `saturation`, or `value` in the `default_palette.tres` resource *while the game is running*. Verify that the grid cell colors update automatically and correctly reflect the new palette and blends.

## 8. User Review & Approval

* Present this revised plan document to the user for final review and approval.

## 9. Implementation Mode Switch

* Once the plan is approved, request to switch to "Code" mode to perform the file modifications.

```mermaid
flowchart TD
    subgraph PaletteSetup
        A[Revise ColorPalette Script: Use HSV inputs, calculate primaries] --> B(Update default_palette.tres Instance)
    end

    subgraph GridSystemIntegration
        C[Export Palette in GridSystem] --> D(User Assigns Palette in Editor)
        E[Connect palette_updated Signal in GridSystem._ready] --> F(Implement _on_palette_updated Handler)
    end

    subgraph BlendingLogic
        G[Revise _calculate_display_color: Average unique primary RGBs] --> H[Revise apply_card: Compare card to calculated primaries, use 3-blend/4th-blackout rule]
    end

    subgraph Dependencies & Finalization
        I[User Action: Ensure CardData colors match calculated primaries]
        J[Testing: Blends, blackout, dynamic palette changes]
        K[User Review & Approval of Plan] --> L[Switch to Code Mode for Implementation]
    end

    PaletteSetup --> GridSystemIntegration
    PaletteSetup --> BlendingLogic
    GridSystemIntegration --> BlendingLogic
    BlendingLogic --> I
    I --> J
    J --> K
