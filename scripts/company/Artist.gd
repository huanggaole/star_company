extends Resource
# class_name Artist # Removed to prevent cyclic dependency crash

@export var name: String = "Unknown"
@export var age: int = 18
@export var gender: int = 0 # 0: Female, 1: Male

# Attributes
@export var acting: int = 0
@export var singing: int = 0
@export var speech: int = 0
@export var appearance: int = 0
@export var smarts: int = 0
@export var morality: int = 0
@export var sports: int = 0
@export var rebellion: int = 0
@export var sexy: int = 0
@export var confidence: int = 0
@export var stamina: int = 100
@export var stress: int = 0
@export var fame: int = 0 # Replaces popularity or maps to it

# Status
@export var schedule: Array = [] # Array of "Activity" IDs for the week/month
@export var current_activity: String = "rest"
@export var location: String = "office" # Current location

func _init(p_name = "New Artist"):
	name = p_name

func get_stat_average() -> int:
	var total = acting + singing + speech + appearance + smarts + morality + sports + rebellion + sexy + confidence
	return total / 10

func train(stat_name: String, value: int):
	match stat_name:
		"acting": acting += value
		"singing": singing += value
		"speech": speech += value
		"appearance": appearance += value
		"smarts": smarts += value
		"morality": morality += value
		"sports": sports += value
		"rebellion": rebellion += value
		"sexy": sexy += value
		"confidence": confidence += value
	stamina -= 10
	stress += 5
