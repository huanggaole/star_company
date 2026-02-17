extends Node
class_name StoryParser

func parse_script(file_path: String) -> Array:
	var events = []
	if not FileAccess.file_exists(file_path):
		printerr("Story file not found: ", file_path)
		return events
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.is_empty():
			continue
		
		# Command parsing
		if ":" in line and not " " in line.split(":")[0]: # Simple heuristic for command vs dialog
			var parts = line.split(":", true, 1)
			var key = parts[0].to_lower()
			var value = parts[1].strip_edges()
			
			match key:
				"title", "bg", "left", "center", "right", "music":
					events.append({"type": "command", "command": key, "value": value})
				_:
					# Fallback to dialog if it looks like Name: Text
					events.append({"type": "dialog", "speaker": key, "text": value})
		elif ":" in line:
			var parts = line.split(":", true, 1)
			events.append({"type": "dialog", "speaker": parts[0].strip_edges(), "text": parts[1].strip_edges()})
		else:
			# Narration or unknown
			events.append({"type": "dialog", "speaker": "", "text": line})
			
	return events
