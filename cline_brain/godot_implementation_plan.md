# Godot Brain Templates Implementation Plan

## Overview

This document outlines a detailed implementation plan for adapting the existing Go-focused brain templates to Godot 4.x game development. The plan includes specific changes to each template file, new templates to create, and a prioritized implementation schedule.

## Current State Analysis

The current templates are heavily Go-focused:

- `.clinerules` contains Go-specific code styling and project structure guidelines
- `systemPatterns.md` includes detailed Go code organization, formatting, and naming conventions
- `techContext.md` describes Go-specific technology stack, dependencies, and deployment
- Other templates (`projectbrief.md`, `productContext.md`, `activeContext.md`, `progress.md`) are more generic and require minimal changes

## Implementation Priorities

1. **Replace Go-specific content with Godot-specific guidelines**
2. **Add Godot-specific best practices from official documentation**
3. **Create new templates for Godot-specific information**
4. **Update the memory bank structure to reflect Godot development workflow**

## Detailed Changes by File

### 1. `.clinerules`

**Current:** Go-specific code styling rules, project structure, logging practices, etc.

**Changes needed:**

- Replace "Go Code Styling Rules" with "GDScript Styling Rules"
- Update project structure for Godot projects
- Replace Go-specific logging with Godot logging
- Update documentation standards for GDScript
- Replace Go testing requirements with Godot testing approaches
- Update error handling for GDScript
- Add Godot-specific performance considerations

**Implementation details:**

```markdown
## Project Intelligence

### GDScript Styling Rules
- Follow the official GDScript style guide
- Use tabs for indentation (not spaces)
- Use snake_case for functions, variables, and signals
- Use PascalCase for classes and nodes
- Order class members: tool, class_name, extends, signals, enums/constants, exported variables, public variables, private variables, onready variables, methods
- Keep functions short and focused on a single task
- Use descriptive variable and function names
- Add type hints to function parameters and return values
- Document all exported variables, signals, and public functions
- Make frequent, small git commits while coding to create recovery points

### Project Structure
- Define key components in the README.md
- Place scenes under /scenes/
- Organize scripts under /scripts/ or alongside their scenes
- Store resources under /resources/
- Place assets (textures, models, sounds) under /assets/
- Store addons under /addons/
- Place autoloads under /autoloads/ or /scripts/singletons/
- Keep unit tests alongside the code they test
- Place integration tests in a separate /tests/ directory

### Logging Best Practices
- Use Godot's built-in print(), push_error(), and push_warning() functions
- Consider using a custom logger for more complex projects
- Use appropriate log levels (debug, info, warn, error)
- Include context with log entries
- Use formatted strings for complex log messages

### Documentation Standards
- Document all exported variables with descriptive hints
- Document all signals and their parameters
- Use docstrings for classes and methods
- Include examples for complex functions
- Keep README.md up to date with usage instructions
- Document configuration options and their effects
- Create CONTRIBUTING.md for collaboration guidelines

### Testing Requirements
- Write tests for critical game systems
- Consider using GUT (Godot Unit Testing) or another testing framework
- Test both scripts and scenes
- Use mock objects for external dependencies
- Name tests descriptively
- Include integration tests for end-to-end verification

### Error Handling
- Use Godot's error handling mechanisms
- Implement proper error reporting
- Use assert() for development-time validation
- Consider custom error types for domain-specific errors
- Include appropriate logging with error context
- Return early on errors to avoid deep nesting

### Performance Considerations
- Use object pooling for frequently instantiated objects
- Implement proper resource management
- Consider using multithreading for heavy operations
- Profile your game regularly
- Use Godot's built-in profiling tools
- Optimize rendering and physics operations
- Be mindful of garbage collection impact
```

### 2. `systemPatterns.md`

**Current:** Detailed Go architecture, design patterns, code styling, and organization.

**Changes needed:**

- Replace Go code styling with GDScript styling
- Update architecture overview for Godot projects
- Replace design patterns with Godot-specific patterns
- Add Godot scene organization patterns
- Update component relationships for Godot's node system
- Add Godot-specific best practices

**Implementation details:**

