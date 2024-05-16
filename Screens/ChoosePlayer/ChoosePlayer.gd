class_name ChoosePlayer
extends Control
var players:Array[Player]
const SIGN_GROUP = "sign_buttons"
const SIGNAL_SIGN_SELECTED = "sign_selected"

func _ready():
	%Label_player.text = "Jugador 1"
	refresh_enabled_signs()

func refresh_enabled_signs():
	for i:TextureButton in get_tree().get_nodes_in_group(SIGN_GROUP):
		if not i.button_pressed and not i.disabled:
			i.button_pressed = true
			return

func _on_button_save_player_pressed():
	var player_resource_path
	var player_name
	player_name = (%LineEdit_playerName as LineEdit).text
	%Label_player.text = "Jugador 2"
	for i:TextureButton in get_tree().get_nodes_in_group(SIGN_GROUP):
		if i.is_pressed():
			player_resource_path = i.texture_normal.resource_path
			i.queue_free()
			players.append(Player.new(player_name,player_resource_path))
			break
	if players.size() == 1:
		refresh_enabled_signs()
	else:
		change_scene()

func change_scene():
	var scene = preload("res://Screens/TicTacToe/TicTacToe.tscn")
	var node = scene.instantiate()
	node.players = players
	get_tree().root.add_child(node)
	self.queue_free()
