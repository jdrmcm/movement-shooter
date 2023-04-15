extends CharacterBody3D

const mouse_sensitivity: float = 0.08
var speed: float = 5.0
var h_acceleration = 6.0
var air_acceleration = 1.5
var normal_acceleration = 6.0
var gravity = 10
var jump = 5
var health = 100

var current_speed: float = 0.0
var current_speed_mult: float = 1.0
var zoom_sens_mult = 1.0

var cam_accel = 40
var full_contact = false
var snap_vector

@onready var look_pivot = $LookPivot
@onready var camera = $LookPivot/Camera
@onready var ground_check = $GroundCheck


@onready var body_col = $BodyArea
@onready var head_col = $HeadArea

@onready var root_node = $RootNode

@onready var hitmarker_sound = $HitmarkerSound
@onready var teleport_sound = $TeleportSound

var direction = Vector3()
var h_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

var spawnpoints = []


func _ready():
	name = str(get_multiplayer_authority())
	$Name.text = str(name)
	camera.current = is_multiplayer_authority()
	if is_multiplayer_authority():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		root_node.visible = false
		$BodyArea.queue_free()
		$HeadArea.queue_free()
		$Name.visible = false
	respawn_character()


func _input(event):
	if is_multiplayer_authority():
		if !Global.paused:
			if event is InputEventMouseMotion:
				rotate_y(deg_to_rad(((-event.relative.x * mouse_sensitivity) * Global.sensitivity_mult) * zoom_sens_mult))
				look_pivot.rotate_z(deg_to_rad(((-event.relative.y * mouse_sensitivity) * Global.sensitivity_mult) * zoom_sens_mult))
				look_pivot.rotation.x = clamp(look_pivot.rotation.x, deg_to_rad(-85), deg_to_rad(85))
			
		if event.is_action_pressed("pause") && Global.can_pause:
			Global.paused = !Global.paused
			
			if Global.paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


func _process(delta):
	if is_multiplayer_authority():
		if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
			camera.top_level = true
			camera.global_transform.origin = camera.global_transform.origin.lerp(look_pivot.global_transform.origin, cam_accel * delta)
			camera.rotation.y = rotation.y + deg_to_rad(90)
			camera.rotation.x = look_pivot.rotation.x
		else:
			camera.top_level = false
			camera.global_transform = look_pivot.global_transform
		
		
		if global_position.y <= -50.0:
			kill()
		
		
		if health <= 0:
			kill()


func _physics_process(delta):
	if is_multiplayer_authority():
		full_contact = ground_check.is_colliding()
		
		if not is_on_floor():
			gravity_vec += Vector3.DOWN * gravity * delta
			h_acceleration = air_acceleration
			snap_vector = -get_floor_normal()
		elif is_on_floor() and full_contact:
			snap_vector = -get_floor_normal()
			gravity_vec = Vector3.ZERO
			h_acceleration = normal_acceleration
		else:
			snap_vector = Vector3.ZERO
			gravity_vec = -get_floor_normal()
			h_acceleration = normal_acceleration
		
		if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
			snap_vector = Vector3.ZERO
			gravity_vec = Vector3.UP * jump
		
		current_speed = speed
		direction = Vector3()
		
		if Input.is_action_pressed("forward"):
			direction -= transform.basis.x
		if Input.is_action_pressed("back"):
			direction += transform.basis.x
		if Input.is_action_pressed("left"):
			direction += transform.basis.z
		if Input.is_action_pressed("right"):
			direction -= transform.basis.z
			
		direction = direction.normalized()
		h_velocity = h_velocity.lerp(direction * current_speed, h_acceleration * delta)
		movement.z = h_velocity.z + gravity_vec.z
		movement.x = h_velocity.x + gravity_vec.x
		movement.y = gravity_vec.y
		
		velocity = movement
		up_direction = Vector3.UP
		move_and_slide()
		rpc("remote_set_position", global_position, rotation, scale)


@rpc(unreliable)
func remote_set_position(authority_position, authority_rotation, authority_scale):
	global_position = authority_position
	rotation = authority_rotation
	scale = authority_scale


func damage(value):
	rpc("damage_player", value)


@rpc(any_peer, call_local)
func damage_player(value):
	if is_multiplayer_authority():
		hitmarker_sound.pitch_scale = randf_range(0.8, 1.2)
		hitmarker_sound.play()
	health -= value


func kill():
	health = 100
	respawn_character()


@rpc(call_local)
func respawn_character():
	populate_spawns()
	var spawn_pos = spawnpoints[(randi_range(0, len(spawnpoints) - 1))]
	global_position = spawn_pos.global_position
	if is_multiplayer_authority():
		teleport_sound.play()


func populate_spawns():
	spawnpoints.clear()
	for s in $"../Map/Spawnpoints".get_children():
		spawnpoints.append(s)


func zoom_sens_slow():
	zoom_sens_mult = 0.75


func zoom_sens_fast():
	zoom_sens_mult = 1.0
