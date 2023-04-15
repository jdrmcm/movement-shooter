extends PlayerState


var speed = 5.0
var h_acceleration = 6.0
var current_speed = 0.0

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()

func physics_update(delta):
	if !player.is_on_floor() and !player.full_contact:
		state_machine.transition_to("Air")
		return
	
	if Input.is_action_pressed("forward"):
		direction -= player.transform.basis.x
	if Input.is_action_pressed("back"):
		direction += player.transform.basis.x
	if Input.is_action_pressed("left"):
		direction += player.transform.basis.z
	if Input.is_action_pressed("right"):
		direction -= player.transform.basis.z
	
	
	direction = direction.normalized()
	h_velocity = h_velocity.lerp(direction * speed, h_acceleration * delta)
	movement.z = h_velocity.z
	movement.x = h_velocity.x
	
	player.velocity = movement
	player.up_direction = Vector3.UP
	player.move_and_slide()


func update(delta):
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {do_jump = true})
	elif is_equal_approx(movement.x, 0.0):
		state_machine.transition_to("Idle")
