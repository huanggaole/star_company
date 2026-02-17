extends Control

var money_label
var date_label
var bg_view

func _ready():
	print("DEBUG: Office script running on node: ", self.name, " path: ", self.get_path())
	
	if has_node("Background"):
		bg_view = get_node("Background")
		if bg_view:
			# Override stretch mode to allow manual control if needed
			# But first, let's try to update layout manually
			get_tree().root.size_changed.connect(_update_bg_layout)
			_update_bg_layout()
	else:
		printerr("CRITICAL: Background node missing in Office!")

	var children = get_children()
	print("DEBUG: Children count: ", children.size())
	for c in children:
		print("DEBUG: Child: ", c.name)

	# User flattened the structure. Paths are now direct or using special names.
	# "TopBar#MoneyLabel"
	if has_node("TopBar#MoneyLabel"):
		money_label = get_node("TopBar#MoneyLabel")
	elif has_node("TopBar/MoneyLabel"):
		money_label = get_node("TopBar/MoneyLabel")
	
	if has_node("TopBar#DateLabel"):
		date_label = get_node("TopBar#DateLabel")
	elif has_node("TopBar/DateLabel"):
		date_label = get_node("TopBar/DateLabel")
	
	if money_label == null:
		# Fallback search
		money_label = find_child("MoneyLabel", true, false)
		if not money_label: money_label = find_child("TopBar#MoneyLabel", true, false)
		
	if date_label == null:
		date_label = find_child("DateLabel", true, false)
		if not date_label: date_label = find_child("TopBar#DateLabel", true, false)

	if money_label == null or date_label == null:
		printerr("Office: Labels not connected, UI update will fail.")
		return

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

var secretary_menu

func _on_secretary_button_pressed():
	if not secretary_menu:
		secretary_menu = get_node_or_null("SecretaryMenu")
	
	if secretary_menu:
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
func _update_bg_layout():
	if not bg_view or not bg_view.texture: return
	
	var tex_size = bg_view.texture.get_size()
	var screen_size = get_viewport_rect().size
	
	if tex_size.x == 0 or tex_size.y == 0: return
	
	# Logic similar to StoryUI: Fit Inside (Contain) but potentially cover depending on request.
	# User reported "Incomplete display" (gray area).
	# This implies they want the image to COVER the screen, or at least fit consistently.
	# If image is top-aligned and width-fitted, but image is short, bottom is gray.
	# If we want to FILL the screen, we should use 'max' scale (Cover).
	# BUT StoryUI used 'min' scale (Contain) to "Show Longest Edge Fully".
	# If Office background is a room, usually we want Cover.
	# Let's try to make it COVER the width at least.
	
	# Let's stick to the StoryUI logic first (Fit Inside, Align Top) because that was "approved".
	# If that leaves gray space, it means the image aspect ratio doesn't match screen.
	# If user says "Incomplete", maybe they mean "Too small".
	# Let's ensure it FITS WIDTH first.
	
	var scale_factor = screen_size.x / tex_size.x
	
	# If fitting width makes height smaller than screen, we have gray at bottom.
	# If fitting width makes height larger, we crop bottom.
	# Let's start with Fit Width.
	
	var final_width = tex_size.x * scale_factor
	var final_height = tex_size.y * scale_factor
	
	# If fitting width makes it too tall (portrait image?), it will scroll off bottom?
	# "Align Top" handles that.
	
	bg_view.size = Vector2(final_width, final_height)
	bg_view.position.x = (screen_size.x - final_width) / 2
	bg_view.position.y = 0
	
	print("Office BG Updated: ", bg_view.size, " Screen: ", screen_size)
