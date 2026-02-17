extends Control

@onready var tab_container = $Panel/TabContainer
@onready var list_container = null # Will be set dynamically based on active tab

# Prefab for a ranking row (defined in code or scene, here code for simplicity or a simple scene)
# For now, we'll use a simple HBoxContainer with Labels

func _ready():
	_update_rankings()
	# Connect tab change signal
	tab_container.tab_changed.connect(_on_tab_changed)

func _on_tab_changed(_tab_idx):
	_update_rankings()

func _update_rankings():
	var current_tab = tab_container.get_current_tab_control()
	if not current_tab:
		return
		
	var category = ""
	match current_tab.name:
		"Movies": category = RankingManager.CATEGORY_MOVIES
		"Music": category = RankingManager.CATEGORY_MUSIC
		"TV": category = RankingManager.CATEGORY_TV
		"Ads": category = RankingManager.CATEGORY_ADS
	
	_populate_list(current_tab, category)

func _populate_list(parent_node: Control, category: String):
	# Clear previous children
	for child in parent_node.get_children():
		child.queue_free()
		
	var rankings = RankingManager.get_ranking(category)
	
	# Create header
	var header = HBoxContainer.new()
	var rank_lbl = Label.new()
	rank_lbl.text = "Rank"
	rank_lbl.custom_minimum_size.x = 50
	var title_lbl = Label.new()
	title_lbl.text = "Title"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var trend_lbl = Label.new()
	trend_lbl.text = "Trend"
	
	header.add_child(rank_lbl)
	header.add_child(title_lbl)
	header.add_child(trend_lbl)
	parent_node.add_child(header)
	
	# Create rows
	for item in rankings:
		var row = HBoxContainer.new()
		
		var r = Label.new()
		r.text = str(item["rank"])
		r.custom_minimum_size.x = 50
		
		var t = Label.new()
		t.text = item["title"]
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var tr = Label.new()
		match item["trend"]:
			-1: tr.text = "▼"
			0: tr.text = "-"
			1: tr.text = "▲"
			
		row.add_child(r)
		row.add_child(t)
		row.add_child(tr)
		
		parent_node.add_child(row)

func _on_close_button_pressed():
	queue_free()

func _on_update_button_pressed():
	# Debug button to force update
	RankingManager.update_rankings()
	_update_rankings()
