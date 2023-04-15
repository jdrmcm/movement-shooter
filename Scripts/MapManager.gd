extends Node


var maps_dict = {
	"SPACE": preload("res://Scenes/Maps/space_map_3.tscn"),
	"TEST": preload("res://Scenes/Maps/test_map.tscn")
}

var current_map
var selected_map = 0


func get_map_input():
	match selected_map:
		0:
			return "SPACE"
		1:
			return "TEST"
		_:
			return "TEST"


func create_map(map):
	current_map = maps_dict.get(map).instantiate()
	get_tree().get_current_scene().add_child(current_map)


func destroy_map():
	get_tree().get_current_scene().remove_child(current_map)


func _on_map_selection_item_selected(index):
	selected_map = index

