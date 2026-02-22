extends Node

func _ready():
	# Connect to TimeSystem week_started signal
	var time_sys = get_node_or_null("/root/TimeSystem")
	if time_sys:
		time_sys.week_started.connect(_on_week_started)

func _on_week_started():
	print("WeeklySystem: New week started! Triggering weekly events.")
	
	# 1. Weekly Contracts Refresh
	var contract_mgr = get_node_or_null("/root/ContractManager")
	if contract_mgr and contract_mgr.has_method("generate_new_contracts"):
		print("WeeklySystem: Refreshing contracts...")
		contract_mgr.available_contracts.clear()
		contract_mgr.generate_new_contracts(3) # Generate 3 new contracts per week
	
	# 2. Auto-Save (Slot 0)
	var dm = get_node_or_null("/root/DataManager")
	if dm and dm.has_method("save_game"):
		print("WeeklySystem: Auto-saving game to slot 0...")
		dm.save_game(0)
