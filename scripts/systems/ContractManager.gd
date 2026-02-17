extends Node

# Contract Types
const TYPE_MOVIE = "movie"
const TYPE_AD = "ad"
const TYPE_MUSIC = "music"

# Signals
signal contracts_updated

var available_contracts: Array = []
var active_contracts: Array = []

func _ready():
	# Connect to TimeSystem to refresh contracts weekly or daily
	if TimeSystem.is_node_ready():
		TimeSystem.day_changed.connect(_on_day_changed)
	else:
		TimeSystem.ready.connect(func(): TimeSystem.day_changed.connect(_on_day_changed))
		
	generate_new_contracts()

func _on_day_changed(_date):
	# Simple logic: 20% chance to generate a new contract each day
	if randf() < 0.2:
		generate_new_contracts(1)

func generate_new_contracts(count: int = 3):
	for i in range(count):
		available_contracts.append(_create_random_contract())
	emit_signal("contracts_updated")
	print("Generated ", count, " new contracts.")

func _create_random_contract() -> Dictionary:
	var type = [TYPE_MOVIE, TYPE_AD, TYPE_MUSIC].pick_random()
	var title = "Project " + str(randi() % 1000)
	var payout = randi_range(500, 5000)
	var difficulty = randi_range(1, 5)
	
	match type:
		TYPE_MOVIE: title = "Movie: " + ["Star Wars", "Titanic", "Avatar", "Matrix"].pick_random() + " " + str(randi() % 99)
		TYPE_AD: title = "Ad: " + ["Coke", "Pepsi", "Nike", "Apple"].pick_random()
		TYPE_MUSIC: title = "Song: " + ["Love", "Life", "Beat", "Rhythm"].pick_random()
	
	return {
		"id": randi(),
		"type": type,
		"title": title,
		"payout": payout,
		"difficulty": difficulty,
		"req_stat": ["acting", "singing", "appearance", "speech"].pick_random()
	}

func accept_contract(contract_idx: int):
	if contract_idx < 0 or contract_idx >= available_contracts.size():
		return
		
	var contract = available_contracts[contract_idx]
	active_contracts.append(contract)
	available_contracts.remove_at(contract_idx)
	
	# Immediate payout for prototype (later should be upon completion)
	var dm = DataManager
	if dm and dm.dynamic_data:
		dm.dynamic_data.money += contract["payout"]
		print("Accepted contract: ", contract["title"], ". Paid: $", contract["payout"])
		
	emit_signal("contracts_updated")

func reject_contract(contract_idx: int):
	if contract_idx < 0 or contract_idx >= available_contracts.size():
		return
	available_contracts.remove_at(contract_idx)
	emit_signal("contracts_updated")
