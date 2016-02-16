tool

extends Node2D

var curve
var selectedID = null
var pointIn = null # true=pointIn ; false=pointOut

export var bakeInterval = 64
export(Texture) var texture = preload("res://Sprites/ground.png")

export(bool) var showInfo = true


func _ready():
	curve = Curve2D.new()
	
	curve.add_point(Vector2(50, 50), Vector2(-50, 0), Vector2(500, 0))
	curve.add_point(get_viewport_rect().size - Vector2(50, 50), Vector2(-500, 0), Vector2(50, 0))
	
	curve.set_bake_interval(bakeInterval)
	
	update()
	
	set_process_input(true)
	
	
func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.pressed:
			for p in range(curve.get_point_count()):
				if event.pos.distance_to(curve.get_point_pos(p)) < 10:
					selectedID = p
					pointIn = null
					break
				elif event.pos.distance_to(curve.get_point_pos(p) + curve.get_point_in(p)) < 10:
					selectedID = p
					pointIn = true
					break
				elif event.pos.distance_to(curve.get_point_pos(p) + curve.get_point_out(p)) < 10:
					selectedID = p
					pointIn = false
					break
				else:
					selectedID = null
					pointIn = null
		else:
			selectedID = null
			pointIn = null
		update()
		
	if event.type == InputEvent.MOUSE_MOTION:
		if selectedID != null:
			if pointIn == null:
				curve.set_point_pos(selectedID, event.pos)
				update()
			elif pointIn == true:
				curve.set_point_in(selectedID, event.pos - curve.get_point_pos(selectedID))
				update()
			elif pointIn == false:
				curve.set_point_out(selectedID, event.pos - curve.get_point_pos(selectedID))
				update()
	
func _draw():
	#Normals
	var normals = []
	
	for p in range(curve.get_baked_points().size()):
		var n = Vector2()
		
		if p == 0:
			var a = (curve.get_point_pos(0) - curve.get_baked_points()[p]).normalized()
			var b = (curve.get_baked_points()[p+1] - curve.get_baked_points()[p]).normalized()
			
			n = (a+b).normalized()*bakeInterval
			
			#Make normals face up
			if curve.get_baked_points()[p].y + n.y > curve.get_baked_points()[p].y:
				n = -n
				
			normals.push_back(n)
		elif p > 0 && p < curve.get_baked_points().size()-1:
			var a = (curve.get_baked_points()[p-1] - curve.get_baked_points()[p]).normalized()
			var b = (curve.get_baked_points()[p+1] - curve.get_baked_points()[p]).normalized()
			
			n = (a+b).normalized()*bakeInterval
			
			#Make normals face up
			if curve.get_baked_points()[p].y + n.y > curve.get_baked_points()[p].y:
				n = -n
				
			normals.push_back(n)
			
		
		
		
	#Polygon drawing
	var polyArray = []
	var uvArray = []
	
	for p in range(normals.size()-1):
		
		var p0 = curve.get_baked_points()[p] + normals[p]
		var p1 = curve.get_baked_points()[p+1] + normals[p+1]
		var p2 = curve.get_baked_points()[p+1] - normals[p+1]
		var p3 = curve.get_baked_points()[p] - normals[p]
		
		polyArray.push_back([p0, p1, p2, p3])

		
	var colArray = []
	for p in range(4):
		colArray.push_back(Color(1, 1, 1))
		
	uvArray = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	
	
	for p in range(normals.size()-1):
		draw_polygon(polyArray[p], colArray, uvArray, texture)
		
	if showInfo:
		#Draw curve
		#Start with the first point
		if curve.get_baked_points().size() > 0:
			draw_line(curve.get_point_pos(0), curve.get_baked_points()[0], Color(0, 0.5, 1), 1)
		
		#Continue with drawing the whole curve
		for p in range(curve.get_baked_points().size()):
			if p < curve.get_baked_points().size() -1:
				draw_line(curve.get_baked_points()[p], curve.get_baked_points()[p+1], Color(0, 0.5, 1), 1)
		
		
		for n in range(normals.size()):
			draw_line(curve.get_baked_points()[n], curve.get_baked_points()[n] - normals[n], Color(0, 1, 0), 1)
	
	
	
	if selectedID != null:
		if pointIn == true:
			draw_circle(curve.get_point_pos(selectedID) + curve.get_point_in(selectedID), 6, Color(1, 1, 1, 0.25))
		elif pointIn == false:
			draw_circle(curve.get_point_pos(selectedID) + curve.get_point_out(selectedID), 6, Color(1, 1, 1, 0.25))
		else:
			draw_circle(curve.get_point_pos(selectedID), 6, Color(0, 1, 0, 0.25))
		
		
		
	for p in range(curve.get_point_count()):
		var a = curve.get_point_in(p)
		var b = curve.get_point_out(p)
		
		draw_line(curve.get_point_pos(p), curve.get_point_pos(p) + a, Color(1, 0.5, 0))
		draw_line(curve.get_point_pos(p), curve.get_point_pos(p) + b, Color(1, 0, 0.5))
		
		draw_circle(curve.get_point_pos(p) + a, 3, Color(1, 0.5, 0))
		draw_circle(curve.get_point_pos(p) + b, 3, Color(1, 0, 0.5))
		
		draw_circle(curve.get_point_pos(p), 3, Color(0, 0.5, 1))
