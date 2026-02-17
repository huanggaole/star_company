extends Control

@onready var money_label = $TopBar/MoneyLabel
@onready var date_label = $TopBar/DateLabel

func _ready():
	_update_ui()
	_update_secretary()
	# Connect TimeSystem signals
	var time_sys = get_node("/root/TimeSystem")
	if time_sys:
		time_sys.day_changed.connect(_on_day_changed)
	
	var awards_mgr = get_node("/root/AwardsManager")
	if awards_mgr:
		awards_mgr.awards_started.connect(_on_awards_started)
		
	var loc = get_node("/root/LocalizationManager")
	if loc:
		loc.language_changed.connect(_update_ui)

func _on_awards_started():
	var awards_ui = AWARDS_UI_SCENE.instantiate()
	add_child(awards_ui)

func _update_ui():
	var loc = get_node("/root/LocalizationManager")
	if not loc: return
	
	# Access DataManager using the autoload name
	money_label.text = loc.get_text("OFFICE_MONEY") + ": $%d" % DataManager.get_money()
	date_label.text = loc.get_text("OFFICE_DATE") + ": %s" % DataManager.get_current_date()
	
	# Update button text
	$Actions/NextDayButton.text = loc.get_text("OFFICE_NEXT_DAY")
	$Actions/GoOutButton.text = loc.get_text("OFFICE_GO_OUT")
	$Actions/RankingsButton.text = loc.get_text("OFFICE_RANKINGS")
	$Actions/ContractsButton.text = loc.get_text("OFFICE_CONTRACTS")
	$Actions/SecretaryButton.text = loc.get_text("OFFICE_SECRETARY")

func _on_day_changed(_date):
	_update_ui()

func _update_secretary():
	# Update Secretary Image based on Player Orientation
	if has_node("SecretaryMenu"):
		var _sec_menu = $SecretaryMenu
		# For now, let's just log it.
		var orientation = DataManager.dynamic_data.player_orientation
		var orient_str = "Female"
		if orientation == 1: orient_str = "Male"
		elif orientation == 2: orient_str = "Any (Bisexual)"
		
		print("Office: Secretary set for orientation: ", orient_str)
		# Todo: Load specific texture

@onready var secretary_menu = $SecretaryMenu

func _on_secretary_button_pressed():
	secretary_menu.visible = not secretary_menu.visible

func _on_artist_list_pressed():
	print("Open Artist List")

const STORY_UI_SCENE = preload("res://scenes/ui/StoryUI.tscn")
const TEST_SCRIPT_PATH = "res://data/scripts/test_script.txt"

const CITY_MAP_SCENE_PATH = "res://scenes/world/CityMap.tscn"
const RANKING_UI_SCENE = preload("res://scenes/ui/RankingUI.tscn")
const SCHEDULE_UI_SCENE = preload("res://scenes/ui/ScheduleUI.tscn")
const CONTRACT_UI_SCENE = preload("res://scenes/ui/ContractUI.tscn")
const AWARDS_UI_SCENE = preload("res://scenes/ui/AwardsUI.tscn")

func _on_schedule_pressed():
	var schedule_ui = SCHEDULE_UI_SCENE.instantiate()
	add_child(schedule_ui)

func _on_contracts_pressed():
	var contract_ui = CONTRACT_UI_SCENE.instantiate()
	add_child(contract_ui)

func _on_rankings_pressed():
	var ranking_ui = RANKING_UI_SCENE.instantiate()
	add_child(ranking_ui)

func _on_go_out_pressed():
	if ResourceLoader.exists(CITY_MAP_SCENE_PATH):
		get_tree().change_scene_to_file(CITY_MAP_SCENE_PATH)
	else:
		printerr("CityMap scene not found")

func _on_next_day_button_pressed():
	TimeSystem.advance_day()

func _play_test_story():
	var story_ui = STORY_UI_SCENE.instantiate()
	add_child(story_ui)
	story_ui.start_script(TEST_SCRIPT_PATH)
