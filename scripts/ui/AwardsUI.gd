extends Control

@onready var title_label = $Panel/CategoryLabel
@onready var winner_label = $Panel/WinnerLabel
@onready var next_button = $Panel/NextButton

# Local constants to avoid static dependency issues
const CAT_BEST_ACTOR = "Best Actor"
const CAT_BEST_SINGER = "Best Singer"
const CAT_BEST_MOVIE = "Best Movie"
const CAT_BEST_SONG = "Best Song"

var categories = [
	CAT_BEST_MOVIE,
	CAT_BEST_SONG,
	CAT_BEST_ACTOR,
	CAT_BEST_SINGER
]

var current_cat_idx = 0

func _ready():
	_show_category(current_cat_idx)

func _show_category(idx):
	if idx >= categories.size():
		close_ceremony()
		return
		
	var cat = categories[idx]
	title_label.text = "Award: " + cat
	winner_label.text = "And the winner is..."
	next_button.text = "Reveal Winner"
	next_button.disconnect("pressed", _next_step)
	next_button.pressed.connect(_reveal_winner)

func _reveal_winner():
	var cat = categories[current_cat_idx]
	var winner = "Unknown"
	
	var awards_mgr = get_node("/root/AwardsManager")
	if awards_mgr:
		winner = awards_mgr.get_winner(cat)
		
	winner_label.text = winner + "!"
	
	if current_cat_idx < categories.size() - 1:
		next_button.text = "Next Award"
	else:
		next_button.text = "End Ceremony"
		
	if next_button.is_connected("pressed", _reveal_winner):
		next_button.disconnect("pressed", _reveal_winner)
	if not next_button.is_connected("pressed", _next_step):
		next_button.pressed.connect(_next_step)

func _next_step():
	current_cat_idx += 1
	_show_category(current_cat_idx)

func close_ceremony():
	var awards_mgr = get_node("/root/AwardsManager")
	if awards_mgr:
		awards_mgr.end_ceremony()
	queue_free()
