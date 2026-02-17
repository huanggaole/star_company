extends Node

# Activity Constants
const ACT_REST = "rest"
const ACT_TRAIN_ACTING = "train_acting"
const ACT_TRAIN_SINGING = "train_singing"
const ACT_TRAIN_DANCE = "train_dance"
const ACT_WORK_LOCAL = "work_local"

func _ready():
	# Connect to TimeSystem to process end of day
	TimeSystem.day_changed.connect(_on_day_changed)

func _on_day_changed(date):
	process_daily_schedule()

func process_daily_schedule():
	var dm = DataManager
	if not dm or not dm.dynamic_data:
		return
		
	for artist_data in dm.dynamic_data.artists:
		# In a real system, we'd load this into an Artist object, process, then save back
		# For now, we manipulate the dictionary directly or duplicate logic
		_process_artist_day(artist_data)

func _process_artist_day(artist: Resource):
	# Default to rest if no schedule
	var current_activity = artist.current_activity
	
	# If we had a schedule system, we'd look up what to do today
	# For prototype, check if artist has property or method for activity
	# artist.schedule logic needed later.
	
	match current_activity:
		ACT_REST:
			artist.stamina = min(artist.stamina + 10, 100)
			artist.stress = max(artist.stress - 5, 0)
		ACT_TRAIN_ACTING:
			artist.acting += 1
			artist.stamina -= 10
			artist.stress += 5
		ACT_TRAIN_SINGING:
			artist.singing += 1
			artist.stamina -= 10
			artist.stress += 5
		ACT_TRAIN_DANCE: # Reusing for sports/performance?
			artist.sports += 1
			artist.stamina -= 10
			artist.stress += 5
			
	# Clamp values
	artist.stamina = clampi(artist.stamina, 0, 100)
	
	print("Processed day for ", artist.name, ": ", current_activity)

func get_activity_name(activity_code: String) -> String:
	match activity_code:
		ACT_REST: return "Rest"
		ACT_TRAIN_ACTING: return "Acting Class"
		ACT_TRAIN_SINGING: return "Vocal Lesson"
		ACT_TRAIN_DANCE: return "Sports Training"
		_: return "Unknown"
