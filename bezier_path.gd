
extends Node2D

var A = Vector2(10, 10)
var B = Vector2(100, 100)

var aControl = Vector2(50, 10)
var bControl = Vector2(50, 100)

var aCol = Color(1, 0, 0.5)
var bCol = Color(0, 0.5, 1)

var selectionDist = 10
var pressed = false
var selection = "None"
var offset = Vector2()



func _ready():
	set_process(true)
	set_process_input(true)
	
	
func _process(delta):
	update()
	
	
func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		if pressed:
			if selection == "A":
				A = event.pos
				aControl = A + offset
			elif selection == "B":
				B = event.pos
				bControl = B + offset
			elif selection == "aControl":
				aControl = event.pos
			elif selection == "bControl":
				bControl = event.pos
		else:
			if event.pos.distance_to(A) < selectionDist:
				selection = "A"
			elif event.pos.distance_to(aControl) < selectionDist:
				selection = "aControl"
			elif event.pos.distance_to(B) < selectionDist:
				selection = "B"
			elif event.pos.distance_to(bControl) < selectionDist:
				selection = "bControl"
			else:
				selection = "None"
			
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.pressed:
			pressed = true
			if event.pos.distance_to(A) < selectionDist:
				selection = "A"
				offset = aControl - A
			elif event.pos.distance_to(aControl) < selectionDist:
				selection = "aControl"
			elif event.pos.distance_to(B) < selectionDist:
				selection = "B"
				offset = bControl - B
			elif event.pos.distance_to(bControl) < selectionDist:
				selection = "bControl"
			else:
				selection = "None"
		else:
			pressed = false
			selection = "None"
			
	
	
func _draw():
	draw_bezier(A, aControl, B, bControl)
	
	if selection != "None":
		if selection == "A":
			draw_circle(A, 10, Color(1, 1, 1, 0.1))
		elif selection == "B":
			draw_circle(B, 10, Color(1, 1, 1, 0.1))
		elif selection == "aControl":
			draw_circle(aControl, 10, Color(1, 1, 1, 0.1))
		elif selection == "bControl":
			draw_circle(bControl, 10, Color(1, 1, 1, 0.1))
	
	
func draw_bezier(a_pos, a_cont, b_pos, b_cont):
	
	var steps = 30 #Curvature of the path
	var points = []
	
	
	for step in range(steps+1):
			var a = float(step)/steps
			var b = 1 - float(step)/steps
	
			var point = a_pos*pow(b,3) + 3*a_cont*pow(b,2)*a + 3*b_cont*b*pow(a,2) + b_pos*pow(a,3)  
			
			points.push_back(point)
			
	
	#Draw path
	for p in range(points.size()-1):
		draw_line(points[p], points[p+1], Color(1, 1, 1))
	
	
	
	#Draw start and end points
	draw_circle(a_pos, 3, aCol)
	draw_circle(b_pos, 3, bCol)
	
	
	
	#Draw control points
	draw_circle(a_cont, 3, aCol)
	draw_circle(b_cont, 3, bCol)
	
	draw_line(a_pos, a_cont, Color(aCol.r, aCol.g, aCol.b, 0.5), 1)
	draw_line(b_pos, b_cont, Color(bCol.r, bCol.g, bCol.b, 0.5), 1)
	
	

