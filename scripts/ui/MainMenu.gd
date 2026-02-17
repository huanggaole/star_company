extends Control

# Paths to scenes
const OFFICE_SCENE_PATH = "res://scenes/world/Office.tscn"
const SETTINGS_UI_SCENE = preload("res://scenes/ui/SettingsUI.tscn")

@onready var new_game_btn = $VBoxContainer/NewGameButton
@onready var load_game_btn = $VBoxContainer/LoadGameButton
@onready var settings_btn = $VBoxContainer/SettingsButton
@onready var debug_btn = $VBoxContainer/DebugButton
@onready var exit_btn = $VBoxContainer/ExitButton

func _ready():
	# Connect buttons
	new_game_btn.pressed.connect(_on_new_game_pressed)
	load_game_btn.pressed.connect(_on_load_game_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	debug_btn.pressed.connect(_on_debug_story_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	
	# Initial translation
	_update_text()
	
	# Listen for language changes
	var loc = get_node("/root/LocalizationManager")
	if loc:
		loc.language_changed.connect(_update_text)

func _update_text():
	var loc = get_node("/root/LocalizationManager")
	if not loc: return
	
	new_game_btn.text = loc.get_text("MAIN_MENU_NEW_GAME")
	load_game_btn.text = loc.get_text("MAIN_MENU_LOAD_GAME")
	settings_btn.text = loc.get_text("MAIN_MENU_SETTINGS")
	exit_btn.text = loc.get_text("MAIN_MENU_EXIT")

func _on_new_game_pressed():
	# Go to character creation
	get_tree().change_scene_to_file("res://scenes/ui/CharacterCreation.tscn")

func _on_settings_pressed():
	var settings_ui = SETTINGS_UI_SCENE.instantiate()
	add_child(settings_ui)

func _on_load_game_pressed():
	DataManager.load_game()
	if ResourceLoader.exists(OFFICE_SCENE_PATH):
		get_tree().change_scene_to_file(OFFICE_SCENE_PATH)
	else:
		print("Would change to Office scene after load.")

func _on_exit_pressed():
	get_tree().quit()

# Debug: Test Naninovel Story
const STORY_UI_SCENE = preload("res://scenes/ui/StoryUI.tscn")
func _on_debug_story_pressed():
	var story_ui = STORY_UI_SCENE.instantiate()
	add_child(story_ui)
	story_ui.start_script("res://data/scripts/naninovel_test.txt")