```markdown
## Architecture Overview

### Core Components
1. Scene System
   - Description: Godot's scene-based architecture
   - Relationship to other components: Foundation of the entire project
   - Key design decisions: Scene composition vs inheritance

2. Node Hierarchy
   - Description: Tree-based structure of nodes
   - Relationship to other components: Defines game object relationships
   - Key design decisions: Node organization and responsibilities

3. Resource System
   - Description: Godot's resource management
   - Relationship to other components: Provides assets to scenes and scripts
   - Key design decisions: Resource loading and caching strategies

### Data Flow
- Signal-based communication between nodes
- Resource loading and instantiation
- Scene transitions and management

## Design Patterns

1. Dependency Injection
   - Description: Passing dependencies to nodes rather than hard-coding references
   - Where it's applied: Complex systems with multiple interacting components
   - Benefits: Improved testability, flexibility, and reduced coupling

2. State Pattern
   - Description: Managing different states with dedicated state objects
   - Where it's applied: Character controllers, game states, UI systems
   - Benefits: Clean separation of state-specific behavior

3. Observer Pattern (Signals)
   - Description: Using Godot's signal system for event-based programming
   - Where it's applied: UI interactions, game events, inter-node communication
   - Benefits: Decoupled communication between components

4. Resource Singleton
   - Description: Using custom resources as globally accessible data stores
   - Where it's applied: Game configuration, player data, level information
   - Benefits: Type safety, inspector integration, and resource saving/loading

## Scene Organization

### Scene Composition
- Prefer composition over inheritance for most cases
- Create reusable scene components
- Use scene inheritance for variations of the same entity
- Follow the Single Responsibility Principle for scenes

### Node Structure
- Organize nodes hierarchically based on functionality
- Use meaningful node names
- Group related nodes using Node2D, Node3D, or Control nodes
- Keep scene trees as flat as possible while maintaining logical organization

### Scene Instancing
- Use PackedScene resources for dynamic instancing
- Consider object pooling for frequently instantiated scenes
- Use scene unique names when necessary

## GDScript Code Styling

### File Organization
- One script per node/resource when possible
- Keep scripts under 300 lines by splitting into multiple scripts
- Use class_name for scripts that will be instantiated directly
- Follow consistent script structure:
  ```gdscript
  class_name MyClass
  extends Node

  # Tool mode (if needed)
  tool

  # Signals
  signal my_signal(parameter)

  # Enums and Constants
  enum States {IDLE, RUNNING, JUMPING}
  const MAX_SPEED = 300

  # Exported Properties
  @export var speed: float = 200.0

  # Public Properties
  var health: int = 100

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

### Naming Conventions

- Use snake_case for functions, variables, signals, and nodes
- Use PascalCase for classes, including inner classes
- Use UPPER_CASE for constants and enums
- Prefix private functions and variables with underscore (_)
- Use descriptive names that reflect purpose

### Documentation

- Document all exported variables with descriptive hints
- Document all signals and their parameters
- Use docstrings for classes and methods:

  ```gdscript
  ## A player character controller.
  ## Handles movement, jumping, and interactions.
  class_name Player
  extends CharacterBody2D

  ## Maximum movement speed in pixels per second.
  @export var max_speed: float = 300.0

  ## Emitted when the player collects an item.
  ## [param item_id] The unique identifier of the collected item.
  signal item_collected(item_id: String)

  ## Moves the player in the given direction.
  ## [param direction] Normalized direction vector.
  ## [param sprint] Whether to apply sprint multiplier.
  ## [returns] The actual movement applied.
  func move(direction: Vector2, sprint: bool = false) -> Vector2:
      # Implementation
      return Vector2.ZERO
  ```

### Error Handling

- Use Godot's error handling mechanisms:

  ```gdscript
  # Assert (development only)
  assert(condition, "Error message")

  # Warning
  push_warning("Warning message")

  # Error
  push_error("Error message")

  # Return codes
  if some_function() != OK:
      push_error("Function failed")
      return
  ```

## Best Practices

1. Resource Management
   - Preload static resources
   - Use load for dynamic resources
   - Implement proper resource cleanup
   - Consider using ResourceLoader for background loading

2. Signal Usage
   - Connect signals in _ready()
   - Disconnect signals when no longer needed
   - Use signal parameters to pass data
   - Consider using callable_from_function for complex signal handling

3. Performance
   - Use object pooling for frequently instantiated objects
   - Implement proper resource management
   - Consider using multithreading for heavy operations
   - Profile your game regularly
   - Use Godot's built-in profiling tools

4. State Management
   - Use state machines for complex behavior
   - Consider using AnimationTree for character states
   - Separate logic from presentation
   - Use resources for persistent state

```

### 3. `techContext.md`

**Current:** Go-specific technology stack, dependencies, development setup, deployment, etc.

**Changes needed:**
- Replace Go technology stack with Godot
- Update dependencies section for Godot addons/plugins
- Replace development setup with Godot-specific setup
- Update deployment section for game publishing platforms
- Add Godot export configuration details
- Update technical constraints for game development

**Implementation details:**

```markdown
# Technical Context: [Project Name]

## Technology Stack

### Core Technologies
1. Godot Engine (version 4.x)
   - Primary game development engine
   - Built-in GDScript language
   - Scene-based architecture
   - Node system for game objects

2. GDScript
   - Primary scripting language
   - Static typing support
   - Object-oriented programming
   - Built-in integration with Godot Engine

3. [Additional Technology, if applicable]
   - [Purpose in the project]
   - [Key features used]
   - [Version requirements]

### Dependencies

