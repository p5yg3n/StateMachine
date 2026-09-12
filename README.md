# Godot 4 Hierarchical Finite State Machine (FSM)

A lightweight, clean, and robust Finite State Machine implementation for Godot 4, designed using a decoupled component pattern. This architecture keeps your character and entity scripts organized by separating behaviors into distinct, manageable state nodes.


## Features

* **Decoupled Architecture:** Each state is its own self-contained script/node, preventing bloated "god scripts" full of conditional logic.
* **Payload Passing:** Safely pass data dictionaries between states during transitions (e.g., carrying velocity, damage values, or target references).
* **Automatic Node Discovery:** Automatically detects and registers all child `State` nodes on startup.
* **Optimized Performance:** States disable their own processing by default; the state machine selectively ticks only the currently active state.
* **Convenience Shortcuts:** Built-in `actor` reference mapping so states can easily access the character body or node they are controlling without boilerplate code casting.


## Installation & Setup

1. Create a folder in your Godot project (e.g., `res://scripts/state_machine/`).
2. Add the two core script files: `State.gd` and `StateMachine.gd`.


## Usage Guide

### 1. Setting up the State Machine Node

Attach the `StateMachine.gd` script to a `Node` placed as a child of your character (e.g., `CharacterBody2D` or `CharacterBody3D`).

Assign the actor reference or let it leverage the node's owner/parent structure.

### 2. Creating an Individual State

Create a new script that extends `State` and override the virtual methods as needed:

```gdscript
class_name PlayerIdleState
extends State

func enter(msg: Dictionary = {}) -> void:
	# Reset animations, velocity, or timers when entering idle
	actor.velocity = Vector2.ZERO
	# actor.animation_player.play("idle")

func physics_update(delta: float) -> void:
	# Check for transition conditions
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		transitioned.emit("PlayerMoveState", {"speed": 300.0})

```

### 3. Scene Tree Structure Example

```text
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
└── StateMachine (Node) [Script: StateMachine.gd]
    ├── IdleState (Node) [Script: PlayerIdleState.gd]
    ├── MoveState (Node) [Script: PlayerMoveState.gd]
    └── JumpState (Node) [Script: PlayerJumpState.gd]

```


## Script Reference

### `State.gd`

The base class for all individual states. Inherit from this to build custom behaviors.

| Method / Signal | Description |
| --- | --- |
| `signal transitioned(new_state_name, msg)` | Emitted to request a switch to a new state by name, optionally sending a data dictionary. |
| `var actor` | Convenience getter returning the parent actor node controlled by the state machine. |
| `enter(msg: Dictionary)` | Called once when the state becomes active. |
| `exit()` | Called once right before leaving this state. |
| `update(delta)` | Called every frame (`_process`) while active. |
| `physics_update(delta)` | Called every physics frame (`_physics_process`) while active. |
| `handle_input(event)` | Called on unhandled input events while active. |

### `StateMachine.gd`

The orchestrator component that manages state lifecycles and switching logic.

| Export / Variable | Description |
| --- | --- |
| `@export var actor: Node` | The main entity node being manipulated by the states. |
| `@export var initial_state: State` | The fallback default state upon startup. Defaults to the first child state if unassigned. |
| `var current_state: State` | A reference to the currently active state node. |


## License

Distributed under the MIT License. Feel free to use this in your own personal or commercial Godot projects.
