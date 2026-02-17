extends Control

@onready var background = $Background
@onready var left_char = $Portraits/Left
@onready var center_char = $Portraits/Center
@onready var right_char = $Portraits/Right
@onready var dialogue_box = $DialogueBox
@onready var speaker_label = $DialogueBox/SpeakerLabel
@onready var text_label = $DialogueBox/TextLabel

var current_script: Array = []
var current_index: int = 0
var is_typing: bool = false
var typing_speed: float = 0.05
var history: Array = []
var active_tween: Tween

# Flow control
var label_map: Dictionary = {}

const DIALOGUE_LOG_SCENE = preload("res://scenes/ui/DialogueLog.tscn")

func _ready():
	visible = false

func _add_to_history(speaker: String, text: String):
	history.append({
		"speaker": speaker,
		"text": text
	})

func _on_log_button_pressed():
	var log_ui = DIALOGUE_LOG_SCENE.instantiate()
	add_child(log_ui)
	log_ui.set_history(history)

const NANINOVEL_PARSER = preload("res://scripts/systems/NaninovelParser.gd")

func start_script(file_path: String):
	var parser = NANINOVEL_PARSER.new()
	current_script = parser.parse_script(file_path)
	current_index = 0
	
	# Build label map
	label_map.clear()
	for i in range(current_script.size()):
		var event = current_script[i]
		if event.type == "label":
			label_map[event.name] = i
			
	if current_script.is_empty():
		print("Script empty or not found: ", file_path)
		return
	
	visible = true
	_process_next_event()

func _input(event):
	if not visible:
		return
		
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if is_typing:
			# Skip typing: immediately show full text
			if active_tween and active_tween.is_valid():
				active_tween.kill()
			text_label.visible_ratio = 1.0
			is_typing = false
			# Kill tween if needed, but flag is enough for logic
		else:
			_process_next_event()

func _process_next_event():
	if current_index >= current_script.size():
		_end_script()
		return
		
	var event = current_script[current_index]
	current_index += 1
	
	match event.type:
		"label":
			_process_next_event() # Skip labels
		"dialog":
			_show_dialog(event.speaker, event.text)
		"command":
			_handle_command(event.command, event.params)
			# Commands generally auto-advance unless they are wait commands (not implemented yet)
			# But for now, let's auto-advance commands so we don't get stuck execution
			# NOTE: If _handle_command changes index (goto), we shouldn't recurse blindly if not careful.
			# But basic recursion is fine for now.
			if visible: # Check if script ended inside command
				_process_next_event()

func _show_dialog(speaker: String, text: String):
	# Interpolate variables
	text = _interpolate_text(text)
	
	speaker_label.text = speaker
	speaker_label.add_theme_color_override("font_color", Color.YELLOW)
	
	text_label.text = text
	text_label.visible_ratio = 0.0
	is_typing = true
	
	_add_to_history(speaker, text)
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.tween_property(text_label, "visible_ratio", 1.0, text.length() * typing_speed)
	active_tween.tween_callback(func(): is_typing = false)

func _interpolate_text(text: String) -> String:
	# Replace {Var} with DataManager values
	# Simple regex or string search
	# For prototype: basic string replacement for known vars
	# Actually, proper way is Regex
	var regex = RegEx.new()
	regex.compile("\\{([^}]+)\\}") # Matches {VarName}
	var result = regex.search_all(text)
	
	var new_text = text
	# Iterate backwards to replace without messing indices (or just use replace)
	for r in result:
		var var_key = r.get_string(1)
		var val = DataManager.get_variable(var_key) # Need to implement get_variable in DataManager
		new_text = new_text.replace(r.get_string(), str(val))
		
	return new_text

func _handle_command(command: String, params: Dictionary):
	match command:
		"bg":
			var path = params.get("id", "")
			if not path.is_empty():
				# In real game, use ResourceLoader or a lookup table
				# For prototype, we might assume path is valid or a key
				print("Changing BG to: ", path)
				# background.texture = load(path) # Uncomment if real paths
				background.color = Color.from_hsv(randf(), 0.5, 0.5) # Placeholder
		
		"char":
			var id = params.get("id", "")
			var pos = params.get("pos", "center")
			_update_portrait(id, pos)
			
		"goto":
			var label = params.get("value", "") # Assuming @goto Label
			if label_map.has(label):
				current_index = label_map[label]
			else:
				printerr("Label not found: ", label)

		"set":
			# @set Var=Value is parsed as params: {"Var": "Value"} from our simple parser if using =
			# But our parser splits by space first. 
			# Guide says @set Score=10. Parser: command="set", params={"Score": "10"} if using our = logic
			for key in params:
				DataManager.set_variable(key, params[key])

		"if":
			# @if Score==10
			# This is complex to parse fully with our simple parser.
			# For prototype: Assume param "value" holds condition string (e.g. "Score==10")
			# Or key=value if we use @if Score=10 (for check)
			# Implementation of robust parser is out of scope for this step, generic placeholder:
			pass

func _update_portrait(id: String, pos: String):
	# Hide all first? Or just update specific?
	# Naninovel usually keeps others unless hidden.
	var node = center_char
	match pos:
		"left": node = left_char
		"right": node = right_char
	
	if id == "none":
		node.visible = false
	else:
		node.visible = true
		print("Show char ", id, " at ", pos)

func _end_script():
	visible = false
	print("Script finished.")
	# Signal completion or go back to main menu/office
