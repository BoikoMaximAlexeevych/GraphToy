extends Node2D

var velocity: Vector2
var center_force: Vector2
var repel_force: Vector2
var link_force: Vector2
var min_dist: float = 100

@onready var repel_area = $repelArea

func _ready() -> void:
	set_meta("connected_nodes", [])
	
func calculate_repel() -> Vector2:
	var near = repel_area.get_overlapping_areas()
	var size = near.size()
	var res: Vector2
	for peer in near:
		var direction: Vector2 = peer.global_position - self.global_position
		var length = direction.length()
		res -= direction / (length / 50 )
	return res
var prevvel: Vector2
func _process(delta: float) -> void:
	prevvel = velocity
	var peers = get_meta("connected_nodes")
	if peers.size() > 0:
		for peer in peers:
			link_force = (peer.position - self.position)
			if((peer.position - self.position).length() <= min_dist):
				link_force *= -1.5
				
	center_force = (get_viewport_rect().get_center() - self.position)
	repel_force = calculate_repel() 
	velocity = (link_force * 0.2 + repel_force * 0.6 + center_force) 
	velocity = (prevvel + velocity) / 2
	position += velocity * delta
