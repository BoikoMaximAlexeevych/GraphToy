extends Node2D

var GNODE = preload("res://GNode.tscn")
var drag: bool = false
@onready var mouse_sat = $Mouse_sat
var lines : Array[Line2D]
var current_line: Line2D
var adjacency: Array[Array]
var gnodes: Array
var current_parent : Gnode

func is_gnode(subject) -> bool:
	return subject.scene_file_path == GNODE.resource_path and subject.scene_file_path != null

func _process(delta: float) -> void:
	var mouse = get_global_mouse_position()
	mouse_sat.position = mouse
	
	if Input.is_action_just_pressed("left_click"):
		var a = mouse_sat.get_overlapping_areas().size() > 0
		if a:
			drag = true
			var int_pos = mouse_sat.get_overlapping_areas()[0].global_position
			current_parent = mouse_sat.get_overlapping_areas()[0].owner
			current_line = Line2D.new()
			add_child(current_line)
			current_line.width = 2.
			current_line.default_color = Color(1, 1, 1, 1)
			current_line.add_point(int_pos,0)
			current_line.add_point(mouse - int_pos)
	elif Input.is_action_just_released("left_click"):
		var a = mouse_sat.get_overlapping_areas().size() > 0
		if !a:
			if drag:
				remove_child(current_line)
				current_line.free()
		else:
			if mouse_sat.get_overlapping_areas()[0] == current_parent:
				remove_child(current_line)
				current_line.free()
			else:
				var area = mouse_sat.get_overlapping_areas()[0]
				if([current_parent, area.owner] not in adjacency and [area.owner, current_parent] not in adjacency):
					var gnodea = area.owner
					current_line.set_point_position(1, area.global_position)
					lines.append(current_line)
					print("Lines: ", lines.size())
					if is_gnode(gnodea):
						gnodea.get_meta("connected_nodes").append(current_parent)
						current_parent.get_meta("connected_nodes").append(gnodea)
						adjacency.append([current_parent, gnodea])
				else:
					remove_child(current_line)
					current_line.free()
		drag = false
	elif Input.is_action_just_pressed("right_click"):
		var gnode = GNODE.instantiate()
		gnode.position = mouse
		add_child(gnode)
		gnodes.append(gnode)
	if drag:
		current_line.set_point_position(0, current_parent.global_position)
		current_line.set_point_position(1, mouse)
		current_line.show()
		
	if !adjacency.is_empty():
		var cnt = 0
		for pair in adjacency:
			var node1 = pair[0]
			var node2 = pair[1]
			if lines[cnt]:
				lines[cnt].set_point_position(0, node1.global_position)
				lines[cnt].set_point_position(1, node2.global_position)
			cnt+=1
		
			
