extends Node
class_name StaticData

var _data: Dictionary = {}

func load_data(file_path: String) -> void:
    if not FileAccess.file_exists(file_path):
        printerr("Static data file not found: ", file_path)
        return
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    var content = file.get_as_text()
    var json = JSON.new()
    var error = json.parse(content)
    
    if error == OK:
        _data = json.data as Dictionary
        print("Static data loaded successfully.")
    else:
        printerr("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())

func get_item(item_id: String) -> Dictionary:
    if _data.has("items") and _data["items"].has(item_id):
        return _data["items"][item_id]
    return {}

func get_event(event_id: String) -> Dictionary:
    if _data.has("events") and _data["events"].has(event_id):
        return _data["events"][event_id]
    return {}

func get_all_awards() -> Dictionary:
    if _data.has("awards"):
        return _data["awards"]
    return {}
