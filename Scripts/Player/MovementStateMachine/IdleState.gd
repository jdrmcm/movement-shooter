extends PlayerState

func enter(_msg = {}):
	player.velocity = Vector3.ZERO

func update(delta):
	if not player.is_on_floor():
		state_machine.transition_to("Air")
	
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif (Input.is_action_pressed("forward") or Input.is_action_pressed("back") or
		Input.is_action_pressed("left") or Input.is_action_pressed("right")):
		state_machine.transition_to("Walk")
