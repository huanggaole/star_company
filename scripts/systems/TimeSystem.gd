extends Node


signal day_changed(new_date)
signal month_changed(new_month)
signal year_changed(new_year)

var data_manager: Node # Reference to DataManager

func _ready():
	# In a real scenario, we'd get the DataManager from the scene tree or autoload
	# For now, we assume it's available via a global variable or passed in
	pass

func advance_day():
	var dm = get_node("/root/DataManager")
	if dm and dm.dynamic_data:
		dm.dynamic_data.advance_day()
		var current_date = dm.dynamic_data.current_date
		emit_signal("day_changed", current_date)
		
		if current_date.month == 12 and current_date.day == 31:
			var awards_manager = get_node("/root/AwardsManager")
			if awards_manager:
				awards_manager.start_ceremony(current_date.year)
			
		if current_date.day == 1:
			emit_signal("month_changed", current_date.month)
			if current_date.month == 1:
				emit_signal("year_changed", current_date.year)
