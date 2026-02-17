extends Control

@onready var gender_choice = $Panel/VBoxContainer/GenderHBox/GenderOption
@onready var orientation_choice = $Panel/VBoxContainer/OrientationHBox/OrientationOption
@onready var start_button = $Panel/VBoxContainer/StartButton

func _ready():
	_update_text()
	
	start_button.pressed.connect(_on_start_pressed)
	
	# Listen for language changes
	var loc = get_node("/root/LocalizationManager")
	if loc:
		loc.language_changed.connect(_update_text)

func _update_text():
	var loc = get_node("/root/LocalizationManager")
	if not loc: return
	
	$Panel/Label.text = loc.get_text("CHAR_CREATION_TITLE")
	$Panel/VBoxContainer/GenderHBox/Label.text = loc.get_text("CHAR_GENDER_LABEL")
	$Panel/VBoxContainer/OrientationHBox/Label.text = loc.get_text("CHAR_ORIENTATION_LABEL")
	start_button.text = loc.get_text("CHAR_START_BUTTON")
	
	# Update Gender Options (Preserve selection if needed, but for simplicity just rebuild or set text)
	# Since ID mapping matters, let's just update text by index if we know the order is fixed.
	# Or safer: clear and re-add.
	
	var current_gender_idx = gender_choice.selected
	gender_choice.clear()
	gender_choice.add_item(loc.get_text("GENDER_MALE"), 1)
	gender_choice.add_item(loc.get_text("GENDER_FEMALE"), 0)
	gender_choice.add_item(loc.get_text("GENDER_OTHER"), 2)
	
	if current_gender_idx != -1:
		gender_choice.select(current_gender_idx)
	else:
		gender_choice.select(0) # Default Male
		
	var current_orient_idx = orientation_choice.selected
	orientation_choice.clear()
	orientation_choice.add_item(loc.get_text("ORIENT_LIKE_FEMALE"), 0)
	orientation_choice.add_item(loc.get_text("ORIENT_LIKE_MALE"), 1)
	orientation_choice.add_item(loc.get_text("ORIENT_BISEXUAL"), 2)
	
	if current_orient_idx != -1:
		orientation_choice.select(current_orient_idx)
	else:
		orientation_choice.select(0) # Default Likes Female

func _on_start_pressed():
	var gender = gender_choice.get_selected_id()
	var orientation = orientation_choice.get_selected_id()
	
	print("Starting game with Gender: ", gender, ", Orientation: ", orientation)
	DataManager.start_new_game(gender, orientation)
	
	# Transition to Office
	get_tree().change_scene_to_file("res://scenes/world/Office.tscn")
