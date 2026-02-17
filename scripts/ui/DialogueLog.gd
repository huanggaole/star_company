extends Control

@onready var container = $Panel/ScrollContainer/VBoxContainer

func set_history(history: Array):
	# Clear existing
	for child in container.get_children():
		child.queue_free()
		
	# Populate
	for item in history:
		var speaker = item.get("speaker", "")
		var text = item.get("text", "")
		
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.text = "[color=yellow]%s[/color]: %s" % [speaker, text]
		label.fit_content = true
		label.custom_minimum_size.y = 20 # Minimum height
		container.add_child(label)

func _on_close_button_pressed():
	queue_free()
