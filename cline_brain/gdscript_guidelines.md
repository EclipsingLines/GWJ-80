# GDScript Guidelines

## Style Guide

### Formatting

- Use tabs for indentation (not spaces)
- Keep lines under 100 characters when possible
- Use one space after keywords like `if`, `for`, `while`
- Use spaces around operators: `var x = 5 + 3`
- No space between function name and parentheses: `func foo():`
- One space between function parameters: `func foo(a: int, b: String):`
- Align function parameters for multiline definitions:

  ```gdscript
  func long_function_name(
      argument1: String,
      argument2: Dictionary,
      argument3: Array
  ) -> void:
      pass
  ```

### Naming Conventions

- **snake_case**: functions, variables, signals, nodes

  ```gdscript
  var player_score: int = 0
  func calculate_damage() -> int:
      return 10
  signal health_depleted
  $character_sprite
  ```

- **PascalCase**: classes, including inner classes

  ```gdscript
  class_name PlayerController
  
  class InventoryItem:
      var name: String
  ```

- **UPPER_CASE**: constants and enums

  ```gdscript
  const MAX_SPEED = 300
  enum Direction { UP, DOWN, LEFT, RIGHT }
  ```

- **_underscore_prefix**: private functions and variables

  ```gdscript
  var _internal_value: int = 10
  func _private_helper() -> void:
      pass
  ```

### Class Organization

Order class members as follows:

1. Tool declaration (if needed)
2. Class name declaration
3. Extends declaration

4. # docstring

5. Signals
6. Enums and Constants
7. Exported properties
8. Public properties
9. Private properties
10. Onready properties
11. Built-in virtual methods (_ready,_process, etc.)
12. Public methods
13. Private methods

Example:

```gdscript
tool
class_name MyClass
extends Node

## Documentation for the class
## Provides functionality for X and Y

# Signals
signal my_signal(parameter)

# Enums and Constants
enum States { IDLE, RUNNING, JUMPING }
const MAX_SPEED = 300

# Exported Properties
@export var speed: float = 200.0
@export_range(0, 100) var health: int = 100

# Public Properties
var is_active: bool = true

# Private Properties
var _private_var: bool = false

# Onready Properties
@onready var _sprite = $Sprite

# Built-in Virtual Methods
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

# Public Methods
func public_method() -> void:
    pass

# Private Methods
func _private_method() -> void:
    pass
```

## Documentation Comments

### Class Documentation

Use a docstring (triple-quoted string) at the top of the class:

```gdscript
class_name Enemy
extends CharacterBody2D

## An enemy character that patrols and attacks the player.
## 
## This enemy has configurable speed, health, and attack patterns.
## It uses raycasts for detection and a state machine for behavior.
```

### Function Documentation

Document functions with a comment above the function:

```gdscript
## Calculates damage based on weapon strength and critical hit chance.
## 
## [param weapon_strength] Base damage of the weapon.
## [param critical_chance] Probability of a critical hit (0.0 to 1.0).
## [returns] The final damage amount.
func calculate_damage(weapon_strength: int, critical_chance: float) -> int:
    # Implementation
    return 0
```

### Signal Documentation

Document signals with a comment above the signal:

```gdscript
## Emitted when the player takes damage.
## [param amount] The amount of damage taken.
## [param source] The source of the damage.
signal damage_taken(amount: int, source: Node)
```

### Property Documentation

Document properties with a comment above the property:

```gdscript
## Maximum health points of the character.
@export_range(1, 1000) var max_health: int = 100

## Current movement speed in pixels per second.
var current_speed: float = 0.0
```

## Static Typing

### Basic Type Annotations

```gdscript
var score: int = 0
var player_name: String = "Player"
var is_active: bool = true
var movement_speed: float = 5.5
var items: Array[String] = ["Sword", "Shield", "Potion"]
var player_data: Dictionary = {"health": 100, "mana": 50}
```

### Function Type Annotations

```gdscript
func calculate_damage(base_damage: int, multiplier: float) -> int:
    return int(base_damage * multiplier)

func get_player_name() -> String:
    return "Player"

func process_input(delta: float) -> void:
    # Implementation
    pass
```

### Custom Types

```gdscript
class_name Player
extends CharacterBody2D

var inventory: Inventory  # Using a custom class
var weapon: Weapon  # Using a custom class

func equip_weapon(new_weapon: Weapon) -> void:
    weapon = new_weapon
```

### Array and Dictionary Type Hints

```gdscript
# Typed arrays
var string_array: Array[String] = []
var node_array: Array[Node] = []
var vector_array: Array[Vector2] = []

# Typed dictionaries
var string_to_int: Dictionary = {}  # Can't specify key/value types in GDScript 4.0
```

### Benefits of Static Typing

- Catches type errors at compile time
- Improves code completion and IDE support
- Makes code more self-documenting
- Can improve performance

