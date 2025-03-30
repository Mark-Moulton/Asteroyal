extends RigidBody2D

@export var rotationSpeed = 10.0
@export var rotDamp = 0.8
@export var thrustPower = 500.0
@export var maxSpeed = 500.0
@export var Bullet : PackedScene
signal playDeathSFX
signal scoringCloseCall(closeCallScore)
signal startCloseCall
var gameManager: Node
var closeCallScore = 0

func _ready() -> void:
	gameManager = get_parent()

func _process(_delta: float) -> void:
	#Check for wrapping
	gameManager.wrap_object(self)
	#closeCallScore increases per tick (resets on starting a close call and sent on ending)
	closeCallScore += 1

#Input handled in physics process
func _physics_process(delta):
	#Boost increases max speed and thrust
	if Input.is_action_just_pressed("boost"):
		thrustPower *= 2
		maxSpeed *= 1.5
	
	#Boost sets animation to full thrust frame
	if Input.is_action_pressed("boost"):
		$AnimatedSprite2D.set_frame_and_progress(2, 0)
	
	#Reverts to normal when not boosting
	if Input.is_action_just_released("boost"):
		thrustPower /= 2
		maxSpeed /= 1.5
		$AnimatedSprite2D.set_frame_and_progress(0, 0)
	
	 # Apply rotation on input
	if Input.is_action_pressed("turn_left"):
		angular_velocity -= rotationSpeed * delta
	elif Input.is_action_pressed("turn_right"):
		angular_velocity += rotationSpeed * delta
	else:
		#Dampen angular velocity when not turning
		angular_velocity *= rotDamp
		
	#Engine animates and SFX only when thrust is applied
	if Input.is_action_just_pressed("thrust"):
		$AnimatedSprite2D.play("default")
		$AudioStreamPlayer.play(0.0)
	if Input.is_action_just_released("thrust"):
		$AnimatedSprite2D.stop()
		$AudioStreamPlayer.stop()

	#Applies thrust
	if Input.is_action_pressed("thrust"):
		var thrustVector = Vector2(thrustPower, 0).rotated(rotation)
		apply_central_force(thrustVector)		
	if Input.is_action_pressed("reverse"):
		var reverseVector = Vector2(-thrustPower, 0).rotated(rotation)
		apply_central_force(reverseVector)
		
	if Input.is_action_just_pressed("shoot"):
		shoot_bullet()
		

#Limits speed
func _integrate_forces(_state):
	if linear_velocity.length() > maxSpeed:
		linear_velocity = linear_velocity.normalized() * maxSpeed

#Spawns bullet and sets up its signals to game manager
func shoot_bullet():
	var bullet = Bullet.instantiate()
	gameManager.add_child(bullet)
	bullet.connect("scoreUpdate", Callable(gameManager, "_on_score_update"))
	bullet.transform = $bulletspawn.global_transform

#When player collides with object, set closeCallScore to 0 so death doesn't trigger score, then die
func _on_body_entered(_body: Node) -> void:
	closeCallScore = 0
	emit_signal("playDeathSFX")
	queue_free()
	

#When close call area2d is entered by an asteroid (ie player is near an asteroid) initialize closeCallScore to 0 (it is always ticking up so must be set to 0 when it is meant to be used)
#and send signal to begin close call danger state
func _on_close_call_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroids"):
		closeCallScore = 0
		emit_signal("startCloseCall")

#When close call area2d is exited by an asteroid (ie player was near an asteroid but creates distance) send signal to end the close call danger state with the score that they've gained
func _on_close_call_body_exited(body: Node2D) -> void:
	if body.is_in_group("asteroids"):
		emit_signal("scoringCloseCall", closeCallScore)
