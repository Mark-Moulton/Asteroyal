extends Node2D

var alpha: float = 0.0  # Start fully transparent
var radius: float = 10
@export var alphaSpeed = 0.2
@export var radSpeed = 10.0
@export var Asteroid: PackedScene
@export var maxRad: float

func _process(delta: float) -> void:
	# Warning circle, becomes larger and less transparent over time
	alpha = min(alpha + delta * alphaSpeed, 1.0)
	radius = min(radius + delta * radSpeed, maxRad)
	queue_redraw()
	
	if radius >= maxRad:
		#Spawns asteroid when circle is filled
		var asteroid = Asteroid.instantiate()
		get_parent().add_child(asteroid)
		asteroid.transform = self.global_transform
		asteroid.connect("playGiantSFX",Callable(get_parent(),"_on_asteroid_giant_play_giant_sfx"))
		queue_free()

func _draw() -> void:
	#Triggers from queue_redraw, drawing with updated size and transparency each _process tick
	var center: Vector2 = Vector2(0, 0)
	var color: Color = Color(1, 0, 0, alpha)
	draw_circle(center, radius, color)
