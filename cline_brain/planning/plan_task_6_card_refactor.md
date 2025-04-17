# Plan: Refactor Card UI and Add 3x3 Visualization

**Task:** Refactor the card object creation out of `HandUI.gd` into its own scene/script, and add a 3x3 grid visualization representing the card's shape and color, using Godot UI Themes for styling.

**Current State:**

* Card data is defined in `scr/resources/card_data.gd` (Resource with `shape: Shape` enum and `color: Color`).
* Card UI nodes (`Button` + `ColorRect`) are created procedurally within `scenes/ui/HandUI.gd` in the `_create_card_node` function.
* Styling is basic and not theme-driven.

**Proposed Changes:**

1. **New Scene: `scenes/ui/card_ui.tscn`**
    * A dedicated scene for representing a single card in the UI.
    * **Structure:**

        ```mermaid
        graph TD
            CardUI(CardUI [Control/PanelContainer]) --> Btn(Button)
            CardUI --> Grid(GridContainer 3x3)
            Grid --> C1(ColorRect)
            Grid --> C2(ColorRect)
            Grid --> C3(ColorRect)
            Grid --> C4(ColorRect)
            Grid --> C5(ColorRect)
            Grid --> C6(ColorRect)
            Grid --> C7(ColorRect)
            Grid --> C8(ColorRect)
            Grid --> C9(ColorRect)
        ```

2. **New Script: `scenes/ui/card_ui.gd`**
    * Attached to the root of `card_ui.tscn`.
    * `class_name CardUI`.
    * `@export var card_data: CardData`: Holds the data for the card to display.
    * `signal card_pressed(card_data: CardData)`: Emitted when the card's button is pressed.
    * `func update_display()`: Updates the 3x3 grid `ColorRect` colors based on `card_data.shape` and `card_data.color`. Uses theme colors for inactive cells.
    * `func _on_button_pressed()`: Internal handler for the Button's `pressed` signal; emits `card_pressed`.

3. **Refactor: `scenes/ui/HandUI.gd`**
    * Preload `card_ui.tscn`.
    * Modify `_create_card_node` to `instantiate()` the `CardUIScene`, set its `card_data`, and connect its `card_pressed` signal.
    * Rename `_on_card_pressed` to `_on_card_selected` and update it to receive `CardData` from the signal.

4. **Grid Logic (in `card_ui.gd`)**
    * Implement logic (e.g., a dictionary or `match` statement) to map `CardData.Shape` enums to a 9-element boolean pattern representing the 3x3 grid.
    * Use this pattern in `update_display()` to color the `ColorRect`s.

5. **Theming**
    * Apply the project's UI Theme to `card_ui.tscn`.
    * Use theme properties (e.g., `theme_override_colors/background_color`) for inactive grid cells and potentially active cell borders/backgrounds if desired. Style the `Button` via the theme.

**Implementation Steps:**

1. Create `scenes/ui/card_ui.tscn` with the node structure outlined above.
2. Create `scenes/ui/card_ui.gd`, attach it, and implement the basic structure (exports, signals, empty functions).
3. Implement the `update_display()` function in `card_ui.gd`, including the shape-to-grid mapping logic.
4. Implement the signal handling (`_on_button_pressed` and emitting `card_pressed`) in `card_ui.gd`.
5. Refactor `scenes/ui/HandUI.gd` to use the new `CardUIScene`.
6. Ensure UI Theme properties are correctly applied and used in `card_ui.tscn` and `card_ui.gd`.
7. Test the changes by running the game and verifying hand display and card selection.

**Next Step:** Review this plan. Once approved, switch to "Code" mode to implement the changes.
