extends Resource

class BlockSaveData:
	var block_position := Vector2i(-1,-1)
	var block_colors : Array[Color] = []
	var score : int = -1
	var score_normalized : float = -1

var blocks : Array[BlockSaveData]

var config = ConfigFile.new()

func load_defaults():
	blocks = []
	var level_dir_path = "res://resources/levels/"
	var dir := DirAccess.open(level_dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var file_path = level_dir_path.path_join(file_name)
				var loaded_resource = load(file_path)
				if loaded_resource is LevelData:
					if loaded_resource.complexity > 0:
						var block := BlockSaveData.new()
						blocks.append(block)
				else:
					push_warning("MainGame: Found non-LevelData resource in levels directory: %s" % file_path)
			

func load_data():
	# Load data from a file.
	var err = config.load("user://save.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		load_defaults()
		return

	# Iterate over all sections.
	for section in config.get_sections():
		# Fetch the data for each section.
		pass

func save_data():
	# Create new ConfigFile object.
	var block_index = 0
	for block in blocks:
		var section_name = "block_%.d" % block_index
		config.set_value(section_name, "score", block.score)
		config.set_value(section_name, "score_normalized", block.score_normalized)
		config.set_value(section_name, "block_position", block.block_position)
		var color_index = 0
		for color in block.block_colors:
			config.set_value(section_name, "block_color_%.d" % color_index, block.block_position)
			color_index
		block_index

	# Save it to a file (overwrite if already exists).
	config.save("user://save.cfg")
