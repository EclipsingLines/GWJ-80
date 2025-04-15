extends Node
class_name Bootstrap

# Configuration
@export var main_scene: PackedScene
@export var timeout: float = 10.0
@export var debug_level: DebugLevel = DebugLevel.INFO

# Services
var game_services: Dictionary = {}
var initialization_wrappers: Array = []

# Debug level enum
enum DebugLevel {
	NONE,
	INFO,
	DEBUG,
	VERBOSE
}

func _ready() -> void:
	initialize()

# Initialize all wrappers
func initialize() -> void:
	_log("Starting initialization", DebugLevel.INFO)
	
	var timeout_timer := get_tree().create_timer(timeout)
	timeout_timer.timeout.connect(_on_timeout)
	
	for wrapper in initialization_wrappers:
		if not _initialize_wrapper(wrapper):
			display_error("Initialization failed for: " + wrapper.name)
			return
			
	_log("All wrappers initialized", DebugLevel.INFO)
	load_main_scene()

# Initialize a single wrapper
func _initialize_wrapper(wrapper: Node) -> bool:
	_log("Initializing: " + wrapper.name, DebugLevel.DEBUG)
	
	if wrapper.has_method("initialize") and not wrapper.initialize():
		display_error(wrapper.error_message)
		return false
		
	if wrapper.has_method("get_service_name"):
		game_services[wrapper.get_service_name()] = wrapper
		
	return true

# Load the main scene
func load_main_scene() -> void:
	if not main_scene:
		display_error("Main scene not set")
		return
		
	_log("Loading main scene", DebugLevel.INFO)
	get_tree().call_deferred("change_scene_to_packed", main_scene)

# Handle timeout
func _on_timeout() -> void:
	display_error("Initialization timed out")
	get_tree().quit()

# Display error message
func display_error(message: String) -> void:
	push_error(message)
	_log(message, DebugLevel.INFO)

# Add a wrapper
func add_wrapper(wrapper: Node) -> void:
	initialization_wrappers.append(wrapper)
	add_child(wrapper)

# Log messages based on debug level
func _log(message: String, level: DebugLevel) -> void:
	if level <= debug_level:
		print("[Bootstrap] " + message)
