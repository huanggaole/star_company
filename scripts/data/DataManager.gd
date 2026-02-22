extends Node

const STATIC_DATA_PATH = "res://data/static_data.json"
const ARTIST_CONFIG_PATH = "res://data/artist_config.csv"
const SAVE_PATH = "user://savegame.tres"

var ARTIST_SCRIPT # Lazy load

var static_data: StaticData
var dynamic_data: DynamicData

func _ready():
	print("DataManager: Ready start")
	ARTIST_SCRIPT = load("res://scripts/company/Artist.gd")
	if not ARTIST_SCRIPT:
		printerr("CRITICAL: Failed to load Artist.gd")
	
	_load_static_data()
	# For testing, we can initialize a new game if no save exists
	if not dynamic_data:
		print("DataManager: No dynamic data, creating new game")
		new_game()

func _init_artists_deprecated():
	print("DataManager: Initializing artists from CSV...")
	if not ARTIST_SCRIPT:
		printerr("CRITICAL: Cannot init artists, Artist script missing.")
		return

	if not FileAccess.file_exists(ARTIST_CONFIG_PATH):
		printerr("Artist config not found: ", ARTIST_CONFIG_PATH)
		return

	var file = FileAccess.open(ARTIST_CONFIG_PATH, FileAccess.READ)
	var header = file.get_csv_line() # dynamic header parsing? or assume fixed?
	# Assume fixed structure for now based on our CSV, or map by header
	# Let's map by header for robustness
	var header_map = {}
	for i in range(header.size()):
		header_map[header[i]] = i
		
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < header.size(): continue
		
		var artist = ARTIST_SCRIPT.new()
		artist.name = line[header_map["name"]]
		artist.age = int(line[header_map["age"]])
		artist.gender = int(line[header_map["gender"]])
		
		artist.acting = int(line[header_map["acting"]])
		artist.singing = int(line[header_map["singing"]])
		artist.speech = int(line[header_map["speech"]])
		artist.appearance = int(line[header_map["appearance"]])
		artist.smarts = int(line[header_map["smarts"]])
		artist.morality = int(line[header_map["morality"]])
		artist.sports = int(line[header_map["sports"]])
		artist.rebellion = int(line[header_map["rebellion"]])
		artist.sexy = int(line[header_map["sexy"]])
		artist.confidence = int(line[header_map["confidence"]])
		
		artist.stamina = int(line[header_map["stamina"]])
		artist.stress = int(line[header_map["stress"]])
		artist.fame = int(line[header_map["fame"]])
		
		dynamic_data.add_artist(artist)
	
	print("Initialized ", dynamic_data.artists.size(), " artists from config.")

func _load_static_data():
	static_data = StaticData.new()
	static_data.load_data(STATIC_DATA_PATH)

func new_game():
	start_new_game(1, 0) # Default: Male, Likes Female if called without params

func start_new_game(gender: int, orientation: int):
	print("Starting New Game with Gender: ", gender, " Orientation: ", orientation)
	dynamic_data = DynamicData.new()
	# Initialize default values
	dynamic_data.company_name = "New Star Co."
	dynamic_data.money = 50000
	dynamic_data.player_gender = gender
	dynamic_data.player_orientation = orientation
	
	_init_artists_based_on_orientation(orientation)

func _init_artists_based_on_orientation(orientation: int):
	print("DataManager: Initializing artists for orientation: ", orientation)
	if not ARTIST_SCRIPT:
		printerr("CRITICAL: Cannot init artists, Artist script missing.")
		return

	if not FileAccess.file_exists(ARTIST_CONFIG_PATH):
		printerr("Artist config not found: ", ARTIST_CONFIG_PATH)
		return

	var file = FileAccess.open(ARTIST_CONFIG_PATH, FileAccess.READ)
	var header = file.get_csv_line()
	var header_map = {}
	for i in range(header.size()):
		header_map[header[i]] = i
		
	var target_gender = orientation # 0: Female, 1: Male, 2: Bisexual (Any)
	
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < header.size(): continue
		
		# Check gender before adding
		var gender = int(line[header_map["gender"]])
		
		# For Bisexual (2), we accept everyone (or maybe a mix?)
		# For now, if target_gender is 2, ignore gender check.
		
		if target_gender == 2 or gender == target_gender:
			var artist = ARTIST_SCRIPT.new()
			artist.name = line[header_map["name"]]
			artist.age = int(line[header_map["age"]])
			artist.gender = gender
			
			artist.acting = int(line[header_map["acting"]])
			artist.singing = int(line[header_map["singing"]])
			artist.speech = int(line[header_map["speech"]])
			artist.appearance = int(line[header_map["appearance"]])
			artist.smarts = int(line[header_map["smarts"]])
			artist.morality = int(line[header_map["morality"]])
			artist.sports = int(line[header_map["sports"]])
			artist.rebellion = int(line[header_map["rebellion"]])
			artist.sexy = int(line[header_map["sexy"]])
			artist.confidence = int(line[header_map["confidence"]])
			
			artist.stamina = int(line[header_map["stamina"]])
			artist.stress = int(line[header_map["stress"]])
			artist.fame = int(line[header_map["fame"]])
			
			dynamic_data.add_artist(artist)
	
	print("Initialized ", dynamic_data.artists.size(), " artists matching orientation ", orientation)

# Dynamic Data Helpers
func get_variable(key: String):
	if dynamic_data and dynamic_data.variables.has(key):
		return dynamic_data.variables[key]
	return 0 # Default

func set_variable(key: String, value):
	if not dynamic_data: return
	
	# Try to convert to int if number
	if str(value).is_valid_float():
		if str(value).contains("."):
			dynamic_data.variables[key] = float(value)
		else:
			dynamic_data.variables[key] = int(value)
	else:
		dynamic_data.variables[key] = value
	print("Set variable ", key, " to ", value)

func get_save_path(slot_id: int) -> String:
	return "user://savegame_%d.tres" % slot_id

func save_game(slot_id: int = 0):
	if dynamic_data:
		var error = ResourceSaver.save(dynamic_data, get_save_path(slot_id))
		if error == OK:
			print("Game Saved Successfully to slot ", slot_id)
		else:
			printerr("Failed to save game to slot ", slot_id, ": ", error)

func load_game(slot_id: int = 0):
	var path = get_save_path(slot_id)
	if ResourceLoader.exists(path):
		dynamic_data = ResourceLoader.load(path)
		print("Game Loaded Successfully from slot ", slot_id)
	else:
		print("No save file found for slot ", slot_id)

func get_save_info(slot_id: int) -> String:
	var path = get_save_path(slot_id)
	if not ResourceLoader.exists(path):
		return "Empty"
		
	# Try to load just to get the string, or we load the full Resource.
	var test_data = ResourceLoader.load(path)
	if test_data and test_data is DynamicData:
		var date_str = test_data.get_date_string() if test_data.has_method("get_date_string") else "Unknown Date"
		var comp_name = test_data.company_name if "company_name" in test_data else "Unknown"
		var money = test_data.money if "money" in test_data else 0
		return "%s\n%s  |  $%d" % [comp_name, date_str, money]
		
	return "Corrupted Save"

func get_money() -> int:
	if dynamic_data:
		return dynamic_data.money
	return 0

func get_current_date() -> String:
	if dynamic_data:
		return dynamic_data.get_date_string()
	return "0000-00-00"
