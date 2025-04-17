# Plan: Task 4 - Implement Card Shapes Logic

## 1. Goal

Implement the logic within the `GridSystem` to determine the set of absolute grid coordinates affected by placing a card of a specific shape (`O`, `PLUS`, `XLine`, `YLine`, `XShape`) at a given center coordinate.

## 2. Proposed Implementation

### 2.1 Define Shape Patterns

We need to define the relative coordinates covered by each shape, assuming the placement coordinate is the center (0,0).

- **`O` Shape:** Perimeter of a 3x3 square (excludes center).
  - Relative Coordinates: `[(-1,-1), (0,-1), (1,-1), (-1,0), (1,0), (-1,1), (0,1), (1,1)]`
- **`PLUS` Shape:** A standard 3x3 plus sign.
  - Relative Coordinates: `[(0,-1), (-1,0), (0,0), (1,0), (0,1)]`
- **`XLine` Shape:** Horizontal 3-cell line centered.
  - Relative Coordinates: `[(-1,0), (0,0), (1,0)]`
- **`YLine` Shape:** Vertical 3-cell line centered.
  - Relative Coordinates: `[(0,-1), (0,0), (0,1)]`
- **`XShape` Shape:** Corners of a 3x3 square plus the center.
  - Relative Coordinates: `[(-1,-1), (1,-1), (0,0), (-1,1), (1,1)]`

### 2.2 Update `CardData` Resource (`card_data.gd`)

- **Modify Script:** The `Shape` enum in `scr/resources/card_data.gd` needs to be updated to include the new shapes.

    ```gdscript
    enum Shape {
        O,
        PLUS,
        XLine,
        YLine,
        XShape
    }
    ```

    *(This modification will be done in 'code' mode after plan approval)*

### 2.3 Add Function to `GridSystem` (`grid_system.gd`)

- **Modify Script:** Add a new function to `scr/core/grid_system.gd`.
- **Function Signature:**

    ```gdscript
    ## Calculates the absolute grid coordinates affected by a card shape placed at a center point.
    ## Returns an array of Vector2i coordinates, filtering out any that are off-grid.
    func get_affected_coordinates(shape: CardData.Shape, center_x: int, center_y: int) -> Array[Vector2i]:
        pass # Implementation below
    ```

- **Implementation Details:**
    1. Initialize an empty array `affected_coords: Array[Vector2i]`.
    2. Define the relative offset arrays (using `Vector2i`) for `O`, `PLUS`, `XLine`, `YLine`, and `XShape` shapes based on section 2.1.
    3. Use a `match` statement on the input `shape`.
    4. Inside the `match`, select the appropriate array of relative offsets based on the `shape`.
    5. Iterate through the selected relative offsets (`offset: Vector2i`).
    6. Calculate the absolute coordinate: `absolute_coord = Vector2i(center_x + offset.x, center_y + offset.y)`.
    7. **Boundary Check:** Verify if `absolute_coord` is within the grid bounds (using `GRID_WIDTH` and `GRID_HEIGHT` constants already in `GridSystem`):
        - `absolute_coord.x >= 0 and absolute_coord.x < GRID_WIDTH`
        - `absolute_coord.y >= 0 and absolute_coord.y < GRID_HEIGHT`
    8. If the coordinate is valid (within bounds), append `absolute_coord` to the `affected_coords` array.
    9. Return the `affected_coords` array.

### 2.4 Required Types

- Ensure `CardData` type is available (it should be due to `class_name`).
- Use `Vector2i` for coordinates.

## 3. Next Steps

1. Review this updated plan with the new shape definitions.
2. Approve the plan or suggest further modifications.
3. Once approved, I will request to switch to 'code' mode to first update `card_data.gd` and then implement the logic in `grid_system.gd`.
