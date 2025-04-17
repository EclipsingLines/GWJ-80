# Plan: Task 3 - Implement Card Data Structure

## 1. Goal

Define a custom Godot `Resource` script that represents the data structure for a single card, including its shape and color, as specified in `GTD.md` Task 3.

## 2. Proposed Implementation

### 2.1 Create `CardData` Resource Script (`card_data.gd`)

- **File Location:** Create a new script at `scr/resources/card_data.gd`.
- **Class Definition:**
  - Define the script with `class_name CardData`.
  - Make it extend `Resource`.
- **Shape Enum:**
  - Define an `enum Shape` within the script to represent the possible card shapes:

      ```gdscript
      enum Shape {
          O,
          PLUS
      }
      ```

- **Exported Properties:**
  - Add an exported variable `shape` of type `Shape`:

      ```gdscript
      @export var shape: Shape = Shape.O
      ```

  - Add an exported variable `color` of type `Color`:

      ```gdscript
      @export var color: Color = Color.WHITE
      ```

- **Purpose:** This script will serve as the blueprint for creating individual card definition files (e.g., `red_o_card.tres`, `blue_plus_card.tres`) using Godot's resource system. Creating the actual `.tres` files is outside the scope of this specific task but will follow later.

### 2.2 Directory Structure

- Ensure the `scr/resources/` directory exists. If not, the `write_to_file` tool will create it when saving `card_data.gd`.

## 3. Next Steps

1. Review this plan.
2. Approve the plan or suggest modifications.
3. Once approved, I will request to switch to the 'code' mode to implement this resource definition.
