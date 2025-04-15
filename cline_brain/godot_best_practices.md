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
- CharacterBody2D (Player)
  - CollisionShape2D
  - Sprite2D
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

## Common Game Systems

### Input System

```gdscript
# input_manager.gd (Autoload)
extends Node

# Define action mappings in Project Settings > Input Map
# Examples: move_left, move_right, jump, attack, interact

func get_movement_vector() -> Vector2:
    return Vector2(
        Input.get_axis("move_left", "move_right"),
        Input.get_axis("move_up", "move_down")
    ).normalized()

func is_action_just_pressed(action: String) -> bool:
    return Input.is_action_just_pressed(action)

func is_action_pressed(action: String) -> bool:
    return Input.is_action_pressed(action)

func is_action_just_released(action: String) -> bool:
    return Input.is_action_just_released(action)
```

### Save System

```gdscript
# save_manager.gd (Autoload)
extends Node

const SAVE_FILE = "user://save_game.json"

func save_game(data: Dictionary) -> bool:
    var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
    if file == null:
        push_error("Failed to open save file for writing")
        return false
    
    var json_string = JSON.stringify(data)
    file.store_string(json_string)
    file.close()
    return true

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_FILE):
        return {}
    
    var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
    if file == null:
        push_error("Failed to open save file for reading")
        return {}
    
    var json_string = file.get_as_text()
    file.close()
    
    var result = JSON.parse_string(json_string)
    if result == null:
        push_error("Failed to parse save file JSON")
        return {}
    
    return result
```

### Audio System

```gdscript
# audio_manager.gd (Autoload)
extends Node

@export var music_bus: String = "Music"
@export var sfx_bus: String = "SFX"

var music_players: Array[AudioStreamPlayer] = []
var sfx_players: Dictionary = {}
var music_tracks: Dictionary = {}
var sound_effects: Dictionary = {}

func _ready() -> void:
    # Create music players for crossfading
    for i in range(2):
        var player = AudioStreamPlayer.new()
        player.bus = music_bus
        player.volume_db = -80.0
        add_child(player)
        music_players.append(player)
    
    # Load music tracks
    load_audio_resources("res://assets/audio/music/", music_tracks)
    
    # Load sound effects
    load_audio_resources("res://assets/audio/sfx/", sound_effects)

func load_audio_resources(path: String, dict: Dictionary) -> void:
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if not dir.current_is_dir() and (file_name.ends_with(".ogg") or file_name.ends_with(".wav")):
                var key = file_name.get_basename()
                var resource = load(path + file_name)
                dict[key] = resource
            file_name = dir.get_next()

func play_music(track_name: String, fade_time: float = 1.0) -> void:
    if not music_tracks.has(track_name):
        push_error("Music track not found: " + track_name)
        return
    
    var current_player = music_players[0] if music_players[0].playing else music_players[1]
    var next_player = music_players[1] if current_player == music_players[0] else music_players[0]
    
    next_player.stream = music_tracks[track_name]
    next_player.volume_db = -80.0
    next_player.play()
    
    # Fade out current music and fade in new music
    var tween = create_tween()
    if current_player.playing:
        tween.tween_property(current_player, "volume_db", -80.0, fade_time)
    tween.tween_property(next_player, "volume_db", 0.0, fade_time)
    tween.tween_callback(func(): if current_player.playing: current_player.stop())

func play_sound(sound_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
    if not sound_effects.has(sound_name):
        push_error("Sound effect not found: " + sound_name)
        return
    
    # Reuse or create audio player
    var player: AudioStreamPlayer
    if sfx_players.has(sound_name) and not sfx_players[sound_name].playing:
        player = sfx_players[sound_name]
    else:
        player = AudioStreamPlayer.new()
        player.bus = sfx_bus
        add_child(player)
        sfx_players[sound_name] = player
    
    player.stream = sound_effects[sound_name]
    player.volume_db = volume_db
    player.pitch_scale = pitch_scale
    player.play()

func set_bus_volume(bus_name: String, volume_percent: float) -> void:
    var bus_idx = AudioServer.get_bus_index(bus_name)
    if bus_idx >= 0:
        var volume_db = linear_to_db(clamp(volume_percent, 0.0, 1.0))
        AudioServer.set_bus_volume_db(bus_idx, volume_db)
```

### Object Pooling

```gdscript
# object_pool.gd
class_name ObjectPool
extends Node

var scene: PackedScene
var pool: Array[Node] = []
var active_objects: Array[Node] = []

func _init(p_scene: PackedScene, initial_size: int = 10) -> void:
    scene = p_scene
    for i in range(initial_size):
        var instance = scene.instantiate()
        instance.visible = false
        pool.append(instance)

func get_object() -> Node:
    var obj: Node
    
    if pool.size() > 0:
        obj = pool.pop_back()
    else:
        obj = scene.instantiate()
    
    obj.visible = true
    active_objects.append(obj)
    return obj

func release_object(obj: Node) -> void:
    if obj in active_objects:
        active_objects.erase(obj)
        obj.visible = false
        
        # Reset object state
        if obj.has_method("reset"):
            obj.reset()
        
        pool.append(obj)

func release_all() -> void:
    for obj in active_objects.duplicate():
        release_object(obj)
