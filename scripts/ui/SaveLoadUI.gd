extends Control

@export_enum("save", "load") var mode: String = "load"

@onready var title_label = $Panel/TitleLabel
@onready var slot_container = $Panel/ScrollContainer/SlotList

func _ready():
	_init_ui()
	_populate_slots()

func _init_ui():
	var title_text = "Save Game" if mode == "save" else "Load Game"
	
	# Try localization
	var loc = get_node_or_null("/root/LocalizationManager")
	if loc and loc.has_method("get_text"):
		var loc_key = "UI_SAVE_GAME" if mode == "save" else "UI_LOAD_GAME"
		var trans = loc.get_text(loc_key)
		if trans != loc_key: # Key exists
			title_text = trans
			
	title_label.text = title_text

func _populate_slots():
	for child in slot_container.get_children():
		child.queue_free()
		
	var loc = get_node_or_null("/root/LocalizationManager")
	
	for i in range(6):
		var slot_btn = Button.new()
		slot_btn.custom_minimum_size = Vector2(0, 80)
		
		# Build slot title
		var slot_title = "Auto Save" if i == 0 else "Save %d" % i
		if loc and loc.has_method("get_text"):
			if i == 0:
				var t = loc.get_text("UI_AUTO_SAVE")
				if t != "UI_AUTO_SAVE": slot_title = t
			else:
				var t = loc.get_text("UI_SAVE_SLOT")
				if t != "UI_SAVE_SLOT":
					slot_title = t + " " + str(i)
		
		# Get save info
		var info = "Empty"
		if typeof(DataManager) != TYPE_NIL and DataManager.has_method("get_save_info"):
			info = DataManager.get_save_info(i)
			if info == "" or info == "Empty":
				if loc and loc.has_method("get_text"):
					var t = loc.get_text("UI_EMPTY_SLOT")
					if t != "UI_EMPTY_SLOT": info = t
					
		# Rich text layout for the button
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.layout_mode = 1
		label.anchors_preset = Control.PRESET_FULL_RECT
		label.text = "[center][b]%s[/b]\n%s[/center]" % [slot_title, info]
		
		slot_btn.add_child(label)
		
		# Connect press
		slot_btn.pressed.connect(func(): _on_slot_pressed(i))
		
		slot_container.add_child(slot_btn)

func _on_slot_pressed(slot_idx: int):
	if typeof(DataManager) == TYPE_NIL: return
	
	if mode == "save":
		if slot_idx == 0:
			print("Warning: Cannot manually overwrite Auto Save from UI.")
			# Alternatively, allow it or throw a visual warning. For now, let's just ignore manual save to slot 0.
			return
		
		if DataManager.has_method("save_game"):
			DataManager.save_game(slot_idx)
			_populate_slots() # Refresh UI
			
	elif mode == "load":
		# Only load if file exists
		if DataManager.has_method("get_save_info") and DataManager.get_save_info(slot_idx) not in ["Empty", ""]:
			if DataManager.has_method("load_game"):
				DataManager.load_game(slot_idx)
				
				# If we are not in Office, go there.
				var current_scene = get_tree().current_scene.scene_file_path
				if "Office.tscn" not in current_scene:
					get_tree().change_scene_to_file("res://scenes/world/Office.tscn")
				else:
					# If already in office, we need a way to refresh it.
					# For simplicity, reload the scene to re-init everything with loaded data.
					get_tree().reload_current_scene()
				
				queue_free()

func _on_close_pressed():
	queue_free()
