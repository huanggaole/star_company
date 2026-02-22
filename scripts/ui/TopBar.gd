extends PanelContainer

@onready var money_label = $HBoxContainer/MoneyLabel
@onready var date_label = $HBoxContainer/DateLabel

func _ready():
	# Initial refresh
	refresh_ui()
	
	# Connect signals for auto-refresh
	var time_sys = get_node_or_null("/root/TimeSystem")
	if time_sys and time_sys.has_signal("day_changed"):
		if not time_sys.day_changed.is_connected(_on_day_changed):
			time_sys.day_changed.connect(_on_day_changed)
			
	var loc = get_node_or_null("/root/LocalizationManager")
	if loc and loc.has_signal("language_changed"):
		if not loc.language_changed.is_connected(refresh_ui):
			loc.language_changed.connect(refresh_ui)

func _on_day_changed(_date = null):
	refresh_ui()

# User requested a public function that can be actively called to refresh
func refresh_ui():
	if not money_label or not date_label: return
	
	var money = 0
	# Safely get money
	if typeof(DataManager) != TYPE_NIL and DataManager.has_method("get_money"):
		money = DataManager.get_money()
		
	var date_str = "2000-01-01"
	# Safely get date
	if typeof(TimeSystem) != TYPE_NIL and TimeSystem.has_method("get_date_string"):
		date_str = TimeSystem.get_date_string()
	elif typeof(DataManager) != TYPE_NIL and DataManager.has_method("get_current_date"):
		date_str = DataManager.get_current_date()
		
	var loc = get_node_or_null("/root/LocalizationManager")
	var m_text = "Money"
	var d_text = "Date"
	
	if loc:
		if loc.has_method("get_text"):
			m_text = loc.get_text("OFFICE_MONEY")
			if m_text == "OFFICE_MONEY": m_text = "Money" # Fallback if missing
			
			d_text = loc.get_text("OFFICE_DATE")
			if d_text == "OFFICE_DATE": d_text = "Date"
	
	money_label.text = "%s: $%d" % [m_text, money]
	
	var weekday = 0
	if typeof(DataManager) != TYPE_NIL and DataManager.dynamic_data != null and DataManager.dynamic_data.has_method("get_weekday"):
		weekday = DataManager.dynamic_data.get_weekday()
		
	var color = "black"
	if weekday == 5:
		color = "blue"
	elif weekday == 6:
		color = "red"
		
	var weekday_strings = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
	var weekday_str = weekday_strings[weekday]
	
	date_label.text = "[color=%s]%s: %s %s[/color]" % [color, d_text, date_str, weekday_str]
