extends StateMachine


func _ready():
	add_state("idle")
	add_state("walking")
	add_state("jumping")
	add_state("falling")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	pass

func _get_transition(delta):
	match state:
		states.idle:
			if parent.is_walking():
				return states.walking
			if parent.is_jumping():
				return states.jumping
		states.walking:
			if parent.is_jumping():
				return states.jumping
			if parent.is_idle():
				return states.idle
			if parent.is_falling():
				return states.falling
		states.jumping:
			if parent.is_falling():
				return states.falling
		states.falling:
			if parent.is_walking():
				return states.walking
			if parent.is_idle():
				return states.idle
