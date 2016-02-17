tool

extends Path2D

export(Texture) var texture = preload("res://Sprites/ground.png") setget setBakeInterval
export(bool) var debug = true setget setDebug

var bakeInterval = 64




func _ready():
	get_curve().connect("changed", self, "updateCurve")
	
	
func updateCurve():
	update()
	
func setDebug(val):
	debug = val
	update()
	
	
	
func _draw():
	#Normals
	var normals = []
	
	for p in range(get_curve().get_baked_points().size()):
		var n = Vector2()
		
		if p == 0:
			var a = (get_curve().get_point_pos(0) - get_curve().get_baked_points()[p]).normalized()
			var b = (get_curve().get_baked_points()[p+1] - get_curve().get_baked_points()[p]).normalized()
			
			#Fix normal direction
			if get_curve().get_baked_points()[p].y + n.y > get_curve().get_baked_points()[p].y:
				n = -n
			
			n = (a+b).normalized()*bakeInterval/2
			normals.push_back(n)
			
		elif p > 0 && p < get_curve().get_baked_points().size()-1:
			var a = (get_curve().get_baked_points()[p-1] - get_curve().get_baked_points()[p]).normalized()
			var b = (get_curve().get_baked_points()[p+1] - get_curve().get_baked_points()[p]).normalized()
			
			n = (a+b).normalized()*bakeInterval/2
			
			#Fix normal direction
			if get_curve().get_baked_points()[p].y + n.y > get_curve().get_baked_points()[p].y:
				n = -n
				
			normals.push_back(n)
			
	
	#Polygon drawing
	var polyArray = []
	var uvArray = []
	
	for p in range(normals.size()-1):
		
		var p0 = get_curve().get_baked_points()[p] + normals[p]
		var p1 = get_curve().get_baked_points()[p+1] + normals[p+1]
		var p2 = get_curve().get_baked_points()[p+1] - normals[p+1]
		var p3 = get_curve().get_baked_points()[p] - normals[p]
		
		polyArray.push_back([p0, p1, p2, p3])

		
	var colArray = []
	for p in range(4):
		colArray.push_back(Color(1, 1, 1))
		
	uvArray = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	
	
	for p in range(normals.size()-1):
		draw_polygon(polyArray[p], colArray, uvArray, texture)
	
	#Draws lines only when debug enabled
	if debug:
		#Draw curve
		#Start with the first point
		if get_curve().get_baked_points().size() > 0:
			draw_line(get_curve().get_point_pos(0), get_curve().get_baked_points()[0], Color(0, 0.5, 1), 1)
			
		#Continue with drawing the whole curve
		for p in range(get_curve().get_baked_points().size()):
			if p < get_curve().get_baked_points().size() -1:
				draw_line(get_curve().get_baked_points()[p], get_curve().get_baked_points()[p+1], Color(0, 0.5, 1), 1)
				
		for n in range(normals.size()):
			draw_line(get_curve().get_baked_points()[n], get_curve().get_baked_points()[n] - normals[n], Color(0, 1, 0), 1)
	
	
func setBakeInterval(val):
	texture = val
	bakeInterval = texture.get_width()

