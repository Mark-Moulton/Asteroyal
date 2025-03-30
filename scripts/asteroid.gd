extends RigidBody2D

var rotSpeed = 150.0
var maxSpeed = 300.0
var speedVector = Vector2(0,0)
var splitNumber = 4
var gameManager: Node
var points = 1
signal playSFX
signal playGiantSFX
@export var Asteroid: PackedScene

func _init() -> void:
	#Sets speeds depending on size
	if self.is_in_group("giant"):
		rotSpeed = rotSpeed / 1.2
		maxSpeed = maxSpeed / 2
		points = 5
		
	#Sets initial speed and rotation within range
	speedVector.x = randf_range(-maxSpeed, maxSpeed)
	speedVector.y = randf_range(-maxSpeed, maxSpeed)
	set_axis_velocity(speedVector)
	apply_torque(randf_range(-rotSpeed, rotSpeed))

func _ready() -> void:
	gameManager = get_parent()
	if !self.is_in_group("giant"):
		$Timer.start()

func take_damage():
	#Emit signal to play appropriate SFX - If giant, split into smalls.
	if self.is_in_group("giant"):
		for i in splitNumber:
			call_deferred("smallSpawn")
		emit_signal("playGiantSFX")
	else:
		emit_signal("playSFX")
	queue_free()

func _process(_delta: float) -> void:
	#Check for screen wrapping
	gameManager.wrap_object(self)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("asteroids") or body.is_in_group("bullet"):
		take_damage()

func smallSpawn() -> void:
		var asteroid = Asteroid.instantiate()
		get_parent().add_child(asteroid)
		asteroid.connect("playSFX",Callable(get_parent(),"_on_asteroid_play_sfx"))
		asteroid.transform = self.global_transform

func _on_timer_timeout():
	#Small asteroids start without group "asteroids" to avoid instantly destroying each other when they spawn.
	#After a very brief timer they are added.
	add_to_group("asteroids")
