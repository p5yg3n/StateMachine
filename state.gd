class_name State
extends Node

## Emitted when the state wants to switch to a different state, optionally passing data.
signal transitioned(new_state_name: StringName, msg: Dictionary)

## A reference to the parent state machine managing this state.
var state_machine: StateMachine

## A convenience getter for the node being controlled by the state machine (e.g., the player or enemy).
## Assumes the parent StateMachine has an 'actor' property defined.
var actor: Node:
	get:
		return state_machine.actor if state_machine else null


## Called when the node enters the scene tree.
## Disables all automatic processing by default; processing is handled manually by the state machine when active.
func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)


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
