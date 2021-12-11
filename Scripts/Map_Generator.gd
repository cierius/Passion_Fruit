#tool
extends Node

signal add_text(text)

var world = null
var gen_map = Image.new()
var map_tex = null
onready var noise = OpenSimplexNoise.new()

# Map Size
export var width = 1064 #Default map tile size 1064x1064 in pixels
export var height = 1064

# Noise Seed
export var random_seed = 0.0
export var randomize_seed = false setget ran_seed
var max_noise = -1.0
var min_noise = 1.0

# Noise Variables
export var oct = 3        #Default 3
export var per = 64.0     #Default 64.0
export var pers = 0.5     #Default 0.5
export var lac = 2.0      #Default 2.0
export var apply_settings = false setget set_noise_settings
export var generate_map = false setget _on_gen_map

func _ready():
	if(world == null):
		_print("No World Generated")
		if(find_node("World")):
			world = find_node("World")
		else:
			var new_sprite = Sprite.new()
			new_sprite.name = "World"
			get_parent().add_child(new_sprite.instance())
		
	
	_on_gen_map()

# Overloaded print method for printing to debug console and ingame console
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
	
	for pix_x in range(gen_map.get_size().x):
		for pix_y in range(gen_map.get_size().y):
			if(max_noise < noise.get_noise_2dv(Vector2(pix_x, pix_y))):
				max_noise = noise.get_noise_2dv(Vector2(pix_x, pix_y))
				
			elif(min_noise > noise.get_noise_2dv(Vector2(pix_x, pix_y))):
				min_noise = noise.get_noise_2dv(Vector2(pix_x, pix_y))
	
	_print("Start Colorizing Noise")
	for pix_x in range(gen_map.get_size().x):
		for pix_y in range(gen_map.get_size().y):
			gen_map.set_pixel(pix_x, pix_y, elevation_color(noise.get_noise_2dv(Vector2(pix_x, pix_y))))
	
	_print("Finish Colorizing Noise")
	gen_map.unlock()
	
	_print("World Generation Time: " + str((OS.get_system_time_msecs() - start_time) / 1000.0) + "s")
	
	create_world(gen_map)

func elevation_color(col):
	var color
	col = (col + 1) / 2 # Makes the noise value be between 0 and 1
	
	
	# Hard coded colorization of the noise map
	if(col <= 0.2):
		color = ColorN("navyblue", 1.0)
	elif(col > 0.2 and col <= .4):
		color = ColorN("blue", 1.0)
	elif(col > 0.4 and col <= .6):
		color = ColorN("green", 1.0)
	elif(col > 0.6 and col <= .8):
		color = ColorN("gray", 1.0)
	elif(col > 0.8 and col <= 1.0):
		color = ColorN("white", 1.0)
	
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



func scale_map():
	var tile = [preload("res://Scenes/Tiles/Grass_Tile.tscn"), preload("res://Scenes/Tiles/Water_Tile.tscn")]
	add_child(tile[0].instance())
	









