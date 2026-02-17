extends Node
class_name NaninovelParser

# Parses a script file into a list of events
func parse_script(file_path: String) -> Array:
	var events = []
	if not FileAccess.file_exists(file_path):
		printerr("Story file not found: ", file_path)
		return events
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var line_num = 0
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		line_num += 1
		
		if line.is_empty() or line.begins_with(";"):
			continue
			
		# Labels
		if line.begins_with("#"):
			var label_name = line.substr(1).strip_edges()
			events.append({"type": "label", "name": label_name, "line": line_num})
			continue
			
		# Commands
		if line.begins_with("@"):
			var command_data = _parse_command(line)
			events.append(command_data)
			continue
			
		# Dialogue
		if ":" in line:
			var parts = line.split(":", true, 1)
			var speaker = parts[0].strip_edges()
			var text = parts[1].strip_edges()
			events.append({"type": "dialog", "speaker": speaker, "text": text})
		else:
			# Narration
			events.append({"type": "dialog", "speaker": "", "text": line})
			
	return events

func _parse_command(line: String) -> Dictionary:
	# @command param:value param2:value2
	var parts = line.substr(1).split(" ", false) # Remove @ and split by space
	var command_name = parts[0]
	var params = {}
	
	for i in range(1, parts.size()):
		var param_str = parts[i]
		if ":" in param_str:
			var p = param_str.split(":", true, 1)
			params[p[0]] = p[1]
		elif "=" in param_str: # Allow = for set command
			var p = param_str.split("=", true, 1)
			params[p[0]] = p[1]
		else:
			# Flag or unnamed param (treat as "value")
			params["value"] = param_str
			
	return {"type": "command", "command": command_name, "params": params}
