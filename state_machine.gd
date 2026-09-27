class_name StateMachine
extends Node

## The node being controlled by this state machine (e.g., CharacterBody2D, Player, Enemy).
## If left unassigned, it defaults to the StateMachine's parent node.
@export var actor: Node

## The default state the machine starts in upon readiness. If unassigned, defaults to the first child state.
@export var initial_state: State

## The currently active state node.
var current_state: State

## Dictionary mapping state keys (StringName) to State node references for O(1) lookups.
var states: Dictionary = {}


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


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


## Handles transitioning between states, passing the [param msg] dictionary payload to the new state's enter() function.
func _on_child_transition(new_state_name: StringName, msg: Dictionary = {}) -> void:
	var key := StringName(new_state_name.to_lower())

	var new_state: State = states.get(key)
	if not new_state:
		push_warning("StateMachine: State '%s' does not exist." % new_state_name)
		return

	# Handle self-transitions or normal switches
	if current_state == new_state:
		current_state.exit()
		current_state.enter(msg)
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	new_state.enter(msg)
