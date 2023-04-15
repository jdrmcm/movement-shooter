extends Node3D


var all_weapons = {}
var hud
var current_weapon

var mouse_mov
var sway_threshold = 5
var sway_lerp = 5

var sway_left : Vector3
var sway_right : Vector3
var sway_normal : Vector3

@onready var shooting = $"../.."


func _ready():
	if is_multiplayer_authority():
		hud = owner.get_node("HUD")
		
		all_weapons = {
			"Unarmed" : preload("res://Scenes/Weapons/Unarmed.tscn"),
			"SMG" : preload("res://Scenes/Weapons/SMG.tscn")
		}
		
		current_weapon = "UNARMED"
		rpc("update_weapon", get_current_weapon())
		
		sway_left = rotation
		sway_right = rotation
		sway_normal = rotation
		
		sway_left.y -= 0.1
		sway_right.y += 0.1


func _input(event):
	if is_multiplayer_authority():
		if !Global.paused:
			if Input.is_action_just_pressed("slot_1"):
				rpc("update_weapon", "UNARMED")
			if Input.is_action_just_pressed("slot_2"):
				rpc("update_weapon", "SMG")
			if Input.is_action_just_pressed("slot_3"):
				rpc("update_weapon", "SNIPER")
			
			
			if event is InputEventMouseMotion:
				mouse_mov = -event.relative.x


func _process(delta):
	if is_multiplayer_authority():
		if mouse_mov != null:
			if mouse_mov > sway_threshold:
				rotation = rotation.lerp(sway_left, sway_lerp * delta)
			elif mouse_mov < -sway_threshold:
				rotation = rotation.lerp(sway_right, sway_lerp * delta)
			else:
				rotation = rotation.lerp(sway_normal, sway_lerp * delta)


@rpc(call_local)
func update_weapon(weapon):
	current_weapon = weapon
	for n in get_children():
		n.visible = false
	get_current_weapon().visible = true



func get_current_weapon() -> Node:
	match current_weapon:
		"SMG":
			return $SMG
		"UNARMED":
			return $Unarmed
		"SNIPER":
			return $Sniper
		_:
			return $Unarmed
