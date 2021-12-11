extends Node2D

var tile_size = 50
var grid = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for c in range(get_child_count()):
		grid.append(get_child(c))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Click is ran on every touch that wasn't dragged
func _on_click(pos):
	print(pos)
	for tile in grid:
		if(pos.x >= tile.global_position.x and pos.x < tile.global_position.x + tile_size and
		pos.y >= tile.global_position.y and pos.y < tile.global_position.y + tile_size):
			tile.modulate.a = 0.2
		


func _on_Camera2D_add_text(text):
	pass # Replace with function body.
