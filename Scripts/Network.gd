extends Node

"""
Server Code:
https://replit.com/join/azfqmiywou-silverspace505
"""

var websocket_url = "wss://Embercore-Server.silverspace505.repl.co"
var player = load("res://entities/Player.tscn")
var playerData = {}
var data = {}
var databaseData = {}
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

var peer = WebSocketClient.new()
var id = ""

func connectToServer():
	peer.disconnect_from_host()
	peer = WebSocketClient.new()
	peer.connect("connection_established", self, "_connected")
	peer.connect("connection_error", self, "_closed")
	peer.connect("connection_closed", self, "_closed")
	peer.connect("data_received", self, "_on_data")
	var err = peer.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _ready():
	id = Global.getId(10)
	
	peer.connect("connection_established", self, "_connected")
	peer.connect("connection_error", self, "_closed")
	peer.connect("connection_closed", self, "_closed")
	peer.connect("data_received", self, "_on_data")
	var err = peer.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	
	yield(get_tree().create_timer(2), "timeout")
	while not connected:
		print("Retrying")
		connectToServer()
		yield(get_tree().create_timer(2), "timeout")

func sendMsg(data, wait=false):
	peer.get_peer(1).put_packet(JSON.print(data).to_utf8())
	if wait:
		returnData = {}
		gotData = false
		while not gotData:
			yield(get_tree().create_timer(0.1), "timeout")
		return returnData
		

func updateDatabaseData(id):
	sendMsg({"databaseset": databaseData, "databaseid": id})

func getDatabaseData(id):
	return yield(sendMsg({"databaseget": id}, true), "completed")

func getDatabase():
	return yield(sendMsg({"databaselist": "idk"}, true), "completed")
	
func deleteDatabaseData(id):
	sendMsg({"databasedelete": id})

func _player_connected(id):
	print("Player Joined: " + id)
	#instance_player(id)

func _player_disconnected(id):
	print("Player Left: " + id)
	playerLeaveGame(id)
	playerData.erase(id)

func _closed(was_clean = false):
	var lastScene = Global.sceneName
	Console.log2("Disconnected")
	#print("disconnected: " + str(was_clean))
	connected = false
	Global.ready = false
	Global.changeScene("Disconnected")
	for node in Players.get_children():
		node.queue_free()
	
	if auto and not was_clean:
		while not connected:
			print("Retrying")
			connectToServer()
			yield(get_tree().create_timer(2), "timeout")
		if lastScene == "Game":
			sendMsg({"joinGame": id})
		Global.changeScene(lastScene)
		Global.ready = true

func _connected(proto):
	print("Connected")
	connected = true
	sendMsg({"join": id, "password": "wearecoolerthanyou"})
	#print("Connected with protocol: ", proto)
	#peer.get_peer(1).put_packet(JSON.print({"join": id, "password": "weroweinafoien"}).to_utf8())
	#Global.player = instance_player(id)

func playerJoinGame(id):
	if Global.playTime > 0.5:
		Console.log2(playerData[id]["username"] + " Joined!")
	if Global.sceneName == "main":
		instance_player(id)

func playerLeaveGame(id):
	if Global.sceneName == "main":
		Console.log2(playerData[id]["username"] + " Left :(")
	if Players.has_node(str(id)):
		Players.get_node(str(id)).queue_free()

func _on_data():
	var data = JSON.parse(peer.get_peer(1).get_packet().get_string_from_utf8()).result
	#print(data)
	#print("Got data from server: ", data)
	
	var found = false
	if data["secure"]:
		var dataJSON = JSON.print(data)
		
		for data2 in received:
			if JSON.print(data2) == dataJSON:
				found = true
	
	if not found:
		if data["secure"]:
			received.append(data)
			sendMsg({"received": data})
		
		if data.has("connected"):
			_player_connected(data["connected"])
		if data.has("disconnected"):
			_player_disconnected(data["disconnected"])
		if data.has("joingame"):
			playerJoinGame(data["joingame"])
		if data.has("leavegame"):
			playerLeaveGame(data["leavegame"])
		if data.has("players"):
			for player in data["players"]:
				if player != id:
					_player_connected(player)
		if data.has("data"):
			playerData[data["id"]] = data["data"]
		if data.has("databaseget"):
			gotData = true
			returnData = data["databaseget"]
		if data.has("databaselist"):
			gotData = true
			returnData = data["databaselist"]
		if data.has("send") and Global.sceneName == "main":
			Console.log2(data["send"])
	

func _process(delta):
	peer.poll()
	if Global.ready:
		data["scene"] = Global.sceneName
		playerData[id] = data
		sendMsg({"data": data, "id": id})
		admin = Global.id in admins
	clearReceivedTimer += delta
	if clearReceivedTimer >= 1:
		clearReceivedTimer = 0
		if Global.ready:
			if JSON.print(databaseData) != JSON.print(lastData):
				updateDatabaseData(Global.id)
				lastData = databaseData.duplicate(true)
		var i = 0
		for data2 in received:
			var dataJSON = JSON.print(data2)
			var found = false

			for data3 in lastReceived:
				if JSON.print(data3) == dataJSON:
					found = true
			if found:
				received.remove(i)
			i += 1
		lastReceived = received.duplicate(true)

func _exit_tree():
	peer.disconnect_from_host()

func instance_player(id, pos=Vector2(0, 0)) -> Object:
	var player_instance = Global.instance_node_at_location(player, Players, pos)
	player_instance.name = str(id)
	return player_instance
