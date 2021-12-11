extends TextEdit

var console = []
var line_count = 0

func _on_text_add(t):
	if(visible == true):
		text = ""
		console.push_front(str(t))
		line_count = 0
		
		var timestamp = "[" + str(OS.get_time().hour) + ":" + str(OS.get_time().minute) +":" + str(OS.get_time().second) + "]" + ": "
		
		for lines in console:
			if(len(console) >= 20):
				console.pop_back()
			text += timestamp + console[line_count] + "\n"
			line_count += 1


#func _on_move(coord=Vector2(-800,-450)):
	#rect_position = coord + Vector2(-800, -450)
	#Vector2.clamp()


func _on_console_button():
	if(visible):
		visible = false
		get_parent().get_node("Console_Button").rect_position = Vector2(-800, -450)
	else:
		get_parent().get_node("Console_Button").rect_position = Vector2(-800,-200)
		visible = true

