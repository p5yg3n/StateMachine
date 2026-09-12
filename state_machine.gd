class_name StateMachine
extends Node

## The node being controlled by this state machine (e.g., CharacterBody2D, Player, Enemy).
@export var actor: Node

## The default state the machine starts in upon readiness. If unassigned, defaults to the first child state.
@export var initial_state: State

## The currently active state node.
var current_state: State

## Dictionary mapping lowercase state name keys to State node references for quick lookup.
var states: Dictionary = {}


func _ready() -> void:
	# Wait for the owner to be ready so sibling/parent nodes are fully initialized.
	await owner.ready

	for child in get_children():
		if child is State:
			var key := StringName(child.name.to_lower())
			states[key] = child
			child.transitioned.connect(_on_child_transition)
			child.state_machine = self

	if initial_state:
		current_state = initial_state
		current_state.enter()
	elif get_child_count() > 0 and get_child(0) is State:
		current_state = get_child(0) as State
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

	if current_state and StringName(current_state.name.to_lower()) == key:
		return

	var new_state: State = states.get(key)
	if not new_state:
		push_warning("StateMachine: State '%s' does not exist." % new_state_name)
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	new_state.enter(msg)
