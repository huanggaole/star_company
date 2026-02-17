extends Control

@onready var artist_list = $Panel/HBoxContainer/ArtistList
@onready var schedule_grid = $Panel/HBoxContainer/ScheduleGrid
@onready var activity_options = $Panel/ActivityOptions

var current_artist_idx = 0
var selected_activity = CompanyManager.ACT_REST

func _ready():
	_populate_artist_list()
	_update_schedule_view()

func _populate_artist_list():
	artist_list.clear()
	var dm = DataManager
	if dm and dm.dynamic_data:
		for artist in dm.dynamic_data.artists:
			artist_list.add_item(artist.name)

func _on_artist_list_item_selected(index):
	current_artist_idx = index
	_update_schedule_view()

func _update_schedule_view():
	# For prototype, we just show the current single activity and allow changing it
	var dm = DataManager
	if not dm or not dm.dynamic_data or dm.dynamic_data.artists.is_empty():
		return
		
	var artist = dm.dynamic_data.artists[current_artist_idx]
	var current_act = "rest"
	if artist.current_activity:
		current_act = artist.current_activity
		
	$Panel/CurrentActivityLabel.text = "Current Schedule: " + CompanyManager.get_activity_name(current_act)

func _on_set_rest_pressed():
	_set_activity(CompanyManager.ACT_REST)

func _on_set_acting_pressed():
	_set_activity(CompanyManager.ACT_TRAIN_ACTING)

func _on_set_singing_pressed():
	_set_activity(CompanyManager.ACT_TRAIN_SINGING)

func _set_activity(act_code):
	var dm = DataManager
	if dm and dm.dynamic_data and not dm.dynamic_data.artists.is_empty():
		dm.dynamic_data.artists[current_artist_idx].current_activity = act_code
		_update_schedule_view()
		print("Set activity for ", dm.dynamic_data.artists[current_artist_idx].name, " to ", act_code)

func _on_close_button_pressed():
	queue_free()
