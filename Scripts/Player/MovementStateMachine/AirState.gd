extends PlayerState

var jump_force = 5.0
var speed = 5.0
var air_acceleration = 1.5
var current_speed = 0.0
var gravity = 10.0

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()


func enter(msg = {}):
	if msg.has("do_jump"):
		gravity_vec = Vector3.UP * jump_force


func physics_update(delta):
	
	gravity_vec += Vector3.DOWN * gravity * delta
	
	if Input.is_action_pressed("forward"):
		direction -= player.transform.basis.x
	if Input.is_action_pressed("back"):
		direction += player.transform.basis.x
	if Input.is_action_pressed("left"):
		direction += player.transform.basis.z
	if Input.is_action_pressed("right"):
		direction -= player.transform.basis.z
	
	direction = direction.normalized()
	h_velocity = h_velocity.lerp(direction * speed, air_acceleration * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	player.velocity = movement
	player.up_direction = Vector3.UP
	player.move_and_slide()
