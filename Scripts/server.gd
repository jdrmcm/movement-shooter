extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()

var ADDRESS = "127.0.0.1"
var PORT = 1928
var use_upnp = false

var connected_peer_ids = []

@onready var map_manager = $MapManager


func _ready():
	randomize()

func _on_host_pressed():
	$NetworkInfo/NetworkSideDisplay.text = "Server"
	show_menu(false)
	if use_upnp:
		var upnp = UPNP.new()
		var discover_result = upnp.discover()
		if discover_result == UPNP.UPNP_RESULT_SUCCESS:
			if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
				var map_result_udp = upnp.add_port_mapping(1928, 0, "godot_udp", "UDP", 0)
				var map_result_tcp = upnp.add_port_mapping(1928, 0, "godot_tcp", "TCP", 0)
				if not map_result_udp == UPNP.UPNP_RESULT_SUCCESS:
					upnp.add_port_mapping(1928, 0, "", "UDP")
				if not map_result_tcp == UPNP.UPNP_RESULT_SUCCESS:
					upnp.add_port_mapping(1928, 0, "", "TCP")
			else:print("INVALID GATEWAY")
		else:print("DISCOVER FAILED")
		
		print(upnp.query_external_address())
	
	
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	$NetworkInfo/UniquePeerID.text = str(multiplayer.get_unique_id())
	
	map_manager.create_map(map_manager.get_map_input())
	add_player_character(1)
	
	multiplayer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			rpc_id(new_peer_id, "create_map_remote", map_manager.get_map_input())
			rpc("add_newly_connected_player_character", new_peer_id)
			rpc_id(new_peer_id, "add_previously_connected_player_characters", connected_peer_ids)
			add_player_character(new_peer_id)
	)


func boot_to_menu():
	show_menu(true)
	Global.can_pause = false
	Global.paused = false

func _on_join_pressed():
	$NetworkInfo/NetworkSideDisplay.text = "Client"
	show_menu(false)
	multiplayer_peer.create_client($Menu/Address.text, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	$NetworkInfo/UniquePeerID.text = str(multiplayer.get_unique_id())


func add_player_character(peer_id):
	connected_peer_ids.append(peer_id)
	var player_character = preload("res://Scenes/Player.tscn").instantiate()
	player_character.set_multiplayer_authority(peer_id)
	get_node("/root/World").add_child(player_character)
	Global.can_pause = true


func destroy_map():
	map_manager.destroy_map()


func show_menu(value):
	$Menu.visible = value


@rpc
func create_map_remote(map):
	map_manager.create_map(map)


@rpc
func add_newly_connected_player_character(new_peer_id):
	add_player_character(new_peer_id)


@rpc
func add_previously_connected_player_characters(peer_ids):
	for peer_id in peer_ids:
		add_player_character(peer_id)


func _on_upnp_toggled(button_pressed):
	use_upnp = !use_upnp
