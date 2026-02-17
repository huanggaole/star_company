extends Node

signal awards_started
signal award_winner_revealed(category, winner_name)
signal awards_ended

const CAT_BEST_ACTOR = "Best Actor"
const CAT_BEST_SINGER = "Best Singer"
const CAT_BEST_MOVIE = "Best Movie"
const CAT_BEST_SONG = "Best Song"

var _is_ceremony_active = false
var _current_year = 0

func start_ceremony(year: int):
	_current_year = year
	_is_ceremony_active = true
	emit_signal("awards_started")
	print("--- STAR AWARDS ", year, " STARTED ---")
	
	# In a real game, this would be a sequence. For prototype, we'll delay or trigger one by one.
	# We will assume the UI drives the flow by calling "reveal_next_category"
	
func get_winner(category: String) -> String:
	# Detailed logic to pick winners
	match category:
		CAT_BEST_MOVIE:
			var movies = RankingManager.get_ranking(RankingManager.CATEGORY_MOVIES)
			if movies.is_empty(): return "No Nominations"
			return movies[0]["title"] # Top ranked movie
			
		CAT_BEST_SONG:
			var music = RankingManager.get_ranking(RankingManager.CATEGORY_MUSIC)
			if music.is_empty(): return "No Nominations"
			return music[0]["title"] # Top ranked song
			
		CAT_BEST_ACTOR:
			# Mocking an actor win based on our artists
			var top_artist = _get_top_artist("acting")
			return top_artist.name if top_artist else "Unknown Actor"
			
		CAT_BEST_SINGER:
			var top_artist = _get_top_artist("singing")
			return top_artist.name if top_artist else "Unknown Singer"
			
	return "Unknown"

func _get_top_artist(stat: String) -> Resource:
	var dm = DataManager
	if not dm or not dm.dynamic_data or dm.dynamic_data.artists.is_empty():
		return null
	
	var best_artist = null
	var max_val = -1
	
	for artist in dm.dynamic_data.artists:
		var val = artist.get(stat)
		if val == null: val = 0 # Handle missing property safely
		
		if val > max_val:
			max_val = val
			best_artist = artist
			
	return best_artist

func end_ceremony():
	_is_ceremony_active = false
	print("--- STAR AWARDS ENDED ---")
	emit_signal("awards_ended")
