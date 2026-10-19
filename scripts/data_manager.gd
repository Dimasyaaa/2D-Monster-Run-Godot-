extends Node

const SAVE_FILE = "user://game_data.save"
var high_score = 0

func _ready():
	load_data()

func save_data():
	var data = {"high_score": high_score}
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()

func load_data():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var data = JSON.parse_string(content)
			if data:
				high_score = data.get("high_score", 0)

func update_high_score(score: int):
	if score > high_score:
		high_score = score
		save_data()
		return true
	return false
