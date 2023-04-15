extends CharacterBody3D


const MOVE_SPEED: float = 3.5
const GRAVITY_ACCELERATION: float = 9.8

var input_move: Vector3 = Vector3()
var gravity_local: Vector3 = Vector3()
var snap_vector: Vector3 = Vector3()

var gravity = 20
var gravity_vec = Vector3()
var movement = Vector3()

@export
var health: int = 100


func _ready():
	pass


func _process(delta):
	if health <= 0:
		rpc("kill")


func damage(value):
	rpc("enemy_damage", value)


@rpc(call_local)
func enemy_damage(value):
	health -= value


func _physics_process(delta):
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
	else:
		gravity_vec = Vector3.ZERO

	movement.y = gravity_vec.y
	
	velocity = movement
	move_and_slide()


@rpc(any_peer, call_local)
func kill():
	queue_free()
