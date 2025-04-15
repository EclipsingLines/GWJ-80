# System Patterns: [Project Name]

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

## Component Relationships

1. Player → Input System
   - Description: Player receives input events and translates them to actions
   - Interface: Input map and action events
   - Error handling: Graceful degradation for missing input devices

2. Game State → Level Manager
   - Description: Game state controls level loading and transitions
   - Interface: Methods for loading, unloading, and transitioning between levels
   - Error handling: Fallback to default level on loading errors

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

### Source Control Practices

1. Git Commit Strategy
   - Make frequent, small commits while coding to create recovery points
   - Each commit should represent a logical unit of work
   - Use descriptive commit messages with a clear structure:

     ```
     [Component] Brief description of change
     
     More detailed explanation if needed
     ```

   - Example commit messages:

     ```
     [Player] Add jump mechanics
     
     Implements double-jump functionality with proper animation
     transitions and sound effects.
     ```

     ```
     [UI] Fix health bar display
     
     Corrects scaling issues on different resolutions and
     adds smooth transitions when health changes.
     ```

2. Code Recovery with Git
   - Use git to recover accidentally deleted code:

     ```bash
     # Find the commit where code was deleted
     git log -p -- path/to/file.gd
     
     # Recover specific file from a previous commit without affecting other files
     git checkout [commit-hash] -- path/to/file.gd
     
     # For recovering just part of a file, use git blame to find the right commit
     git blame path/to/file.gd
     
     # Then checkout that specific file and manually extract the needed parts
     git checkout [commit-hash] -- path/to/file.gd
     ```

   - Consider using `git stash` to temporarily save changes when switching tasks:

     ```bash
     # Save current changes
     git stash save "description of changes"
     
     # List saved stashes
     git stash list
     
     # Apply a specific stash (keeping it in the stash list)
     git stash apply stash@{0}
     
     # Remove stash after applying it
     git stash pop
     ```

3. Branching Strategy
   - Use feature branches for new features or significant changes
   - Keep feature branches short-lived (1-5 days)
   - Regularly rebase feature branches on the main branch
   - Use pull requests for code review
   - Clean up branches after merging

### Naming Conventions

1. General Naming
   - Use snake_case for functions, variables, signals, and nodes
   - Use PascalCase for classes, including inner classes
   - Use UPPER_CASE for constants and enums
   - Prefix private functions and variables with underscore (_)
   - Be explicit and descriptive in naming

2. Node-Specific Naming
   - Name nodes according to their purpose
   - Use type prefixes for clarity when helpful (e.g., btn_start, lbl_score)
   - Keep node names concise but descriptive
   - Use consistent naming across similar nodes

3. Variable Naming
   - Loop indices: `i`, `j`, etc., or descriptive names for complex loops
   - Temporary variables: short names are acceptable
   - Long-lived variables: descriptive names that explain purpose
   - Boolean variables: use is_, has_, can_prefixes (e.g., is_active, has_weapon)

### Error Handling Patterns

1. Standard Error Handling

   ```gdscript
   # Using assert for development-time validation
   assert(condition, "Error message")
   
   # Using push_error for runtime errors
   if not condition:
       push_error("Something went wrong")
       return
   ```

2. Signal-Based Error Handling

   ```gdscript
   # Define an error signal
   signal error_occurred(message)
   
   # Emit the signal when an error occurs
   if not condition:
       emit_signal("error_occurred", "Failed to load resource")
       return
   ```

3. Error Logging

   ```gdscript
   # Simple error logging
   print_debug("Error: " + error_message)
   
   # More structured logging
   print_debug("[ERROR][%s] %s" % [get_name(), error_message])
   ```

### Documentation Standards

1. Script Documentation
   - Add documentation comments at the top of the script:

     ```gdscript
     ## A player character controller.
     ## Handles movement, jumping, and interactions.
     class_name Player
     extends CharacterBody2D
     ```

2. Function Documentation
   - Document all public functions with detailed comments
   - Include usage examples for complex functions
   - Document all parameters and return values

     ```gdscript
     ## Moves the player in the given direction.
     ## [param direction] Normalized direction vector.
     ## [param sprint] Whether to apply sprint multiplier.
     ## [returns] The actual movement applied.
     func move(direction: Vector2, sprint: bool = false) -> Vector2:
         # Implementation
         return Vector2.ZERO
     ```

