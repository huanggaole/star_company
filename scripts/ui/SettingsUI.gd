extends Control

@onready var title_label = $Panel/TitleLabel
@onready var lang_label = $Panel/HBoxContainer/LangLabel
@onready var close_button = $Panel/CloseButton

func _ready():
	_update_ui()
	var loc = get_node("/root/LocalizationManager")
	if loc:
		loc.language_changed.connect(_update_ui)

func _update_ui():
	var loc = get_node("/root/LocalizationManager")
	if not loc: return
	
	title_label.text = loc.get_text("MAIN_MENU_SETTINGS")
	lang_label.text = loc.get_text("SETTINGS_LANGUAGE")
	close_button.text = loc.get_text("SETTINGS_CLOSE")

func _on_en_pressed():
	var loc = get_node("/root/LocalizationManager")
	if loc:
		loc.set_language(loc.LANG_EN)

func _on_zh_pressed():
	var loc = get_node("/root/LocalizationManager")
	if loc:
		loc.set_language(loc.LANG_ZH)

func _on_close_button_pressed():
	queue_free()
