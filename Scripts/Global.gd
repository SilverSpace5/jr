extends Node

var player
var id = ""
var databaseData = {}
var playing = false
var ready = false
var scene
var sceneName = "Connect"
var playTime = 0 
var fasterNetwork = false

var letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var version = 0

var defaultDatabase = {
	"username": "Unnamed",
	"volume": 100
}

func _process(delta):
	if Input.is_action_just_pressed("fasterNetwork"):
		if fasterNetwork:
			fasterNetwork = false
		else:
			fasterNetwork = true
	if sceneName == "main":
		playTime += delta
		Network.data["playing"] = true
	else:
		playTime = 0
		Network.data["playing"] = false
	if ready:
		Network.data["username"] = Network.databaseData["username"]
	scene = get_tree().get_root().get_node(sceneName)

func changeScene(newScene):
	sceneName = newScene
	get_tree().change_scene("res://Scenes/" + newScene + ".tscn")

func _ready():
	Console.log2("Connecting...")
	while not Network.connected:
		yield(get_tree().create_timer(0.1), "timeout")
		
	var data = SaveLoad.loadData("embercore-id3.data")
	if data.has("id"):
		id = data["id"]
	else:
		id = getId(10)
		Network.databaseData = defaultDatabase.duplicate(true)
		Network.updateDatabaseData(id)
		SaveLoad.saveData("embercore-id3.data", {"id": id})
	
	print(id)
	
	Console.log2("Getting database data...")
	var list = yield(Network.getDatabase(), "completed")
	Network.databaseData = yield(Network.getDatabaseData(id), "completed")
	for key in Network.databaseData:
		if not key in defaultDatabase.keys():
			Network.databaseData.erase(key)
	
	for key in defaultDatabase:
		if not key in Network.databaseData.keys():
			Network.databaseData[key] = defaultDatabase[key]
	print("Got data: " + str(Network.databaseData))
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
