extends Node2D
class_name Gnode

# Components
@export var adjacencyComponent: AdjacencyComponent

@onready var repel_area = $repelArea

#Constants
@export var centerForceCoef: float
@export var repelForceCoef: float
@export var linkForceCoef: float

var velocity: Vector2
var center_force: Vector2
var repel_force: Vector2
var link_force: Vector2
var min_dist: float = 100

func calculate_repel() -> Vector2:
	var near = repel_area.get_overlapping_areas()
	var res: Vector2
	for peer in near:
		var direction: Vector2 = peer.global_position - self.global_position
		res -= direction 
	return res.normalized()

var prevvel: Vector2
func _process(delta: float) -> void:
	prevvel = velocity
	var peers = adjacencyComponent.adjacent_nodes
	if peers.size() > 0:
		for peer in peers:
			link_force = (peer.position - self.position).normalized()
			if((peer.position - self.position).length() <= min_dist):
				link_force *= -1.5

	center_force = (get_viewport_rect().get_center() - self.position).normalized()
	repel_force = calculate_repel() 
	velocity = (link_force * linkForceCoef + repel_force * repelForceCoef + center_force * centerForceCoef) 
	velocity = (prevvel + velocity) / 2
	position += velocity * delta
