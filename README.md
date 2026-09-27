# Godot 4 Lightweight Finite State Machine (FSM)

A clean, robust, and production-ready Finite State Machine implementation for Godot 4. Designed with a decoupled component pattern, this architecture keeps your character and entity scripts organized by cleanly separating behaviors into distinct, manageable state nodes.

---

## ✨ Features

* **Decoupled Architecture:** Each state is its own self-contained script and node, preventing bloated "god scripts" filled with messy conditional logic.
* **Payload Passing:** Safely pass data dictionaries between states during transitions (e.g., carrying initial velocity, damage values, or target references).
* **Automatic Node Discovery:** Automatically detects, registers, and maps all child `State` nodes on startup.
* **Custom State IDs:** Easily override default node-name lookups using a custom `state_id` property.
* **Optimized Performance:** States disable their own processing by default; the state machine selectively ticks *only* the currently active state.
* **Smart Actor Propagation & Null-Guarding:** Automatically pushes actor references down to child states, featuring a safe `get_actor()` helper method to prevent runtime crashes and warn you if an actor is unassigned.
* **Transition Queueing & Buffering:** Supports state locking (`can_exit()`), automatically queueing and buffering transition requests so inputs or animations are never abruptly cut short.
* **Self-Transitions:** Supports clean self-restarts and payload updates when a state transitions back to itself.

---

## 📦 Installation & Setup

1. Create a folder in your project directory (e.g., `res://scripts/state_machine/`).
2. Add the two core script files: `state.gd` and `state_machine.gd`.

---

## 🚀 Usage Guide

### 1. Setting up the State Machine Node

Attach the `state_machine.gd` script to a `Node` placed as a child of your character (e.g., `CharacterBody2D` or `CharacterBody3D`). The state machine will automatically target its direct parent as the `actor` if left unassigned in the inspector.

### 2. Creating an Individual State (with Locks & Buffering)

Create a new script that extends `State` and override the virtual lifecycle methods. You can use `can_exit()` to lock a state (such as an un-interruptible attack animation) so that incoming transition requests are safely buffered until the state finishes:

```gdscript
class_name PlayerAttackState
extends State

var is_locked: bool = true

func enter(msg: Dictionary = {}) -> void:
	is_locked = true
	var player = get_actor() as CharacterBody2D
	if not player:
		return
		
	player.velocity = Vector2.ZERO
	# player.animation_player.play("attack")
	
	# Simulate attack recovery lockout duration
	await get_tree().create_timer(0.4).timeout
	is_locked = false

# Locks the state machine from switching away until the action completes
func can_exit() -> bool:
	return not is_locked

func physics_update(delta: float) -> void:
	# If the player inputs another action while locked, it gets buffered 
	# and fires automatically the exact instant is_locked becomes true!
	if Input.is_action_just_pressed("jump"):
		transitioned.emit("PlayerJumpState")

```

### 3. Scene Tree Structure Example

```text
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
└── StateMachine (Node) [Script: state_machine.gd]
	├── IdleState (Node) [Script: PlayerIdleState.gd]
	├── AttackState (Node) [Script: PlayerAttackState.gd]
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
| `get_actor() -> Node` | Safely returns the actor reference, throwing a helpful warning if unassigned to prevent crashes. |
| `can_exit() -> bool` | Returns whether the state can be exited. Override to lock states (e.g., attacks, dashes) and trigger transition buffering. |
| `enter(msg: Dictionary)` | Called once when the state becomes active. |
| `exit()` | Called once right before switching away from this state. |
| `update(delta)` | Called every frame (`_process`) while active. |
| `physics_update(delta)` | Called every physics frame (`_physics_process`) while active. |
| `handle_input(event)` | Called on unhandled input events while active. |

---

### `StateMachine.gd`

The orchestrator component that manages state lifecycles, routing, buffering, and switching logic.

| Export / Variable | Description |
| --- | --- |
| `@export var actor: Node` | The main entity node being manipulated. Auto-falls back to the parent node if unassigned. |
| `@export var initial_state: State` | The default state upon startup. Falls back to the first child state if unassigned. |
| `var current_state: State` | A reference to the currently active state node. |
| `var states: Dictionary` | Dictionary mapping lowercase state keys to their respective `State` node references. |

---

## 📝 License

Distributed under the MIT License. Feel free to use this in your own personal or commercial Godot projects.
