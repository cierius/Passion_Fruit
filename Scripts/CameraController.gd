extends Camera2D

signal click(pos)
signal add_text(text)
signal gen_map()
signal on_move()

# Used to tell if touch is for dragging or touching purposes
var dragging = false 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	


# Input for events handled first
func _input(event):
	# Debug only:
	if Input.is_action_just_released("Quit"):
		print("--- Quitting Game --- \n---\n--- Thanks For Playing ---")
		get_tree().quit()
	if Input.is_action_just_pressed("Zoom-Out"):
		zoom = Vector2(zoom.x+0.1, zoom.y+0.1)
		print(zoom)
	if Input.is_action_just_pressed("Zoom-In"):
		zoom = Vector2(zoom.x-0.1, zoom.y-0.1)
		print(zoom)
	if(Input.is_action_just_pressed("Space")):
		emit_signal("gen_map")
	
	if event is InputEventScreenDrag:
		
		#for i in range(event.get_index()):
		event.set_index(0)
		var t = event.position
		#emit_signal("add_text", "t:" + str(t))
		event.set_index(1)
		var t2 = event.position
		#emit_signal("add_text", "t2:" + str(t2))
		event.set_index(0)
		#print("t: " + str(t) + str(event.get_index()))
		#print("t2: " + str(t2))
		#if(event.get_index() == 0):
		dragging = true
		position.x -= event.relative.x
		position.y -= event.relative.y
		#emit_signal("on_move", Vector2(position))
		#elif(event.get_index() == 1):
			#var touch_start = Vector2(event.position).distance_to(event.get_index[1].position)
			#var touch_delta = Vector2()
			#if()
		
	"""if event is InputEventScreenDrag:
		for i in range(event.get_index()):
			print("hllow")
	"""
		
	if event is InputEventScreenTouch:
		# On touch input
		if event.pressed:
			
			pass
			
		# On release of touch
		if event.pressed == false:
			if(!dragging):
				emit_signal("click", get_global_mouse_position())
			dragging = false
	

func _unhandled_input(event):
	pass



