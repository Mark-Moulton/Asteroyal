extends Node2D

var maxRad: float

#Draws an outer circle that the asteroidSpawner fills in
#This gives the player a sense of when the spawn will complete instead of being an arbitrary growing red circle

func _ready() -> void:
	var pa = get_parent()
	maxRad = pa.maxRad

func _draw() -> void:
	var center: Vector2 = Vector2(0, 0)
	var color: Color = Color(1, 0, 0)
	draw_circle(center, maxRad, color, false)
