extends Node


const factor: float = 0.25
var slowing: bool = false


func _ready():
	slowing = false


func _input(event):
	if Input.is_action_just_pressed("ability_1"):
		slowing = !slowing


func _process(delta):
	if slowing:
		Engine.time_scale = factor
	else:
		Engine.time_scale = 1
