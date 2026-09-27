# Godot 4 Lightweight Finite State Machine (FSM)

A clean, robust, and production-ready Finite State Machine implementation for Godot 4. Designed with a decoupled component pattern, this architecture keeps your character and entity scripts organized by cleanly separating behaviors into distinct, manageable state nodes.

---

## ✨ Features

* **Decoupled Architecture:** Each state is its own self-contained script and node, preventing bloated "god scripts" filled with messy conditional logic.
* **Payload Passing:** Safely pass data dictionaries between states during transitions (e.g., carrying initial velocity, damage values, or target references).
* **Automatic Node Discovery:** Automatically detects, registers, and maps all child `State` nodes on startup.
* **Custom State IDs:** Easily override default node-name lookups using a custom `state_id` property.
* **Optimized Performance:** States disable their own processing by default; the state machine selectively ticks *only* the currently active state.
* **Smart Actor Propagation:** Automatically pushes actor references down to child states to eliminate boilerplate code and manual casting.
* **Self-Transitions:** Supports clean self-restarts and payload updates when a state transitions back to itself.

---

## 📦 Installation & Setup

1. Create a folder in your project directory (e.g., `res://scripts/state_machine/`).
2. Add the two core script files: `state.gd` and `state_machine.gd`.

---

## 🚀 Usage Guide

### 1. Setting up the State Machine Node

Attach the `state_machine.gd` script to a `Node` placed as a child of your character (e.g., `CharacterBody2D` or `CharacterBody3D`). The state machine will automatically target its direct parent as the `actor` if left unassigned in the inspector.

### 2. Creating an Individual State

Create a new script that extends `State` and override the virtual lifecycle methods as needed:

```gdscript
class_name PlayerIdleState
extends State

func enter(msg: Dictionary = {}) -> void:
	# Reset animations, velocity, or timers when entering idle
	actor.velocity = Vector2.ZERO
	# actor.animation_player.play("idle")

func physics_update(delta: float) -> void:
	# Check for transition conditions and pass optional payloads
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		transitioned.emit("PlayerMoveState", {"speed": 300.0})

```

### 3. Scene Tree Structure Example

```text
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
└── StateMachine (Node) [Script: state_machine.gd]
	├── IdleState (Node) [Script: PlayerIdleState.gd]
	├── MoveState (Node) [Script: PlayerMoveState.gd]
	└── JumpState (Node) [Script: PlayerJumpState.gd]

```

---

## 📚 Script Reference

### `State.gd`

The base class for all individual states. Inherit from this to build custom behavior logic.

| Property / Signal / Method | Description |
| --- | --- |
| `signal transitioned(new_state_name, msg)` | Emitted to request a switch to a new state by name, optionally sending a data dictionary payload. |
| `@export var state_id: StringName` | Optional explicit identifier for lookups. If left blank, defaults to the node's lowercase name. |
| `var actor` | Convenience reference pointing to the main entity node being controlled. |
| `enter(msg: Dictionary)` | Called once when the state becomes active. |
| `exit()` | Called once right before switching away from this state. |
| `update(delta)` | Called every frame (`_process`) while active. |
| `physics_update(delta)` | Called every physics frame (`_physics_process`) while active. |
| `handle_input(event)` | Called on unhandled input events while active. |

---

### `StateMachine.gd`

The orchestrator component that manages state lifecycles, routing, and switching logic.

| Export / Variable | Description |
| --- | --- |
| `@export var actor: Node` | The main entity node being manipulated. Auto-falls back to the parent node if unassigned. |
| `@export var initial_state: State` | The default state upon startup. Falls back to the first child state if unassigned. |
| `var current_state: State` | A reference to the currently active state node. |
| `var states: Dictionary` | Dictionary mapping lowercase state keys to their respective `State` node references. |

---

## 📝 License

Distributed under the MIT License. Feel free to use this in your own personal or commercial Godot projects.