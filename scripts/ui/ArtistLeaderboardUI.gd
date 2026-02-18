extends Control

const ARTIST_CONFIG_PATH = "res://data/artist_config.csv"

@onready var scroll_container = $Panel/ScrollContainer
@onready var list_container = $Panel/ScrollContainer/VBoxContainer

func _ready():
	_populate_list()

func _load_all_artists_from_csv() -> Array:
	var all_artists = []
	if not FileAccess.file_exists(ARTIST_CONFIG_PATH):
		printerr("ArtistLeaderboardUI: CSV not found: ", ARTIST_CONFIG_PATH)
		return all_artists
	
	var file = FileAccess.open(ARTIST_CONFIG_PATH, FileAccess.READ)
	var header = file.get_csv_line()
	var header_map = {}
	for i in range(header.size()):
		header_map[header[i]] = i
	
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < header.size():
			continue
		all_artists.append({
			"name": line[header_map["name"]],
			"gender": int(line[header_map["gender"]]),
			"age": int(line[header_map["age"]]),
			"fame": int(line[header_map["fame"]])
		})
	return all_artists

func _populate_list():
	# Clear previous children
	for child in list_container.get_children():
		child.queue_free()
	
	# Read ALL artists from CSV (not filtered by orientation)
	var artists = _load_all_artists_from_csv()
	artists.sort_custom(func(a, b): return a.fame > b.fame)
	
	# Create header row
	var header = _create_row("排名", "", "姓名", "性别", "年龄", "名气", true)
	list_container.add_child(header)
	
	# Add separator
	var sep = HSeparator.new()
	list_container.add_child(sep)
	
	# Create artist rows
	for i in range(artists.size()):
		var artist = artists[i]
		var gender_str = "♀" if artist.gender == 0 else "♂"
		var row = _create_row(
			str(i + 1),
			"", # avatar placeholder
			artist.name,
			gender_str,
			str(artist.age),
			str(artist.fame),
			false
		)
		list_container.add_child(row)

func _create_row(rank_text: String, _avatar_path: String, name_text: String, gender_text: String, age_text: String, fame_text: String, is_header: bool) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	
	# Rank
	var rank_lbl = Label.new()
	rank_lbl.text = rank_text
	rank_lbl.custom_minimum_size.x = 50
	rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if is_header:
		rank_lbl.add_theme_font_size_override("font_size", 14)
	row.add_child(rank_lbl)
	
	# Avatar placeholder (48x48 gray box for non-header, skip for header)
	if not is_header:
		var avatar_container = PanelContainer.new()
		avatar_container.custom_minimum_size = Vector2(48, 48)
		var avatar_style = StyleBoxFlat.new()
		avatar_style.bg_color = Color(0.3, 0.3, 0.3, 0.6)
		avatar_style.corner_radius_top_left = 4
		avatar_style.corner_radius_top_right = 4
		avatar_style.corner_radius_bottom_left = 4
		avatar_style.corner_radius_bottom_right = 4
		avatar_container.add_theme_stylebox_override("panel", avatar_style)
		
		# Inner TextureRect for future avatar image
		var avatar_tex = TextureRect.new()
		avatar_tex.name = "AvatarTexture"
		avatar_tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		avatar_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		avatar_container.add_child(avatar_tex)
		
		row.add_child(avatar_container)
	else:
		# Spacer for header alignment
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(48, 0)
		row.add_child(spacer)
	
	# Name
	var name_lbl = Label.new()
	name_lbl.text = name_text
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if is_header:
		name_lbl.add_theme_font_size_override("font_size", 14)
	row.add_child(name_lbl)
	
	# Gender
	var gender_lbl = Label.new()
	gender_lbl.text = gender_text
	gender_lbl.custom_minimum_size.x = 40
	gender_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gender_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if not is_header:
		if gender_text == "♀":
			gender_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.6))
		else:
			gender_lbl.add_theme_color_override("font_color", Color(0.4, 0.6, 1.0))
	if is_header:
		gender_lbl.add_theme_font_size_override("font_size", 14)
	row.add_child(gender_lbl)
	
	# Age
	var age_lbl = Label.new()
	age_lbl.text = age_text
	age_lbl.custom_minimum_size.x = 50
	age_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	age_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if is_header:
		age_lbl.add_theme_font_size_override("font_size", 14)
	row.add_child(age_lbl)
	
	# Fame
	var fame_lbl = Label.new()
	fame_lbl.text = fame_text
	fame_lbl.custom_minimum_size.x = 80
	fame_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fame_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if is_header:
		fame_lbl.add_theme_font_size_override("font_size", 14)
	else:
		fame_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	row.add_child(fame_lbl)
	
	return row

func _on_close_button_pressed():
	queue_free()
