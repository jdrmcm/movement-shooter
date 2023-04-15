extends Node3D


var health: int = 50


func _ready():
	pass 


func damage(d):
	health -= d


func _process(delta):
	if health <= 0:
		get_parent().queue_free()
