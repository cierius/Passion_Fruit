#tool
extends Node

signal add_text(text)

var world = null
var gen_map = Image.new()
var map_tex = null
onready var noise = OpenSimplexNoise.new()

# Map Size
export var width = 1024 #Default map tile size 1024x1024 in pixels
export var height = 1024
var chunk_size = 64
var grid_image = Image.new()
var grid_tex = ImageTexture.new()
var grid_sprite = Sprite.new()

# Noise Seed
export var random_seed = 0.0
export var randomize_seed = false setget ran_seed
var max_noise = -1.0
var min_noise = 1.0
var range_noise = 2
var proportion = 0
var noise_grid

# Noise Variables
export var oct = 3        #Default 3
export var per = 64.0     #Default 64.0
export var pers = 0.5     #Default 0.5
export var lac = 2.0      #Default 2.0
export var apply_settings = false setget set_noise_settings
export var generate_map = false setget _on_gen_map


func _ready():
	if(world == null):
		_print("World Object is Null")
		if(find_node("World")):
			_print("Found World Object")
			world = find_node("World")
		else:
			_print("Creating New World Object")
			var new_sprite = Sprite.new()
			new_sprite.name = "World"
			get_parent().add_child(new_sprite.instance())
		
	
	_on_gen_map()


# "Overloaded" print method for printing to debug console and ingame console
func _print(t):
	print(str(t))
	emit_signal("add_text", str(t))


func ran_seed(_ran = null):
	random_seed = randi()
	_print(random_seed)


func set_noise_settings(_set = null):
	_print("Applying Noise Setting To The Map")
	noise.seed = int(random_seed)
	noise.octaves = oct
	noise.period = per
	noise.persistence = pers
	noise.lacunarity = lac


func _on_gen_map(_gen = null):
	_print("Generating Map")
	
	var start_time = OS.get_system_time_msecs()
	
	ran_seed()
	set_noise_settings()

	if(gen_map.is_empty() == true):
		gen_map.create(width, height, false, Image.FORMAT_RGB8)
	
	gen_map.lock()
	
	max_noise = -1.0 # Reset max and min noise defaults
	min_noise = 1.0
	
	for pix_x in range(gen_map.get_size().x):
		for pix_y in range(gen_map.get_size().y):
			if(max_noise < noise.get_noise_2dv(Vector2(pix_x, pix_y))):
				max_noise = noise.get_noise_2dv(Vector2(pix_x, pix_y))
				
			elif(min_noise > noise.get_noise_2dv(Vector2(pix_x, pix_y))):
				min_noise = noise.get_noise_2dv(Vector2(pix_x, pix_y))
	
	noise_grid = noise_interpolation()
	
	var counter = 0
	
	_print("Start Colorizing Noise")
	for pix_x in range(gen_map.get_size().x):
		for pix_y in range(gen_map.get_size().y):
			gen_map.set_pixel(pix_x, pix_y, elevation_color(noise_grid[counter]))
			counter += 1
	
	_print("Finish Colorizing Noise")
	gen_map.unlock()
	
	_print("World Generation Time: " + str((OS.get_system_time_msecs() - start_time) / 1000.0) + "s")
	
	create_world(gen_map)
	
	grid_overlay()


func noise_interpolation():
	var grid = []
	
	range_noise = max_noise - min_noise
	proportion = range_noise / 2
	
	max_noise = max_noise / proportion
	min_noise = min_noise / proportion
	range_noise = max_noise - min_noise
	
	for pix_x in range(gen_map.get_size().x):
		for pix_y in range(gen_map.get_size().y):
			grid.push_back(noise.get_noise_2dv(Vector2(pix_x, pix_y)) / proportion)
	
	return grid


func elevation_color(col):
	var color
	var offset = range_noise / 5 # total number of base colors
	
	# Hard coded colorization of the noise map
	if(col >= min_noise and col <= min_noise + offset):
		color = ColorN("navyblue", 1.0)
	elif(col > min_noise + offset and col <= min_noise + offset*1.75):
		color = ColorN("blue", 1.0)
	elif(col > min_noise + offset*1.75 and col <= min_noise + offset*2):
		color = ColorN("blanchedalmond", 1.0)
	elif(col > min_noise + offset*2 and col <= min_noise + offset*2.6):
		color = ColorN("green", 1.0)
	elif(col > min_noise + offset*2.6 and col <= min_noise + offset*3):
		color = ColorN("forestgreen", 1.0)
	elif(col > min_noise + offset*3 and col <= min_noise + offset*3.5):
		color = ColorN("gray", 1.0)
	elif(col > min_noise + offset*3.5 and col <= min_noise + offset*4):
		color = ColorN("darkgray", 1.0)
	elif(col > min_noise + offset*4 and col <= max_noise):
		color = ColorN("snow", 1.0)
	else:
		color = ColorN("Black")
	
	return color 


func create_world(img):
	_print("Creating ImageTexture")
	
	if(map_tex == null):
		map_tex = ImageTexture.new()
		map_tex.create_from_image(img)
	else:
		map_tex.set_data(img)
	
	_print("Applying ImageTexture")
	world.texture = map_tex
	
	_print("Max: " + str(max_noise) + " | Min: " + str(min_noise))


func grid_overlay():
	if(grid_image.is_empty()):
		grid_image.create(width, height, false, 1)
		_print("Creating Grid Image")
	
	grid_image.lock()
	
	_print("Creating Grid")
	for gy in range(width / chunk_size):
		for gx in range(height / chunk_size):
			create_square(gx, gy)
	
	grid_image.unlock()
	
	if(!get_node("Grid_Overlay")):
		_print("Creating New Grid Game Object")
		grid_sprite.name = "Grid_Overlay"
		add_child(grid_sprite)
	
	grid_tex.create_from_image(grid_image)
	
	_print("Applying Grid Texture")
	grid_sprite.texture = grid_tex


func create_square(x_offset, y_offset):
	for y in range(chunk_size):
		for x in range(chunk_size):
			if(y == 0 or y == chunk_size):
				grid_image.set_pixel(x + (x_offset * 64), y + (y_offset * 64), ColorN("black"))
			elif(x == 0 or x == chunk_size):
				grid_image.set_pixel(x + (x_offset * 64), y + (y_offset * 64), ColorN("black"))


func scale_map():
	var tile = [preload("res://Scenes/Tiles/Grass_Tile.tscn"), preload("res://Scenes/Tiles/Water_Tile.tscn")]
	add_child(tile[0].instance())
	









