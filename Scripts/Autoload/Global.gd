extends Node

var player
var id = ""
var dbData = {}
var playing = false
var ready = false
var scene
var sceneName = "Menu"
var playTime = 0 
var fasterServer = false

var letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var version = 0

var defaultDatabase = {
	"username": "Unnamed",
	"volume": 83
}

func _process(delta):
	if sceneName == "main":
		playTime += delta
		Server.data["playing"] = true
	else:
		playTime = 0
		Server.data["playing"] = false
	if ready:
		Server.data["username"] = Server.dbData["username"]
	scene = get_tree().get_root().get_node(sceneName)

func changeScene(newScene):
	sceneName = newScene
	get_tree().change_scene("res://Scenes/" + newScene + ".tscn")

func _ready():
	Console.log2("Connecting...")
	while not Server.connected:
		yield(get_tree().create_timer(0.1), "timeout")
	
	var list = yield(Server.listData(), "completed")
	#print(list)
	var data = SaveLoad.loadData("embercore-id4.data")
	if data.has("id"):
		id = data["id"]
		if not id in list:
			Server.dbData = defaultDatabase.duplicate(true)
			Server.setData(id, Server.dbData)
			SaveLoad.saveData("embercore-id4.data", {"id": id})
	else:
		id = getId(10)
		Server.dbData = defaultDatabase.duplicate(true)
		Server.setData(id, Server.dbData)
		SaveLoad.saveData("embercore-id4.data", {"id": id})
	
	print(id)
	
	Console.log2("Getting database data...")
	Server.dbData = yield(Server.fetchData(id), "completed")
	for key in Server.dbData:
		if not key in defaultDatabase.keys():
			Server.dbData.erase(key)
	
	for key in defaultDatabase:
		if not key in Server.dbData.keys():
			Server.dbData[key] = defaultDatabase[key]
	print("Got data: " + str(Server.dbData))
	Console.log2("Done")
	
	ready = true

func getVector(string):
	var vector = string
	vector[0] = "["
	vector[len(vector)-1] = "]"
	vector = parse_json(vector)
	vector = Vector2(vector[0], vector[1])
	return vector

func getId(digits) -> String:
	var id = ""
	for i in range(digits):
		randomize()
		id += str(letters[floor(rand_range(0, len(letters)-1))])
	return id

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
