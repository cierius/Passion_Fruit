extends Node2D

onready var cam = get_node("/root/GameManager/Camera2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Checks to see if this tile is outside of the cameras view in which case it turns off its sprite
	var dx = Vector2(cam.position.x / cam.zoom.x, 0).distance_to(Vector2(position.x, 0))
	var dy = Vector2(0, cam.position.y / cam.zoom.y).distance_to(Vector2(0, position.y))
	if abs(dx) > 400 or abs(dy) > 350:
		visible = false
	else:
		visible = true
