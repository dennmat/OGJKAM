extends Node

var players = []

const PlayerInfo = preload("PlayerInfo.gd")
const GameState = preload("GameState.gd")

onready var game_state = GameState.new()

var current_scene = null

func getFromDevice(device_id):
	for player in players:
		if player.device_id == device_id:
			return player
	return null

func playersForTeam(team):
	var ret = []
	for player in players:
		if player.team == team:
			ret.append(player)
	return ret

func addPlayer(device_id, team, position):
	var player = PlayerInfo.new()
	
	player.index = self.players.size()
	player.device_id = device_id
	player.team = team
	player.position = position
	
	self.players.append(player)
	
	return player

func _ready():
	self.current_scene = get_tree().get_current_scene()
	
	var slist = get_node("/root/MusicPlayer").get_sample_library().get_sample_list()
	
	randomize()
	var index = randi() % slist.size()
	
	get_node("/root/MusicPlayer").play(slist[index])
	

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function from the running scene.
	# Deleting the current scene at this point might be
	# a bad idea, because it may be inside of a callback or function of it.
	# The worst case will be a crash or unexpected behavior.
	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	game_state.reset_game()
	call_deferred("_deferred_goto_scene",path)

func _deferred_goto_scene(path):
	# Immediately free the current scene,
	# there is no risk here.
	self.current_scene.free()
	
	# Load new scene
	var s = ResourceLoader.load(path)
	
	# Instance the new scene
	self.current_scene = s.instance()
	
	# Add it to the active scene, as child of root
	get_tree().get_root().add_child(self.current_scene)
	
	# optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene(self.current_scene)