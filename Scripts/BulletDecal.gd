extends Node3D


func _ready():
	pass 


func _on_Timer_timeout():
	queue_free()
