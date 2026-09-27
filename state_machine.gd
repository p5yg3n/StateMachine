class_name StateMachine
extends Node

## The node being controlled by this state machine (e.g., CharacterBody2D, Player, Enemy).
## If left unassigned, it defaults to the StateMachine's parent node.
@export var actor: Node

## The default state the machine starts in upon readiness. If unassigned, defaults to the first child state.
@export var initial_state: State

## The currently active state node.
var current_state: State

## Dictionary mapping lowercase state keys to State node references.
var states: Dictionary = {}

## Stores a requested transition if the current state is locked (`can_exit() == false`).
var _pending_transition: Dictionary = {}


func _ready() -> void:
	# Fallback actor assignment if not set in the inspector
	if actor == null:
		actor = get_parent()

	# Register all child states
	for child in get_children():
		if child is State:
			# Use explicit state_id if provided, otherwise fallback to the node's name
			var id: StringName = child.state_id if child.state_id != &"" else StringName(child.name)
			var key := StringName(id.to_lower())

			if states.has(key):
				push_warning("StateMachine: Duplicate state key '%s' found." % key)

			states[key] = child
			child.transitioned.connect(_on_child_transition)
			child.state_machine = self
			child.actor = actor

	# Initialize starting state
	if initial_state:
		current_state = initial_state
	elif get_child_count() > 0 and get_child(0) is State:
		current_state = get_child(0) as State

	if current_state:
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
	_check_pending_transition()


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
	_check_pending_transition()


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


## Handles transitioning between states, queueing if the current state is locked.
## Passes the optional [msg] dictionary payload to the new state's enter() function.
func _on_child_transition(new_state_name: StringName, msg: Dictionary = {}) -> void:
	var key := StringName(new_state_name.to_lower())

	var new_state: State = states.get(key)
	if not new_state:
		push_warning("StateMachine: State '%s' does not exist." % new_state_name)
		return

	# If the current state cannot be exited yet, buffer the transition request
	if current_state and not current_state.can_exit():
		_pending_transition = {"key": key, "msg": msg}
		return

	_execute_transition(new_state, msg)


## Checks if a queued transition can now execute because the state unlocked.
func _check_pending_transition() -> void:
	if _pending_transition.is_empty():
		return

	if current_state and current_state.can_exit():
		var next_key: StringName = _pending_transition["key"]
		var next_msg: Dictionary = _pending_transition["msg"]
		_pending_transition.clear()

		var next_state: State = states.get(next_key)
		if next_state:
			_execute_transition(next_state, next_msg)


## Internal helper to handle clean switching and self-transitions.
func _execute_transition(new_state: State, msg: Dictionary) -> void:
	if current_state == new_state:
		current_state.exit()
		current_state.enter(msg)
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	new_state.enter(msg)