## Warning System

### Common Warnings

- **Unused variable**: A declared variable is never used
- **Unused signal**: A declared signal is never emitted
- **Unused parameter**: A function parameter is never used
- **Unassigned variable**: A variable is used before being assigned
- **Unreachable code**: Code that will never execute
- **Narrowing conversion**: Converting from a larger type to a smaller type
- **Return value discarded**: Not using the return value of a function

### Handling Warnings

```gdscript
# Ignore specific warning
# warning-ignore:unused_variable
var my_unused_var = 5

# Ignore specific warning for a block
# warning-ignore-all:unused_variable
var unused1 = 5
var unused2 = 10
# warning-restore:unused_variable

# Explicitly mark unused parameters
func process_data(_unused_param: int, value: int) -> void:
    print(value)
```

### Warning Annotations

```gdscript
@warning_ignore("unused_variable")
func some_function() -> void:
    var unused = 5
    # Implementation
```

## Format Strings

### Basic String Formatting

```gdscript
var player_name = "Alex"
var score = 100
var formatted = "Player %s scored %d points" % [player_name, score]
```

### Named Placeholders

```gdscript
var data = {
    "name": "Alex",
    "score": 100,
    "level": 5
}
var formatted = "%(name)s reached level %(level)d with %(score)d points" % data
```

### String Methods

```gdscript
# String interpolation (Godot 4.0+)
var player_name = "Alex"
var score = 100
var formatted = "%s scored %d points" % [player_name, score]

# Format method
var formatted = "Player {name} scored {score} points".format({"name": player_name, "score": str(score)})
```

## Advanced GDScript Features

### Lambda Functions

```gdscript
var add = func(a: int, b: int) -> int: return a + b
var result = add.call(5, 3)  # result = 8

# With arrays
var numbers = [1, 2, 3, 4, 5]
var doubled = numbers.map(func(n): return n * 2)  # [2, 4, 6, 8, 10]
```

### Pattern Matching

```gdscript
match value:
    1:
        print("One")
    2:
        print("Two")
    _:
        print("Other")

# Pattern matching with arrays
match array:
    []:
        print("Empty array")
    [1, 2, var x]:
        print("Array with 1, 2, and ", x)
    [var start, ..]:
        print("Array starting with ", start)
```

### Coroutines

```gdscript
func _ready() -> void:
    var co = coroutine()
    co.resume()

func coroutine():
    print("Start")
    await get_tree().create_timer(1.0).timeout
    print("After 1 second")
    await get_tree().create_timer(1.0).timeout
    print("After 2 seconds")
```

### Inner Classes

```gdscript
class_name Inventory
extends Resource

class Item:
    var name: String
    var value: int
    
    func _init(p_name: String, p_value: int) -> void:
        name = p_name
        value = p_value
    
    func get_description() -> String:
        return "%s (worth %d gold)" % [name, value]

var items: Array[Item] = []

func add_item(name: String, value: int) -> void:
    items.append(Item.new(name, value))
```

### Export Annotations

```gdscript
# Basic exports
@export var health: int = 100
@export var player_name: String = "Player"

# Ranged values
@export_range(0, 100) var stamina: int = 100
@export_range(0, 10, 0.1) var attack_speed: float = 1.0

# Enums
enum WeaponType { SWORD, BOW, STAFF }
@export var weapon_type: WeaponType = WeaponType.SWORD

# File paths
@export_file("*.png") var character_sprite: String

# Node paths
@export var target_node: NodePath

# Color picker
@export var player_color: Color = Color.BLUE

# Groups
@export_group("Combat Stats")
@export var attack: int = 10
@export var defense: int = 5
@export_group_end
```

## Common Pitfalls and Best Practices

### Memory Management

- Free resources when no longer needed
- Use `queue_free()` to remove nodes safely
- Be cautious with circular references
- Use weak references when appropriate

### Performance Optimization

- Avoid creating objects in tight loops
- Cache node references with `@onready`
- Use object pooling for frequently created/destroyed objects
- Profile your game to identify bottlenecks

### Signal Connections

- Connect signals in `_ready()`
- Disconnect signals when no longer needed
- Use the correct connection method:

  ```gdscript
  # Method 1: Using connect()
  some_node.signal_name.connect(_on_signal_name)
  
  # Method 2: In the editor
  # Connect via the Node tab in the editor
  
  # Method 3: Using @export
  @export var target_node: NodePath
  @onready var _target = get_node(target_node)
  
  func _ready() -> void:
      _target.signal_name.connect(_on_signal_name)
  ```

### Error Handling

- Use `assert()` for development-time validation
- Handle errors gracefully in production code
- Log errors with appropriate context
- Consider using a custom error handling system for complex games

### Code Reuse

- Create reusable components
- Use inheritance when appropriate
- Consider composition over inheritance for flexibility
- Use autoloads sparingly and with clear purpose
