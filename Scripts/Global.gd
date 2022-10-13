extends Node

var player
var id = ""
var databaseData = {}
var playing = false
var ready = false

func _ready():
	var data = SaveLoad.loadData("jr-embercore-id.data")
	
	if data.has("id"):
		id = data["id"]
	else:
		id = ""
		for i in range(6):
			randomize()
			id += str(round(rand_range(0, 9)))
		SaveLoad.saveData("jr-embercore-id.data", {"id": id})
		
	while not Network.connected:
		yield(get_tree().create_timer(0.1), "timeout")
	print("Getting database data...")
	var list = yield(Network.getDatabase(), "completed")
	var databaseData = yield(Network.getDatabaseData(id), "completed")
	print("Done")
#	if databaseData:
#		print("Found score: " + str(databaseData["score"]))
#		score = databaseData["score"]
#	else:
#		print("Could not find data")
	
#	Network.data["score"] = score
	
	ready = true

func getVector(string):
	var vector = string
	vector[0] = "["
	vector[len(vector)-1] = "]"
	vector = parse_json(vector)
	vector = Vector2(vector[0], vector[1])
	return vector
