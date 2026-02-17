extends Control

@onready var background = $Background
@onready var cg_view = $CGView
@onready var mouth_view = $MouthView
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

# Lip Sync Vars
var mouth_frames: Array[Texture2D] = []
var mouth_frame_index: int = 0
var mouth_timer: float = 0.0
var MOUTH_ANIM_INTERVAL: float = 0.15 # Change frame every 0.15s
var mouth_active: bool = false # If true, we should be animating when typing

# Flow control
var label_map: Dictionary = {}

const DIALOGUE_LOG_SCENE = preload("res://scenes/ui/DialogueLog.tscn")

func _ready():
	visible = false
	get_tree().root.size_changed.connect(_update_cg_layout)

func _process(delta):
	if not visible: return
	
	if is_typing and mouth_active and not mouth_frames.is_empty():
		mouth_timer += delta
		if mouth_timer >= MOUTH_ANIM_INTERVAL:
			mouth_timer = 0.0
			mouth_frame_index = (mouth_frame_index + 1)
			# Frames are 0, 1, 2. But we want 1, 2, 3 cycling?
			# User said: 0=hidden, 1=frame1, 2=frame2, 3=frame3.
			# So we have 3 frames loaded. Indices 0, 1, 2 correspond to user's 1, 2, 3.
			# Let's cycle 0->1->2->0...
			if mouth_frame_index >= mouth_frames.size():
				mouth_frame_index = 0
			
			mouth_view.texture = mouth_frames[mouth_frame_index]
			mouth_view.visible = true
	else:
		# Not typing or not active.
		# User said: "When typing ends, hide mouth (default closed/0)".
		# So if not typing, we hide mouth_view? Or show frame 0?
		# User said: "0: not show mouth picture; ... 3 ...; after typing, hide mouth picture".
		# So we hide it.
		mouth_view.visible = false
		mouth_frame_index = 0

func _update_cg_layout():
	if not cg_view.texture: return
	
	var tex_size = cg_view.texture.get_size()
	var screen_size = get_viewport_rect().size
	
	if tex_size.x == 0 or tex_size.y == 0: return
	
	# Logic: Fit the image entirely within the screen (Contain).
	# Ensure the longest edge of the image fits the screen?
	# User: "按照图片最长的边显示完全" (Show longest edge fully).
	# And "上边缘紧贴屏幕" (Top aligned).
	
	var scale_x = screen_size.x / tex_size.x
	var scale_y = screen_size.y / tex_size.y
	
	# Use the SMALLER scale factor to ensure the WHOLE image fits (Contain)
	# This ensures "Longest edge" (or rather, the constraining edge) fits.
	var final_scale = min(scale_x, scale_y)
	
	var final_width = tex_size.x * final_scale
	var final_height = tex_size.y * final_scale
	
	cg_view.size = Vector2(final_width, final_height)
	
	# Align Top-Center
	cg_view.position.x = (screen_size.x - final_width) / 2
	cg_view.position.y = 0

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
				print("Changing BG to: ", path)
				if ResourceLoader.exists(path):
					var tex = load(path)
					cg_view.texture = tex
					_update_cg_layout()
				else:
					printerr("BG Image not found: ", path)
		
		"mouth":
			# @mouth id:base_path x:100 y:200
			# id should be like "res://assets/img/mouth" (without _1.png)
			# or just "mouth" if we assume a path. Let's assume full path base for now or mapped id.
			var base_id = params.get("id", "")
			var px = params.get("x", "0").to_float()
			var py = params.get("y", "0").to_float()
			
			if base_id == "" or base_id == "none":
				mouth_active = false
				mouth_frames.clear()
				mouth_view.visible = false
			else:
				# Load frames
				mouth_frames.clear()
				# Try loading _1, _2, _3
				# Support both .png and .svg or even .jpg
				var ext = ".png" # Default, maybe check file existence?
				# Let's try to detect or just try PNG first.
				# Actually, for prototype we know we copied .svg.
				# In real production, we'd probably require specific ext or check.
				# Let's try .svg if .png fails? Or just hardcode based on known assets?
				# For this task, I'll try .svg first since I created svgs.
				
				# Better approach: check what exists.
				var suffix_list = ["_1", "_2", "_3"]
				var loaded_count = 0
				
				# Extensions to try
				var extensions = [".svg", ".png", ".jpg"]
				
				for i in range(1, 4):
					var found = false
					for e in extensions:
						var p = base_id + "_" + str(i) + e
						if ResourceLoader.exists(p):
							mouth_frames.append(load(p))
							found = true
							print("Loaded mouth frame: ", p)
							break
					if not found:
						printerr("Missing mouth frame: ", base_id + "_" + str(i))
				
				if not mouth_frames.is_empty():
					mouth_active = true
					mouth_view.position = Vector2(px, py)
					# Adjust size? For now assume original size or set based on some scale?
					# TextureRect expands if expand_mode is on. We set it to KEEP_SIZE or similar?
					# In Tscn we set expand_mode=1 (IGNORE_SIZE) but stretch_mode=5 (KEEP_ASPECT_CENTERED).
					# If we want exact pixel size, we might want to set size to texture size.
					var s = mouth_frames[0].get_size()
					mouth_view.size = s
					# wait, if expand_mode is 1, size determines display. If we don't set size, it might be 0?
					# We set 40x40 in TSCN. We should update size to match texture.
					mouth_view.size = s
					
					print("Mouth active at ", px, ",", py)
				else:
					mouth_active = false

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

			pass

		"style":
			# @style mode:center or mode:dialog
			var mode = params.get("mode", "dialog")
			if mode == "center":
				# Hide background (Panel) but keep text visible
				dialogue_box.self_modulate = Color(1, 1, 1, 0)
				speaker_label.visible = false
				# Ideally for "center" we might want to center the text vertically in the screen
				# But for "subtitle" (bottom), keeping it in the bottom box is correct.
				# The user requested both (Part 1 center, Part 2 bottom).
				# For now, we leave it at bottom (Subtitle style) to avoid layout complexity.
			elif mode == "dialog":
				# Show background
				dialogue_box.self_modulate = Color(1, 1, 1, 1)
				speaker_label.visible = true

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
	emit_signal("script_completed")

signal script_completed
