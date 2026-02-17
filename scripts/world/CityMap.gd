extends Control

# Time cost in minutes (or arbitrary units)
const TRAVEL_COST = 60

func _ready():
	# Update UI with current time/money
	_update_ui()

func _update_ui():
	# Use autoloads to get data
	$TopBar/DateLabel.text = TimeSystem.get_date_string() if TimeSystem.has_method("get_date_string") else DataManager.get_current_date()
	$TopBar/MoneyLabel.text = "Money: $%d" % DataManager.get_money()

func _on_location_pressed(location_name: String):
	print("Traveling to: ", location_name)
	
	# Deduct time
	# We need a method in TimeSystem to advance by specific amount, 
	# or just use advance_day() if travel takes a full 'action'
	# For now, let's assume 1 click = 1 action = advance day part or just log it.
	# Simplification: Travel takes 1 day for now, or just updates state.
	
	match location_name:
		"Office":
			_change_scene("res://scenes/world/Office.tscn")
		"Studio":
			print("Entered Studio")
		"Park":
			print("Entered Park")
		_:
			print("Unknown location")

func _change_scene(path: String):
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		printerr("Scene not found: ", path)

func _on_office_button_pressed():
	_on_location_pressed("Office")

func _on_studio_button_pressed():
	_on_location_pressed("Studio")

func _on_park_button_pressed():
	_on_location_pressed("Park")
