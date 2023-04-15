extends Node
class_name Weapon


@onready var shooting_controller = $"../../../"
@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioStreamPlayer

var damage = 0
var fire_rate = 0.0
var recoil = 5.0

var full_auto = false
var aimable = false

var weapon_name = "Weapon"


func shoot():
	shooting_controller.fire_bullet()


func get_animation_player() -> AnimationPlayer:
	return animation_player


func get_damage():
	return damage


func get_fire_rate():
	return fire_rate


func can_aim():
	return aimable


func is_full_auto():
	return full_auto


func check_shooting():
	if shooting_controller.current_weapon == self:
		pass


func play_gunshot():
	rpc("play_gunshot_remote")


@rpc(call_local)
func play_gunshot_remote():
	audio_player.pitch_scale = randf_range(0.8, 1.2)
	audio_player.play()
