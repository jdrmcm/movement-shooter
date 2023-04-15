extends Control

var pause_state = false

var res = Vector2(1920, 1080)
var screen_size

@onready var sens_label = $Sensitivity/SensitivityAmount


func _ready():
	update_res(res)
	change_sens(1.0)


func _process(delta):
	visible = Global.paused


func _on_quit_pressed():
	Server.destroy_map()


func _on_reload_pressed():
	pass


func _on_resolution_item_selected(index):
		match index:
			0:
				res = Vector2(640, 480)
			1:
				res = Vector2(800 , 600)
			2:
				res = Vector2(1024, 768)
			3:
				res = Vector2(1280, 720)
			4:
				res = Vector2(1280, 800)
			5:
				res = Vector2(1366, 768)
			6:
				res = Vector2(1440, 900)
			7:
				res = Vector2(1680, 1050)
			8:
				res = Vector2(1920, 1080)
			9:
				res = Vector2(1920, 1200)
			10:
				res = Vector2(2560, 1440)
		update_res(res)


func update_res(r):
	DisplayServer.window_set_size(r)
	screen_size = DisplayServer.screen_get_size()
	DisplayServer.window_set_position(screen_size * 0.5 - res * 0.5)


func change_sens(value):
	sens_label.text = str(value)
	Global.sensitivity_mult = value


func _on_sensitivity_slider_value_changed(value):
	change_sens(value)
