extends Node
class_name StateMachine

signal transitioned(state_name)

@export var initial_state : NodePath

@onready var state = get_node(initial_state)

func _ready():
	await owner.ready
	for child in get_children():
		child.state_machine = self
	state.enter()
	print(owner)


func _unhandled_input(event):
	state.handle_input(event)


func _process(delta):
	state.update(delta)


func _physics_process(delta):
	state.physics_update(delta)


func transition_to(target_state_name, msg = {}):
	if not has_node(target_state_name):
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)
