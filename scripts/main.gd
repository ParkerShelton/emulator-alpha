extends Node2D

var emulators = []
var games = []

var selected_emulator = ""
var selected_game = ""

func _ready():
	display_emulators()

func display_games():
	get_games_by_console(selected_emulator)
	%emulator_selection.visible = false
	%game_selection.visible = true
	
	for i in range(games.size()):
		var texture_button = TextureButton.new()
		
		var texture = get_texture(games[i])
		texture_button.texture_normal = texture
		texture_button.stretch_mode = TextureButton.STRETCH_SCALE
		texture_button.ignore_texture_size = true
		texture_button.custom_minimum_size = Vector2(150, 100)
		texture_button.pressed.connect(func(): select_game(games[i]))
		
		%game_list.add_child(texture_button)

func display_emulators():
	get_emulators()
	%emulator_selection.visible = true
	%game_selection.visible = false
	
	for i in range(emulators.size()):
		var texture_button = TextureButton.new()
		
		var texture = load("res://logos/%s.png" % emulators[i])
		texture_button.texture_normal = texture
		texture_button.stretch_mode = TextureButton.STRETCH_SCALE
		texture_button.ignore_texture_size = true
		texture_button.custom_minimum_size = Vector2(150, 100)
		texture_button.pressed.connect(func(): select_emulator(emulators[i]))
		
		%emulator_list.add_child(texture_button)

func get_texture(game: String):
	match selected_emulator:
		"ps3":
			var path = "D:/Godot/emulator-alpha/games/ps3/%s/PS3_GAME/ICON0.PNG" % game
			print("Attempting to load: ", path)
			
			# Check if file exists first
			if not FileAccess.file_exists(path):
				print("File not found: ", path)
				return null
			
			# Load image using static method
			var image = Image.load_from_file(path)
			
			# Check if image is valid
			if image == null:
				print("Image.load_from_file returned null for: ", path)
				return null
			
			if image.is_empty():
				print("Image is empty for: ", path)
				return null
			
			print("Image loaded successfully. Size: ", image.get_width(), "x", image.get_height())
			
			# Create texture from image
			var texture = ImageTexture.create_from_image(image)
			return texture
		"gamecube":
			return get_cover_art(game)

func get_emulators():
	var dir = DirAccess.open("D:/Godot/emulator-alpha/emulators/")
	if not dir:
		print("  Error: Could not open directory")
		return
		
	dir.list_dir_begin()
	var emulator = dir.get_next()
	
	while emulator != "":
		if dir.current_is_dir() and emulator != "." and emulator != "..":
			emulators.append(emulator)
		emulator = dir.get_next()
	dir.list_dir_end()

func get_games_by_console(console: String):
	var dir = DirAccess.open("D:/Godot/emulator-alpha/games/" + console)
	if not dir:
		print("  Error: Could not open directory")
		return
		
	dir.list_dir_begin()
	var game = dir.get_next()
	
	while game != "":
		if dir.current_is_dir() and game != "." and game != "..":
			games.append(game)
		game = dir.get_next()
	dir.list_dir_end()


func get_cover_art(game: String) -> Texture2D:
	var base_path = "res://cover_art/%s/%s" % [selected_emulator, game]
	var extensions = [".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tga"]
	
	for ext in extensions:
		var full_path = base_path + ext
		if FileAccess.file_exists(full_path):
			return load(full_path) as Texture2D
	
	print("Cover art not found for: %s/%s" % [selected_emulator, game])
	return null



func select_emulator(name: String):
	selected_emulator = name
	display_games()
	
func select_game(game: String):
	selected_game = game
	
	var path = "D:/Godot/emulator-alpha/games/%s/%s/%s" % [selected_emulator, selected_game, selected_game]
	var extensions = [".iso", ".ciso", ".gcz", ".wbfs"]
	var game_path = ""
	
# Find the first existing file
	for ext in extensions:
		var full_path = path + ext
		if FileAccess.file_exists(full_path):
			game_path = full_path
			break  # Stop looking once we find one

	# Only launch if we found a game
	if game_path != "":
		var dolphin_exe = "D:/Godot/emulator-alpha/emulators/gamecube/Dolphin.exe"
		OS.create_process(dolphin_exe, ["--exec=" + game_path])
		print("Launching: " + game_path)
	else:
		print("ERROR: Game not found for " + selected_game)

func _on_button_pressed():	
	var path =  "D:/Godot/emulator-alpha/emulators/ps3/rpcs3.exe"
	var game = "D:/Godot/emulator-alpha/games/ps3/BioShock/PS3_GAME/USRDIR/EBOOT.BIN"
	
	if not FileAccess.file_exists(path) or not FileAccess.file_exists(game):
		print("  ERROR: File no exist: ", path)
		return
	
	var args = [game]
	OS.execute(path, args)