3. Signal Documentation
   - Document all signals with their purpose and parameters

     ```gdscript
     ## Emitted when the player takes damage.
     ## [param amount] The amount of damage taken.
     ## [param source] The source of the damage.
     signal damage_taken(amount: int, source: Node)
     ```

### Testing Patterns

1. Test Organization
   - Use a testing framework like GUT (Godot Unit Testing)
   - Group related test cases
   - Name tests clearly: `test_function_name_scenario`

2. Test Helpers
   - Create shared test fixtures and helpers
   - Use assertions for validating results
   - Isolate test dependencies

3. Test Coverage
   - Focus on testing core game mechanics
   - Test error cases and edge conditions
   - Include integration tests for component interaction

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

5. Input Handling
   - Use Godot's Input Map system
   - Create action names rather than hardcoding keys
   - Support multiple input methods when possible
   - Implement proper input buffering for action games
   - Example input setup:

     ```gdscript
     # In project settings, define actions: "move_left", "move_right", "jump"
     
     func _process(delta: float) -> void:
         var direction = Input.get_axis("move_left", "move_right")
         if direction:
             move_horizontal(direction * speed * delta)
         
         if Input.is_action_just_pressed("jump"):
             jump()

## Initial Scene Flow & Configuration

This section describes the initial sequence of scenes when the game starts and how to configure them.

### Scene Flow Diagram

```mermaid
flowchart TD
   Start[Game Start (project.godot)] --> Opening(scenes/opening/opening_with_logo.tscn);
   Opening -- Displays images --> MainMenu(scenes/menus/main_menu/main_menu_with_animations.tscn);
   MainMenu -- Start New Game --> GameScene(Configured Game Scene);
   MainMenu -- Continue Game --> GameScene;
   MainMenu -- Options --> OptionsMenu(scenes/menus/options_menu/master_options_menu_with_tabs.tscn);
   MainMenu -- Credits --> CreditsMenu(scenes/credits/credits.tscn);
   MainMenu -- Level Select --> LevelSelect(Configured Level Select Scene);
   MainMenu -- Quit --> QuitGame(Quit Game);
   OptionsMenu -- Back --> MainMenu;
   CreditsMenu -- Back --> MainMenu;
   LevelSelect -- Back --> MainMenu;
   LevelSelect -- Select Level --> GameScene;

   subgraph "Main Menu Options"
       direction LR
       GameScene
       OptionsMenu
       CreditsMenu
       LevelSelect
       QuitGame
   end
```

### Configuration Details

1. **`project.godot`**:

- `application/run/main_scene`: Set this to the desired entry point scene. Currently set to `res://scenes/opening/opening_with_logo.tscn`.

2. **`scenes/opening/opening_with_logo.tscn`**:

- `images` (Exported Array[Texture2D]): Add or remove textures in the inspector to change the images displayed during the opening sequence.
- `next_scene` (Exported String - Path or UID): Set this in the inspector to the scene that should load after the opening images are shown. Currently set to `uid://c63y6b25bs4bk` (`scenes/menus/main_menu/main_menu_with_animations.tscn`).

3. **`scenes/menus/main_menu/main_menu_with_animations.tscn`**:

- `game_scene_path` (Exported String - Path): Set this in the inspector to the main game scene file path that should be loaded when "Start New Game" or "Continue Game" is selected. Currently set to the template's example: `res://addons/maaacks_game_template/examples/scenes/game_scene/game_ui.tscn`. **This should be updated to your actual game scene.**
- `options_packed_scene` (Exported PackedScene): Set this in the inspector to the scene to load when "Options" is selected. Currently set to `res://scenes/menus/options_menu/master_options_menu_with_tabs.tscn`.
- `credits_packed_scene` (Exported PackedScene): Set this in the inspector to the scene to load when "Credits" is selected. Currently set to `res://scenes/credits/credits.tscn`.
- `level_select_packed_scene` (Exported PackedScene): Set this in the inspector to the scene to load when "Level Select" is selected. If left null, the "Level Select" button will not appear.

4. **Autoloads (`GameStateExample`, `GlobalState` - specific names might vary):**

- The logic for enabling "Continue Game" (`GameStateExample.has_game_state()`) and "Level Select" (`GameStateExample.get_max_level_reached() > 0`) depends on these autoloads (likely provided by the Maaack template). You may need to adapt the `_setup_game_buttons` function in `main_menu_with_animations.gd` if your project uses different state management singletons or logic.
- The `new_game` function calls `GlobalState.reset()` and `GameStateExample.start_game()`. Adapt these calls if your state management differs.
