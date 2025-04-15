# Enhancement Plan for Godot Brain Templates

## Overview

This document outlines a plan to enhance the existing brain templates with Godot-specific information, best practices, and guidelines. The goal is to make these templates as useful as possible for AI-assisted Godot development.

## Current Template Structure

- `projectbrief.md` - Core requirements and goals
- `.clinerules` - Project rules and guidelines (currently Go-focused)
- `prompt.md` - AI assistant guidelines and memory bank system
- `productContext.md` - Purpose, problems solved, expected behavior
- `activeContext.md` - Current focus, recent changes, next steps
- `systemPatterns.md` - Architecture, key technical decisions, design patterns
- `techContext.md` - Hosting environment and deployment pipelines
- `progress.md` - Tracks what works, what's left, known issues

## Enhancement Areas

### 1. Update `.clinerules` with Godot-Specific Guidelines

#### GDScript Style Guide

- Replace Go styling rules with GDScript style guidelines
- Add indentation rules (use tabs for indentation)
- Add naming conventions (snake_case for functions, variables, signals)
- Add class organization guidelines (tool, class_name, extends, signals, enums/constants, exported variables, public variables, private variables, onready variables, methods)

#### Project Structure

- Replace Go project structure with Godot-specific structure:
  - `/scenes` - All game scenes
  - `/scripts` - Standalone scripts
  - `/resources` - Custom resources
  - `/assets` - Textures, models, sounds, etc.
  - `/addons` - Third-party plugins
  - `/autoloads` - Singleton scripts

#### Testing Guidelines

- Update with Godot-specific testing approaches
- Include guidelines for using GUT (Godot Unit Testing) or other testing frameworks
- Add guidelines for scene testing vs script testing

### 2. Enhance `systemPatterns.md`

#### Scene Organization

- Add guidelines for scene composition and inheritance
- Include best practices for node structure
- Document when to use composition vs inheritance

#### Autoloads vs Internal Nodes

- Add guidelines for when to use autoloads
- Include best practices for dependency injection
- Document singleton pattern implementation in Godot

#### Godot Interfaces

- Add guidelines for creating and using interfaces in Godot
- Include examples of interface-like patterns

#### Godot Notifications

- Document common notification methods (_ready,_process, _physics_process, etc.)
- Include best practices for overriding notifications

### 3. Enhance `techContext.md`

#### Static Typing

- Add guidelines for using static typing in GDScript
- Include best practices for type annotations
- Document performance implications

#### Warning System

- Add guidelines for using GDScript's warning system
- Include common warnings and how to address them

#### Export System

- Document best practices for using exported variables
- Include guidelines for property hints and export categories

### 4. Create New Template: `gdscript_guidelines.md`

This new template would consolidate Godot-specific coding guidelines:

- GDScript style guide summary
- Documentation comment standards
- Format string usage
- Advanced GDScript features
- Static typing best practices
- Warning system usage
- Export system best practices

### 5. Create New Template: `godot_best_practices.md`

This new template would consolidate Godot-specific architectural and design guidelines:

- Scene organization best practices
- Node structure guidelines
- Autoloads vs internal nodes
- Signal usage patterns
- Resource management
- Performance optimization techniques
- Memory management considerations

## Implementation Strategy

1. Update `.clinerules` first to establish core guidelines
2. Enhance existing templates with Godot-specific information
3. Create new templates for consolidated guidelines
4. Update `prompt.md` to reference new templates and Godot-specific workflows
5. Create example snippets and patterns for common Godot development scenarios

## Consideration: Documentation Links

There are two approaches to handling the documentation links:

### Option 1: Incorporate into Templates

- Extract key information from each link
- Integrate directly into appropriate templates
- Add references to official documentation for further reading

### Option 2: Create Separate Reference Document

- Create `godot_resources.md` with categorized links
- Include brief summaries of what each resource covers
- Reference this document from other templates

## Recommendation

I recommend a hybrid approach:

1. Incorporate essential information directly into templates
2. Create a separate `godot_resources.md` document that organizes all links with summaries
3. Reference specific documentation links within templates where appropriate

This approach ensures that:

- Templates contain immediately useful information
- Developers can easily find official documentation for deeper dives
- The AI assistant has access to comprehensive guidelines without needing to follow external links
