extends Node

signal language_changed

const LANG_EN = "en"
const LANG_ZH = "zh"

var current_lang = LANG_EN
var translations = {}

func _ready():
	_load_translations()
	# Default to English or load from config (todo)
	
func _load_translations():
	var file = FileAccess.open("res://data/translations.csv", FileAccess.READ)
	if not file:
		printerr("Translations file not found!")
		return
		
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < 3: continue
		
		# key, en, zh
		var key = line[0]
		translations[key] = {
			LANG_EN: line[1], # Hardcoded index based on CSV structure
			LANG_ZH: line[2]
		}

func set_language(lang: String):
	if lang != LANG_EN and lang != LANG_ZH:
		printerr("Invalid language: ", lang)
		return
		
	current_lang = lang
	emit_signal("language_changed")
	print("Language switched to: ", lang)

func get_text(key: String) -> String:
	if translations.has(key):
		var dict = translations[key]
		if dict.has(current_lang):
			return dict[current_lang]
	return key # Fallback to key if not found
