extends Node
class_name InitializationWrapper

# Requirements that must be met before initialization
@export var requirements: Array[String] = []

# Error message storage
var error_message: String = ""

# Abstract method for initialization
func initialize() -> bool:
	if not check_requirements():
		return false
		
	# Implementation should be provided by child classes
	push_error("initialize() not implemented in InitializationWrapper subclass")
	return false

# Check if all requirements are met
func check_requirements() -> bool:
	for requirement in requirements:
		if not _is_requirement_met(requirement):
			error_message = "Requirement not met: " + requirement
			return false
	return true

# Abstract method for disposal
func dispose() -> void:
	push_error("dispose() not implemented in InitializationWrapper subclass")

# Handle errors
func on_error(message: String) -> void:
	error_message = message
	push_error(message)

# Internal method to check individual requirements
func _is_requirement_met(requirement: String) -> bool:
	# Default implementation checks if requirement is a node path
	if has_node(requirement):
		return true
	return false
