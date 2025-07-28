extends Node2D

var GNODE = preload("res://GNode.tscn")

var drag: bool = false
@onready var mouse_sat = $Mouse_sat

var lines : Array[Line2D]
var current_line: Line2D
var adjacency: Array[Array]
var gnodes: Array

var current_parent

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
			current_parent = mouse_sat.get_overlapping_areas()[0]
			var line = Line2D.new()
			add_child(line)
			line.width = 2.
			line.default_color = Color(1, 1, 1, 1)
			line.add_point(int_pos,0)
			line.add_point(mouse - int_pos)
			lines.append(line)
			print("Lines: ", lines.size())
	elif Input.is_action_just_released("left_click"):
		var a = mouse_sat.get_overlapping_areas().size() > 0
		if !a:
			if drag:
				remove_child(lines[lines.size() - 1])
				lines[lines.size() -1].free()
				lines.pop_at(lines.size() - 1)
		else:
			if mouse_sat.get_overlapping_areas()[0] == current_parent:
				remove_child(lines[lines.size() -1])
				lines[lines.size() - 1].free()
				lines.pop_at(lines.size() - 1)
			else:
				var area = mouse_sat.get_overlapping_areas()[0]
				if([current_parent.owner, area.owner] not in adjacency and [area.owner, current_parent.owner] not in adjacency):
					var gnodea = area.owner
					lines[lines.size() - 1].set_point_position(1, area.global_position)
					if is_gnode(gnodea):
						gnodea.get_meta("connected_nodes").append(current_parent.owner)
						current_parent.owner.get_meta("connected_nodes").append(gnodea)
						adjacency.append([current_parent.owner, gnodea])
				else:
					remove_child(lines[lines.size() - 1])
					lines[lines.size() -1].free()
					lines.pop_at(lines.size() - 1)
		drag = false
	elif Input.is_action_just_pressed("right_click"):
		var gnode = GNODE.instantiate()
		gnode.position = mouse
		add_child(gnode)
		gnodes.append(gnode)
	if drag:
		lines[lines.size() -1].set_point_position(0, current_parent.global_position)
		lines[lines.size() -1].set_point_position(1, mouse)
		lines[lines.size() - 1].show()
		
	if !adjacency.is_empty():
		var cnt = 0
		for pair in adjacency:
			var node1 = pair[0]
			var node2 = pair[1]
			if lines[cnt]:
				lines[cnt].set_point_position(0, node1.global_position)
				lines[cnt].set_point_position(1, node2.global_position)
			cnt+=1
