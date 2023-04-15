extends State
class_name PlayerState

var player

func _ready():
	await owner.ready
	
	player = owner
	
	assert(player != null)
