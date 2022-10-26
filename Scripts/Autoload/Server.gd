extends Node

"""
Server Code:
https://replit.com/join/azfqmiywou-silverspace505
"""

var websocket_url = "wss://Embercore-Server.silverspace505.repl.co"
var player = load("res://Instances/Entities/Player.tscn")
var data = {}
var dbData = {}
var lastData = {}
var connected = false
var returnData = {}
var received = []
var lastReceived = []
var clearReceivedTimer = 0
var gotData = false
var auto = false
var admins = []
var admin = false
var reconnect = false
var usernames = {}

var peer = WebSocketClient.new()
var testing = false
var testIP = "localhost"
var serverIP = "server.silver505.tk"
var port = 31400

func _ready():
	var ip = ""
	if testing:
		ip = "ws://" + testIP
	else:
		ip = "wss://" + serverIP
	print("Connecting to " + ip + ":" + str(port))
	peer.connect_to_url(ip + ":" + str(port), [], true)
	get_tree().set_network_peer(peer)
	
	peer.connect("connection_failed", self, "_failed")
	peer.connect("connection_succeeded", self, "_connected")
	peer.connect("peer_disconnected", self, "_player_disconnected")

func fetchData(id):
	gotData = false
	returnData = {}
	if connected:
		rpc_id(1, "fetchData", id)
		while not gotData:
			yield(get_tree().create_timer(0), "timeout")
	else:
		yield(get_tree().create_timer(0), "timeout")
	return returnData

func setData(id, data):
	if connected:
		rpc_id(1, "setData", id, data)

func listData():
	gotData = false
	returnData = []
	if connected:
		rpc_id(1, "listData")
		while not gotData:
			yield(get_tree().create_timer(0), "timeout")
	else:
		yield(get_tree().create_timer(0), "timeout")
	return returnData
	
func deleteData(id):
	if connected:
		rpc_id(1, "deleteData", id)

remote func returnData(data):
	returnData = data
	gotData = true

remote func returnList(list):
	returnData = list
	gotData = true

func _player_connected(id):
	print("Player Joined: " + str(id))
	#instance_player(id)

func _player_disconnected(id):
	print("Player Left: " + str(id))
	leaveGame(id)

func _closed(was_clean = false):
	Console.log2("Disconnected")
	#print("disconnected: " + str(was_clean))
	connected = false
	Global.ready = false
	Global.changeScene("Disconnected")
	for node in Players.get_children():
		node.queue_free()
		
func _connected():
	print("Connected")
	connected = true

func _failed():
	print("Failed to connect")

remote func joinGame(id, username):
	yield(get_tree().create_timer(0.1), "timeout")
	if not Players.has_node(str(id)):
		usernames[id] = username
		rpc_id(get_tree().get_rpc_sender_id(), "joinGame", get_tree().get_network_unique_id(), dbData["username"])
		if Global.playTime > 0.5:
			Console.log2(username + " Joined!")
		if Global.sceneName == "main":
			Global.scene.get_node("Camera2D/Scale/Menu/Players").add_item(username, null, false)
			instance_player(id)

remote func leaveGame(id):
	if not usernames.has(id):
		return
	if not Players.has_node(str(id)):
		return
	var username = usernames[id]
	if Global.sceneName == "main":
		Console.log2(username + " Left :(")
	if Players.has_node(str(id)):
		Players.get_node(str(id)).queue_free()
		for i in range(Global.scene.get_node("Camera2D/Scale/Menu/Players").get_item_count()):
			var item = Global.scene.get_node("Camera2D/Scale/Menu/Players").get_item_text(i)
			if item == username:
				Global.scene.get_node("Camera2D/Scale/Menu/Players").remove_item(i)

func _exit_tree():
	peer.disconnect_from_host()

func instance_player(id, pos=Vector2(0, 0)) -> Object:
	var player_instance = Global.instance_node_at_location(player, Players, pos)
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	return player_instance

func _process(delta):
	if dbData != lastData and Global.ready:
		setData(Global.id, dbData)
		lastData = dbData.duplicate(true)
