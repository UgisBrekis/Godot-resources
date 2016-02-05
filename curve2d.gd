
extends Node2D

var curve
var selectedID = null
var pointIn = null # true=pointIn ; false=pointOut

func _ready():
	curve = Curve2D.new()
	
	curve.add_point(Vector2(50, 50), Vector2(-50, 0), Vector2(500, 0))
	curve.add_point(get_viewport_rect().size - Vector2(50, 50), Vector2(-500, 0), Vector2(50, 0))
	
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
	for p in range(curve.get_baked_points().size()):
		if p < curve.get_baked_points().size() -1:
			draw_line(curve.get_baked_points()[p], curve.get_baked_points()[p+1], Color(0, 0.5, 1), 1)
			
			
			
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
