extends Node

# Categories
const CATEGORY_MOVIES = "movies"
const CATEGORY_MUSIC = "music"
const CATEGORY_TV = "tv"
const CATEGORY_ADS = "ads"

# Mock Data Generators
var _movie_titles = ["The Galactic Love", "Cyber Detective", "My Neighbor is a ghost", "Star Wars 99", "Romantic Coding"]
var _music_titles = ["Love Algorithm", "Beep Boop", "Neon Lights", "Midnight Drive", "Error 404"]
var _tv_titles = ["Friends in Space", "The Office but on Mars", "Game of Drones", "Breaking Bad Code"]
var _ad_titles = ["Space Cola", "Neo Noodles", "Quantum Shampoo", "Retro Sneakers"]

# Current Rankings (Dictionary of Arrays)
var _current_rankings: Dictionary = {}

func _ready():
	# Initialize with some random data
	generate_initial_rankings()

func generate_initial_rankings():
	_current_rankings[CATEGORY_MOVIES] = _generate_random_list(_movie_titles)
	_current_rankings[CATEGORY_MUSIC] = _generate_random_list(_music_titles)
	_current_rankings[CATEGORY_TV] = _generate_random_list(_tv_titles)
	_current_rankings[CATEGORY_ADS] = _generate_random_list(_ad_titles)

func _generate_random_list(source_titles: Array) -> Array:
	var list = source_titles.duplicate()
	list.shuffle()
	var result = []
	for i in range(list.size()):
		# Each item is a Dictionary with details
		result.append({
			"rank": i + 1,
			"title": list[i],
			"trend": randi_range(-1, 1) # -1: Down, 0: Same, 1: Up
		})
	return result

func get_ranking(category: String) -> Array:
	if _current_rankings.has(category):
		return _current_rankings[category]
	return []

func update_rankings():
	# In the future, this would be more complex logic based on stats
	# For now, just shuffle again to simulate weekly changes
	generate_initial_rankings()
	print("Rankings updated!")
