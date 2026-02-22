extends Resource
class_name DynamicData

@export var company_name: String = ""
@export var money: int = 0
@export var current_date: Dictionary = {"year": 2024, "month": 1, "day": 1}

# Player Info
@export var player_gender: int = 1 # 0: Female, 1: Male
@export var player_orientation: int = 0 # 0: Likes Female, 1: Likes Male

# Store dynamic script variables here
@export var variables: Dictionary = {}

@export var artists: Array[Resource] = []
@export var relationships: Dictionary = {}
@export var unlocked_locations: Array[String] = ["office", "bar", "park"]

func _init():
	pass

# Helper to advance day
func advance_day():
	current_date.day += 1
	if current_date.day > 30: # Simplified calendar for now
		current_date.day = 1
		current_date.month += 1
		if current_date.month > 12:
			current_date.month = 1
			current_date.year += 1

func add_artist(artist_data: Resource):
	artists.append(artist_data)

func get_weekday() -> int:
	# Assume 2024-01-01 is Monday (index 0).
	# Custom calendar: 12 months, 30 days per month.
	var total_days = (current_date.year - 2024) * 360 + (current_date.month - 1) * 30 + (current_date.day - 1)
	return total_days % 7

func get_date_string() -> String:
	return "%04d-%02d-%02d" % [current_date.year, current_date.month, current_date.day]
