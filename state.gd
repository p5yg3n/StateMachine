class_name State
extends Node

## Emitted when the state wants to switch to a different state, optionally passing data.
signal transitioned(new_state_name: StringName, msg: Dictionary)

## Optional explicit identifier for this state. If empty, the node name (lowercase) is used.
@export var state_id: StringName = &""

## A reference to the parent state machine managing this state.
var state_machine: StateMachine

## A convenience reference to the node being controlled by the state machine.
var actor: Node


## Called when the node enters the scene tree.
## Disables automatic processing by default; processing is handled manually by the state machine when active.
func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)


## Safely retrieves the actor reference, issuing a warning if it is null.
func get_actor() -> Node:
	if not actor:
		push_warning("State '%s': Attempted to access 'actor', but it is null or unassigned." % name)
	return actor


## Returns whether this state can currently be exited. 
## Override this to lock a state (e.g., during an un-interruptible attack animation).
func can_exit() -> bool:
	return true


## Called by the state machine when entering this state.
## The optional [_msg] dictionary can carry data from the previous state.
func enter(_msg: Dictionary = {}) -> void:
	pass


## Called by the state machine just before switching away from this state.
func exit() -> void:
	pass


## Called every frame by the state machine if this state is currently active.
func update(_delta: float) -> void:
	pass


## Called every physics frame by the state machine if this state is currently active.
func physics_update(_delta: float) -> void:
	pass


## Called by the state machine to handle unhandled input events while this state is active.
func handle_input(_event: InputEvent) -> void:
	pass
