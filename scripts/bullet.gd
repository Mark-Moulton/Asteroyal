extends Area2D

# Variables
@export var speed = 1000  # Base speed of the bullet
var gameManager: Node
signal scoreUpdate

func _ready() -> void:
	$Timer.start()
	gameManager = get_parent()

func _physics_process(delta):
	position += transform.x * speed * delta
	
func _process(_delta: float) -> void:
	#Check for screen wrapping
	gameManager.wrap_object(self)

func _on_body_entered(body: Node2D) -> void:
	#Only collides with asteroids, gain points based on asteroid size
	if body.is_in_group("asteroids"):
		body.take_damage()
		if body.is_in_group("giant"):
			emit_signal("scoreUpdate", 50)
		else:
			emit_signal("scoreUpdate", 15)
		queue_free()

#Timer for lifespan
func _on_timer_timeout() -> void:
	queue_free()
