extends Node3D


@onready var aimcast = $Camera/AimCast
@onready var active_weapon = $Camera/Weapons/Unarmed
@onready var animation_player = $Camera/Weapons/Unarmed/AnimationPlayer
@onready var weapon_controller = $Camera/Weapons
@onready var hitmarker_anim = $"../HUD/HitmarkerAnimation"
@onready var sniper_scope = $"../HUD/SniperScope"
@onready var player_animation_player = $"../AnimationPlayer"
@onready var temp_sens

@onready var zoom_in_sound = $"../ZoomInSound"
@onready var zoom_out_sound = $"../ZoomOutSound"
@onready var hitmarker_sound = $"../HitmarkerSound"
@onready var headshot_sound = $"../HeadshotSound"

#@onready var synchronizer = $"../MultiplayerSynchronizer"

@onready var b_decal = preload("res://Scenes/BulletDecal.tscn")

var is_shooting: bool = false
var fire_rate: float = 2.0
var damage : int = 10
var full_auto = false


func _ready():
	pass


func _input(event):
	if is_multiplayer_authority():
		if !Global.paused:
			if Input.is_action_pressed("shoot"): 
				shoot()
			if Input.is_action_just_released("shoot"):
				shoot_stop()
			if Input.is_action_just_pressed("alt_fire") and active_weapon.can_aim():
				aim()
			if Input.is_action_just_released("alt_fire") and active_weapon.can_aim():
				stop_aim()


func _process(delta):
	if is_multiplayer_authority():
		active_weapon = get_active_weapon()
		animation_player = active_weapon.get_animation_player()
		damage = active_weapon.get_damage()
		fire_rate = active_weapon.get_fire_rate()


func shoot():
	if is_multiplayer_authority():
		if not is_shooting:
			is_shooting = true
			if active_weapon.is_full_auto():
				animation_player.get_animation("Fire").loop_mode = true
			animation_player.play("Fire", -1.0, fire_rate)


func shoot_stop():
	if is_multiplayer_authority():
		is_shooting = false
		animation_player.get_animation("Fire").loop_mode = false


func fire_bullet():
	if is_multiplayer_authority():
		if aimcast.is_colliding():
			var target = aimcast.get_collider()
			if target.is_in_group("enemy_head"):
				target.damage(damage * 2)
				headshot_sound.pitch_scale = randf_range(0.8, 1.2)
				headshot_sound.play()
				hitmarker_anim.play("Hitmarker")
			if target.is_in_group("enemy_body"):
				target.damage(damage)
				hitmarker_sound.pitch_scale = randf_range(0.8, 1.2)
				hitmarker_sound.play()
				hitmarker_anim.play("Hitmarker")
			#if target.is_in_group("ground"):
			#	var b = b_decal.instantiate()
			#	aimcast.get_collider().add_child(b)
			#	b.global_transform.origin = aimcast.get_collision_point()
			#	b.look_at(aimcast.get_collision_point() + aimcast.get_collision_normal(), Vector3.UP)


func aim():
	$Camera/HUD/SniperScope.visible = true
	player_animation_player.play("SniperZoomIn")
	zoom_in_sound.play()


func stop_aim():
	$Camera/HUD/SniperScope.visible = false
	player_animation_player.play("SniperZoomOut")
	zoom_out_sound.play()


func get_active_weapon():
	return weapon_controller.get_current_weapon()