1. Godot Addons
   - [Addon 1]
     - Purpose: [What it's used for]
     - Version: [Version number]
     - Source: [GitHub/Asset Library link]
   
   - [Addon 2]
     - Purpose: [What it's used for]
     - Version: [Version number]
     - Source: [GitHub/Asset Library link]

2. External Assets
   - [Asset Pack 1]
     - Purpose: [What it's used for]
     - License: [License type]
     - Source: [Where it was obtained]
   
   - [Asset Pack 2]
     - Purpose: [What it's used for]
     - License: [License type]
     - Source: [Where it was obtained]

## Development Setup

### Prerequisites
1. Development Tools
   - Godot Engine 4.x
   - Git for version control
   - [Additional tools if needed]
   - Text editor or IDE with GDScript support (VSCode with Godot Tools, etc.)

2. Environment Setup
   ```bash
   # Clone repository
   git clone [repository URL]
   cd [project directory]
   
   # Open project in Godot
   godot -e
   ```

### Project Structure

```
project/
├── .git/                  # Git repository
├── .gitignore             # Git ignore file
├── project.godot          # Godot project file
├── export_presets.cfg     # Export configurations
├── default_env.tres       # Default environment
├── icon.png               # Project icon
├── scenes/                # All game scenes
│   ├── main/              # Main game scenes
│   ├── ui/                # UI scenes
│   ├── levels/            # Level scenes
│   └── characters/        # Character scenes
├── scripts/               # GDScript files
│   ├── autoloads/         # Singleton scripts
│   ├── resources/         # Custom resources
│   └── classes/           # Reusable classes
├── resources/             # Resource files
│   ├── themes/            # UI themes
│   └── materials/         # Materials
├── assets/                # Game assets
│   ├── textures/          # Texture files
│   ├── models/            # 3D models
│   ├── audio/             # Sound and music
│   └── fonts/             # Font files
├── addons/                # Third-party addons
└── tests/                 # Test scenes and scripts
```

### Build Process

1. Running the Project

   ```bash
   # Open project in Godot Editor
   godot -e
   
   # Run project directly
   godot --path /path/to/project
   ```

2. Testing

   ```bash
   # Run tests using GUT or custom test framework
   godot --path /path/to/project --script res://tests/run_tests.gd
   ```

## Deployment

### Export Configuration

1. Export Presets
   - Windows (Desktop)
   - macOS (Desktop)
   - Linux (Desktop)
   - Android (Mobile)
   - iOS (Mobile)
   - HTML5 (Web)

2. Platform-Specific Settings
   - Windows:
     - Architecture: x86_64
     - Features: [specific features]

   - Android:
     - Minimum SDK: [version]
     - Target SDK: [version]
     - Permissions: [list of permissions]

3. Export Process

   ```bash
   # Export using Godot Editor
   godot --export "Windows Desktop" /path/to/output.exe
   
   # Export using Godot Editor (headless)
   godot --headless --export "Windows Desktop" /path/to/output.exe
   ```

### Distribution Platforms

1. PC Distribution
   - Steam
   - Epic Games Store
   - itch.io
   - GOG

2. Mobile Distribution
   - Google Play Store
   - Apple App Store

3. Web Distribution
   - itch.io
   - Newgrounds
   - Own website

### CI/CD Pipeline

1. GitHub Actions
   - Triggers: [When pipelines run]
   - Stages:
     - Build
     - Test
     - Export
     - Deploy to Staging
     - Deploy to Production

## Technical Constraints

1. Performance Targets
   - Minimum FPS: [target]
   - Target platforms: [platforms]
   - Minimum specifications: [specs]
   - Resolution support: [resolutions]

2. Asset Constraints
   - Texture size limits
   - Polygon count guidelines
   - Audio quality/compression settings
   - Memory usage targets

3. Platform-Specific Constraints
   - Mobile:
     - Touch controls
     - Battery usage
     - File size limits

   - Web:
     - Loading times
     - Browser compatibility
     - WebGL limitations

## Development Patterns

1. Scene Management
   - Scene switching approach
   - Scene preloading strategy
   - Scene instancing patterns

2. State Management
   - Game state handling
   - Save/load system
   - Persistent data approach

3. Input Handling
   - Input mapping system
   - Controller support
   - Touch input handling

4. Optimization Techniques
   - Object pooling
   - Level of detail (LOD) system
   - Occlusion culling
   - Background loading

5. Testing Strategy
   - Unit tests for critical systems
   - Integration tests for game mechanics
   - Playtesting methodology
   - Performance profiling approach

```

### 4. New Template: `gdscript_guidelines.md`

This new template will consolidate Godot-specific coding guidelines from the documentation links.

**Implementation details:**

```markdown
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

```

### 5. New Template: `godot_best_practices.md`

This new template will consolidate Godot-specific architectural and design guidelines from the documentation links.

**Implementation details:**

```markdown
# Godot Best Practices

## Scene Organization

### Scene Composition vs Inheritance

#### When to Use Composition
- For objects made of multiple distinct parts
- When parts need to be reused across different objects
- When you need flexibility to change parts at runtime
- Example: A character composed of a body, weapons, and equipment

```gdscript
# Player.tscn
- KinematicBody2D (Player)
  - CollisionShape2D
  - Sprite
  - Camera2D
  - WeaponSlot (Node2D)
    - Weapon (instance of Weapon.tscn)
  - EffectsPlayer (AudioStreamPlayer)
```

#### When to Use Inheritance

- For variations of the same base entity
- When you need to override specific behaviors
- When the variations share most properties and behaviors
- Example: Different enemy types inheriting from a base enemy

```
BaseEnemy.tscn
├── FlyingEnemy.tscn (inherits BaseEnemy)
├── GroundEnemy.tscn (inherits BaseEnemy)
└── BossEnemy.tscn (inherits BaseEnemy)
```

### Node Structure Guidelines

1. **Logical Hierarchy**
   - Organize nodes based on their logical relationship
   - Parent nodes should control or contain child nodes
   - Group related functionality together

2. **Node Naming**
   - Use clear, descriptive names
   - Follow a consistent naming convention
   - Consider prefixing by type for clarity (e.g., btn_start, lbl_score)

3. **Scene Size**
   - Keep scenes focused on a single responsibility
   - Break large scenes into smaller, reusable components
   - Use scene instancing to compose complex objects

4. **Node Types**
   - Choose the appropriate node type for each purpose
   - Use minimal node types when possible
   - Consider performance implications of node choices

### Example Scene Structures

#### UI Scene

```
- Control (MainMenu)
  - TextureRect (Background)
  - VBoxContainer (MenuOptions)
    - Button (StartButton)
    - Button (OptionsButton)
    - Button (QuitButton)
  - AudioStreamPlayer (MenuMusic)
  - AnimationPlayer
```

#### Character Scene

```
- CharacterBody2D (Player)
  - CollisionShape2D
  - Sprite2D
  - AnimationPlayer
  - Camera2D
  - Area2D (InteractionArea)
    - CollisionShape2D
  - Node2D (WeaponMount)
  - AudioStreamPlayer2D
  - GPUParticles2D (DustEffect)
```

#### Level Scene

```
- Node2D (Level)
  - TileMap (Ground)
  - TileMap (Walls)
  - Node2D (Entities)
    - CharacterBody2D (Player instance)
    - Node2D (Enemies)
      - CharacterBody2D (Enemy instances)
    - Node2D (Collectibles)
      - Area2D (Collectible instances)
  - CanvasLayer (UI)
    - Control (HUD)
  - AudioStreamPlayer (LevelMusic)
```

## Autoloads vs Internal Nodes

### When to Use Autoloads (Singletons)

Autoloads are best for:

- Global game state management
- Services needed throughout the game (audio, input, save system)
- Manager classes that coordinate between systems
- Constants and configuration data

Example Autoload: GameManager

```gdscript
# game_manager.gd
extends Node

signal game_paused(is_paused)
signal score_changed(new_score)

var current_level: int = 1
var score: int = 0
var is_paused: bool = false

func change_score(amount: int) -> void:
    score += amount
    emit_signal("score_changed", score)

func pause_game() -> void:
    is_paused = true
    get_tree().paused = true
    emit_signal("game_paused", true)

func resume_game() -> void:
    is_paused = false
    get_tree().paused = false
    emit_signal("game_paused", false)
```

### When to Use Internal Nodes

Internal nodes are best for:

- Component-specific functionality
- Features that belong to a specific scene
- Localized behavior that doesn't need global access
- Implementation details of a larger system

Example Internal Node: HealthComponent

```gdscript
# health_component.gd
extends Node

signal health_changed(new_health, max_health)
signal died()

@export var max_health: int = 100
var current_health: int = max_health

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    emit_signal("health_changed", current_health, max_health)
    
    if current_health <= 0:
        emit_signal("died")

func heal(amount: int) -> void:
    current_health = min(max_health, current_health + amount)
    emit_signal("health_changed", current_health, max_health)
```

### Best Practices for Autoloads

1. **Keep them focused**
   - Each autoload should have a clear, single responsibility
   - Avoid creating "god objects" that do everything

2. **Use signals for communication**
   - Emit signals when state changes
   - Allow other systems to connect to these signals
   - Reduces tight coupling between systems

3. **Limit the number of autoloads**
   - Too many autoloads can make the codebase hard to understand
   - Consider grouping related functionality

4. **Initialize in the correct order**
   - Be aware of autoload initialization order
   - Set dependencies carefully

### Common Autoload Types

1. **GameManager** - Overall game state and flow
2. **AudioManager** - Sound effects and music
3. **InputManager** - Input handling and mapping
4. **SaveManager** - Save/load functionality
5. **EventBus** - Global event system
6. **ResourceManager** - Asset loading and caching

## Godot Interfaces

### Interface Pattern in GDScript

GDScript doesn't have formal interfaces, but you can implement interface-like patterns:

#### Method 1: Using Abstract Classes

```gdscript
# interface_damageable.gd
class_name IDamageable
extends Node

func take_damage(_amount: int) -> void:
    assert(false, "Method 'take_damage' must be overridden")

func get_health() -> int:
    assert(false, "Method 'get_health' must be overridden")
    return 0
```

Implementation:

```gdscript
# enemy.gd
class_name Enemy
extends CharacterBody2D
# No need to explicitly extend IDamageable

var health: int = 100

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        queue_free()

func get_health() -> int:
    return health
```

#### Method 2: Using Type Checking

```gdscript
# Check if an object implements an interface
if object.has_method("take_damage") and object.has_method("get_health"):
    # Object implements the IDamageable interface
    object.take_damage(10)
```

#### Method 3: Using Duck Typing

```gdscript
# Just call the methods and let Godot handle errors
func attack_target(target):
    # If target doesn't have take_damage, this will error at runtime
    target.take_damage(10)
```

### Best Practices for Interface-like Patterns

1. **Document expected methods**
   - Clearly document what methods an "interface" requires
   - Include parameter and return types

2. **Use consistent method signatures**
   - Keep method signatures consistent across implementations
   - Use type hints to enforce parameter and return types

3. **Consider using signals**
   - Signals can provide interface-like behavior
   - Objects can connect to signals without knowing implementation details

4. **Use has_method() for runtime checks**
   - Check if an object implements required methods
   - Provide graceful fallbacks if methods are missing

## Godot Notifications

### Common Notification Methods

#### Node Lifecycle

- `_enter_tree()` - Called when the node enters the scene tree
- `_ready()` - Called when the node and its children have entered the scene tree
- `_exit_tree()` - Called when the node exits the scene tree
- `_process(delta)` - Called every frame
- `_physics_process(delta)` - Called every physics frame
- `_notification(what)` - Called when the node receives a notification

#### Input Handling

- `_input(event)` - Called when there's an input event
- `_unhandled_input(event)` - Called for unhandled input events
- `_unhandled_key_input(event)` - Called for unhandled key events
- `_gui_input(event)` - Called for GUI input events (Control nodes)

#### 2D Physics

- `_integrate_forces(state)` - Called during physics processing (RigidBody2D)
- `_draw()` - Called when the node needs to be drawn

### Best Practices for Notifications

1. **Use the right notification for the job**
   - `_ready()` for initialization after all children are ready
   - `_process()` for visual updates
   - `_physics_process()` for physics and gameplay logic

2. **Keep notification methods focused**
   - Each notification method should have a clear purpose
   - Break complex logic into helper methods

3. **Consider performance**
   - Be mindful of what you put in frequently called methods like `_process()`
   - Use `set_process(false)` to disable processing when not needed

4. **Chain parent calls when appropriate**
   - Call `super()` when overriding notification methods if needed
   - Example: `super._ready()` to ensure parent initialization

### Example: Proper Notification Usage

```gdscript
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_strength: float = 600.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree
func _enter_tree() -> void:
    # Setup that needs to happen before _ready
    add_to_group("players")

# Called when node is ready (after _enter_tree)
func _ready() -> void:
    # Initialize components
    animation_player.play("idle")
    
    # Connect signals
    $HitBox.body_entered.connect(_on_hit_box_body_entered)

# Called during physics processing
func _physics_process(delta: float) -> void:
    # Apply gravity
    if not is_on_floor():
        velocity.y += gravity * delta
    
    # Handle jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = -jump_strength
    
    # Get movement direction
    var direction = Input.get_axis("move_left", "move_right")
    velocity.x = direction * speed
    
    # Update animations
    update_animations()
    
    # Move the character
    move_and_slide()

# Called every frame
func _process(_delta: float) -> void:
    # Update UI elements or visual effects
    update_dust_effect()

# Called when input events occur
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("attack"):
        attack()

# Helper methods
func update_animations() -> void:
    if velocity.x != 0:
        sprite.flip_h = velocity.x < 0
        animation_player.play("run")
    else:
        animation_player.play("idle")
        
func attack() -> void:
    animation_player.play("attack")

func update_dust_effect() -> void:
    $DustParticles.emitting = is_on_floor() and abs(velocity.x) > 50

func _on_hit_box_body_entered(body: Node2D) -> void:
    if body.is_in_group("enemies"):
        body.take_damage(10)
```

## Data Preferences

### Resource-Based Data Management

Resources are ideal for:

- Game configuration
- Level data
- Character stats
- Item definitions
- Ability systems

#### Custom Resource Example

```gdscript
# item_data.gd
class_name ItemData
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var value: int = 0
@export var weight: float = 1.0
@export var stackable: bool = false
@export var max_stack_size: int = 1
@export var item_type: ItemType = ItemType.MISC

enum ItemType { WEAPON, ARMOR, CONSUMABLE, QUEST, MISC }

func get_tooltip() -> String:
    return "%s\n%s\nValue: %d gold\nWeight: %.1f" % [name, description, value, weight]
```

#### Using Resources for Configuration

```gdscript
# game_settings.gd
class_name GameSettings
extends Resource

@export var master_volume: float = 1.0
@export var music_volume: float = 0.8
@export var sfx_volume: float = 1.0
@export var dialog_speed: float = 1.0
@export var difficulty: Difficulty = Difficulty.NORMAL

enum Difficulty { EASY, NORMAL, HARD }

func save() -> void:
    ResourceSaver.save(self, "user://settings.tres")

static func load_or_create() -> GameSettings:
    if ResourceLoader.exists("user://settings.tres"):
        return ResourceLoader.load("user://settings.tres") as GameSettings
    return GameSettings.new()
```

### Serialization Options

#### Built-in Resource Serialization

```gdscript
# Save a resource
var my_resource = MyResource.new()
my_resource.some_property = "value"
ResourceSaver.save(my_resource, "user://my_resource.tres")

# Load a resource
var loaded_resource = ResourceLoader.load("user://my_resource.tres")
```

#### JSON Serialization

```gdscript
# Save data as JSON
var data = {
    "player_name": "Hero",
    "level": 5,
    "health": 100,
    "inventory": ["sword", "shield", "potion"]
}
var json_string = JSON.stringify(data)
var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
file.store_string(json_string)
file.close()

# Load data from JSON
var file = FileAccess.open("user://save_game.json", FileAccess.READ)
var json_string = file.get_as_text()
file.close()
var data = JSON.parse_string(json_string)
```

#### Binary Serialization

```gdscript
# Save data in binary format
var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
file.store_32(player.level)
file.store_float(player.health)
file.store_string(player.name)
file.close()

# Load data from binary format
var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
var level = file.get_32()
var health = file.get_float()
var name = file.get_string()
file.close()
```

### Best Practices for Data Management

1. **Choose the right format for the job**
   - Resources for editor-defined data
   - JSON for human-readable saves
   - Binary for compact, efficient saves

2. **Separate data from presentation**
   - Store pure data in resources
   - Use separate scenes for visualization

3. **Use typed data where possible**
   - Custom resources with typed properties
   - Enums for constrained values

4. **Handle loading errors gracefully**
   - Check if files exist before loading
   - Provide default values when data is missing

## Logic Preferences

### Signal-Based Communication

Signals are ideal for:

- Decoupling systems
- Event-driven programming
- UI interactions
- Cross-scene communication

#### Signal Example

```gdscript
# health_component.gd
extends Node

signal health_changed(new_health, max_health)
signal died()

@export var max_health: int = 100
var current_health: int = max_health

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    emit_signal("health_changed", current_health, max_health)
    
    if current_health <= 0:
        emit_signal("died")
```

```gdscript
# player.gd
extends CharacterBody2D

@onready var health_component = $HealthComponent

func _ready() -> void:
    # Connect to the health component's signals
    health_component.health_changed.connect(_on_health_changed)
    health_component.died.connect(_on_died)

func _on_health_changed(new_health: int, max_health: int) -> void:
    # Update UI or play effects
    $HealthBar.value = float(new_health) / max_health
    
    if new_health < 30:
        $LowHealthEffect.visible = true

func _on_died() -> void:
    # Handle player death
    $DeathAnimation.play()
    set_process_input(false)
    await $DeathAnimation.animation_finished
    get_tree().reload_current_scene()
```

### State Machines

State machines are ideal for:

- Character behavior
- Game flow
- UI screens
- Animation control

#### Simple State Machine Example

```gdscript
# state_machine.gd
class_name StateMachine
extends Node

signal state_changed(old_state, new_state)

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
    # Register all child states
    for child in get_children():
        if child is State:
            states[child.name.to_lower()] = child
            child.state_machine = self
    
    # Set initial state
    if initial_state:
        current_state = initial_state
        current_state.enter()

func _process(delta: float) -> void:
    if current_state:
        current_state.process(delta)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
    if current_state:
        current_state.handle_input(event)

func transition_to(state_name: String) -> void:
    if not states.has(state_name):
        return
        
    if current_state:
        current_state.exit()
    
    var old_state = current_state
    current_state = states[state_name]
    current_state.enter()
    
    emit_signal("state_changed", old_state, current_state)
```

```gdscript
# state.gd
class_name State
extends Node

var state_machine = null

func enter() -> void:
    pass

func exit() -> void:
    pass

func process(_delta: float) -> void:
    pass

func physics_process(_delta: float) -> void:
    pass

func handle_input(_event: InputEvent) -> void:
    pass
```

```gdscript
# idle_state.gd
extends State

func enter() -> void:
    owner.animation_player.play("idle")

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
        state_machine.transition_to("run")
    elif event.is_action_pressed("jump"):
        state_machine.transition_to("jump")
```

### Dependency Injection

Dependency injection helps with:

- Decoupling components
- Testing
- Flexibility
- Reusability

#### Dependency Injection Example

```gdscript
# weapon_user.gd
extends CharacterBody2D

var current_weapon: Weapon = null

func _ready() -> void:
    # Get the weapon from a child node
    current_weapon = $Weapon

func set_weapon(weapon: Weapon) -> void:
    # Remove old weapon if it exists
    if current_weapon and current_weapon.get_parent() == self:
        remove_child(current_weapon)
        current_weapon.queue_free()
    
    # Add new weapon
    current_weapon = weapon
    add_child(weapon)
    weapon.user = self

func attack() -> void:
    if current_weapon:
        current_weapon.use()
```

```gdscript
# weapon.gd
class_name Weapon
extends Node2D

@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var attack_range: float = 50.0

var user = null

func use() -> void:
    # Base implementation
    pass
```

### Best Practices for Logic Organization

1. **Use composition over inheritance**
   - Create small, focused components
   - Combine components to build complex behavior

2. **Leverage signals for loose coupling**
   - Components should communicate through signals
   - Avoid direct references when possible

3. **Implement state machines for complex behavior**
   - Separate different states into distinct classes
   - Use clear transitions between states

4. **Consider dependency injection**
   - Pass dependencies to objects rather than having them create their own
   - Makes testing and reuse easier

## Project Organization

### Recommended Project Structure

```
project/
├── .git/                  # Git repository
├── .gitignore             # Git ignore file
├── project.godot          # Godot project file
├── export_presets.cfg     # Export configurations
├── default_env.tres       # Default environment
├── icon.png               # Project icon
├── README.md              # Project documentation
├── CHANGELOG.md           # Version history
├── LICENSE                # License information
├── scenes/                # All game scenes
│   ├── main/              # Main game scenes (main menu, game over, etc.)
│   ├── ui/                # UI scenes (HUD, dialogs, menus)
│   ├── levels/            # Level scenes
│   │   ├── level_1/       # Level 1 specific scenes
│   │   ├── level_2/       # Level 2 specific scenes
│   │   └── common/        # Common level components
│   ├── characters/        # Character scenes (player, enemies, NPCs)
│   └── objects/           # Interactive object scenes (items, doors, etc.)
├── scripts/               # GDScript files
│   ├── autoloads/         # Singleton scripts
│   ├── resources/         # Custom resource scripts
│   ├── components/        # Reusable component scripts
│   ├── state_machines/    # State machine implementations
│   └── utils/             # Utility scripts
├── resources/             # Resource files
│   ├── themes/            # UI themes
│   ├── materials/         # Materials
│   ├── data/              # Game data (items, abilities, etc.)
│   └── shaders/           # Shader files
├── assets/                # Game assets
│   ├── textures/          # Texture files
│   │   ├── characters/    # Character textures
│   │   ├── ui/            # UI textures
│   │   ├── environment/   # Environment textures
│   │   └── effects/       # Effect textures
│   ├── models/            # 3D models
│   ├── audio/             # Sound and music
│   │   ├── music/         # Music tracks
│   │   ├── sfx/           # Sound effects
│   │   └── voice/         # Voice acting
│   ├── animations/        # Animation files
│   └── fonts/             # Font files
├── addons/                # Third-party addons
└── tests/                 # Test scenes and scripts
```

### Naming Conventions

1. **Files and Directories**
   - Use snake_case for file and directory names
   - Be descriptive and consistent
   - Group related files together

2. **Scenes**
   - Name scenes after their main purpose
   - Use prefixes for organization (e.g., ui_main_menu, enemy_goblin)
   - Include the type in the name when helpful

3. **Scripts**
   - Match script names to their attached scenes
   - Use suffixes for different types (e.g., _component,_manager)
   - Name utility scripts after their functionality

4. **Resources**
   - Use descriptive names that indicate content and type
   - Include the resource type in the name (e.g., mat_stone, theme_dark)
   - Group related resources with common prefixes

### Version Control Best Practices

1. **What to Commit**
   - All source files (.gd, .tscn, .tres, etc.)
   - Project configuration files
   - Documentation
   - Small, essential assets

2. **What to Exclude**
   - Temporary files
   - Build outputs
   - Large binary files (consider Git LFS)
   - User-specific settings

3. **Sample .gitignore**

   ```
   # Godot-specific ignores
   .import/
   export.cfg
   export_presets.cfg
   
   # Imported translations (automatically generated from CSV files)
   *.translation
   
   # Mono-specific ignores
   .mono/
   data_*/
   
   # System/tool-specific ignores
   .DS_Store
   *.swp
   *~
   
   # Build outputs
   builds/
   
   # User-specific files
   .godot/
   ```

### Asset Management

1. **Asset Naming**
   - Use consistent naming conventions
   - Include dimensions in texture names (e.g., character_32x32.png)
   - Include animation frame count when applicable

2. **Asset Organization**
   - Group assets by type and purpose
   - Keep source files separate from game-ready assets
   - Document asset sources and licenses

3. **Asset Optimization**
   - Compress textures appropriately
   - Use texture atlases for related sprites
   - Optimize audio files for size and quality
   - Consider using importer overrides for specific assets

```

### 6. New Template: `godot_resources.md`

This new template will provide a comprehensive list of Godot documentation resources with brief summaries.

**Implementation details:**

```markdown
# Godot Documentation Resources

This document provides a curated list of official Godot documentation resources that are essential for Godot 4.x development. Each resource includes a brief summary of what it covers and why it's important.

## GDScript Language

### [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- Official style conventions for GDScript
- Covers naming conventions, formatting, and organization
- Essential for maintaining consistent, readable code
- Includes examples of properly formatted code

### [GDScript Basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
- Fundamental GDScript syntax and concepts
- Variables, functions, classes, and control flow
- Basic data types and operations
- Essential for anyone new to GDScript

### [GDScript Advanced](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_advanced.html)
- Advanced GDScript features and techniques
- Inner classes, lambda functions, and coroutines
- Pattern matching and advanced type usage
- Important for writing more sophisticated code

### [GDScript Exports](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html)
- How to expose variables to the Inspector
- Various export annotations and their uses
- Property categories and groups
- Essential for creating configurable components

### [GDScript Documentation Comments](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html)
- How to write effective documentation in GDScript
- Class, method, and property documentation
- Documentation formatting conventions
- Important for maintaining readable, self-documenting code

### [Static Typing in GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html)
- How to use type hints in GDScript
- Benefits of static typing
- Type inference and type checking
- Important for writing more robust, error-resistant code

### [GDScript Warning System](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/warning_system.html)
- Understanding GDScript warnings
- How to enable, disable, and respond to warnings
- Common warning types and their meanings
- Useful for catching potential issues early

### [GDScript Format Strings](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html)
- String formatting techniques in GDScript
- Placeholder syntax and options
- Named placeholders and formatting specifiers
- Essential for creating dynamic text content

## Best Practices

### [Scene Organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html)
- Principles for organizing scenes effectively
- Scene composition vs inheritance
- Node structure guidelines
- Essential for creating maintainable, scalable projects

### [Autoloads vs Internal Nodes](https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_internal_nodes.html)
- When to use autoloads (singletons)
- When to use internal nodes
- Trade-offs and considerations
- Important for proper architecture decisions

### [Godot Interfaces](https://docs.godotengine.org/en/stable/tutorials/best_practices/godot_interfaces.html)
- How to implement interface-like patterns in Godot
- Abstract classes and duck typing
- Signal-based interfaces
- Useful for creating flexible, decoupled systems

### [Godot Notifications](https://docs.godotengine.org/en/stable/tutorials/best_practices/godot_notifications.html)
- Understanding Godot's notification system
- Common notification methods (_ready, _process, etc.)
- Custom notifications
- Essential for proper lifecycle management

### [Data Preferences](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html)
- Best practices for data management in Godot
- Using Resources for data
- Serialization options
- Important for save systems and configuration

### [Logic Preferences](https://docs.godotengine.org/en/stable/tutorials/best_practices/logic_preferences.html)
- Best practices for organizing game logic
- Signal-based communication
- State machines
- Dependency injection
- Essential for creating maintainable game systems

### [Project Organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)
- Directory structure recommendations
- File naming conventions
- Asset organization
- Version control considerations
- Important for maintaining organized, scalable projects

## Additional Resources

### [Godot API Documentation](https://docs.godotengine.org/en/stable/classes/index.html)
- Complete reference for all Godot classes and methods
- Detailed descriptions of properties, methods, and signals
- Essential for understanding available functionality

### [Godot Editor Manual](https://docs.godotengine.org/en/stable/getting_started/introduction/index.html)
- Comprehensive guide to the Godot editor
- Interface overview and customization
- Project management and settings
- Useful for maximizing productivity in the editor

### [Godot Tutorials](https://docs.godotengine.org/en/stable/tutorials/index.html)
- Step-by-step guides for various aspects of Godot
- From beginner to advanced topics
- Practical examples and explanations
- Great for learning specific techniques

### [Godot Community Channels](https://godotengine.org/community/)
- Official Discord, forums, and Q&A
- User-contributed tutorials and examples
- Community support and collaboration
- Valuable for getting help and sharing knowledge
```

## Implementation Schedule

1. **Phase 1: Update Core Files**
   - Update `.clinerules` with Godot-specific guidelines
   - Update `systemPatterns.md` with Godot patterns
   - Update `techContext.md` with Godot technology stack

2. **Phase 2: Create New Templates**
   - Create `gdscript_guidelines.md`
   - Create `godot_best_practices.md`
   - Create `godot_resources.md`

3. **Phase 3: Update Memory Bank Structure**
   - Update `prompt.md` to reference new templates
   - Ensure all templates work together cohesively

4. **Phase 4: Create Example Project**
   - Create a simple example Godot project that follows all guidelines
   - Include documentation that demonstrates the memory bank system in action

## Conclusion

This implementation plan provides a comprehensive approach to adapting the existing Go-focused brain templates for Godot 4.x game development. By following this plan, we can create a robust set of templates that will help AI assistants provide effective guidance for Godot game development projects.
