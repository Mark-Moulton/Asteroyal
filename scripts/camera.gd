extends Camera2D

var isNearAsteroid = false
var normalZoom = Vector2(1, 1)
var closeZoom = Vector2(4, 4) 
var shakeIntensity = 15
var slowMotionScale = 0.1 
var player = null
var defaultPosition = Vector2(0, 0) 
var zoomSpeed = 2
var timeSpeed = 5
var cameraSpeed = 5

func _ready():
	player = get_parent().get_node("PlayerShip")
	defaultPosition = global_position

func _process(delta):
	#When near create danger effect
	if isNearAsteroid:
		# Zoom in and follow the player
		zoom = lerp(zoom, closeZoom, zoomSpeed * delta)
		global_position = lerp(global_position, player.global_position, cameraSpeed * delta)

		# Add screen shake
		offset = Vector2(randi() % shakeIntensity - shakeIntensity / 2, randi() % shakeIntensity - shakeIntensity / 2)

		# Slow motion effect
		Engine.time_scale = lerp(Engine.time_scale, slowMotionScale, timeSpeed * delta)
	
	#Upon exiting near state, return smoothly to default
	else:
		# Reset zoom and position
		zoom = lerp(zoom, normalZoom, 0.1)
		global_position = lerp(global_position, defaultPosition, 0.1)
		offset = Vector2.ZERO

		# Reset time scale to normal
		Engine.time_scale = lerp(Engine.time_scale, 1.0, 0.1)

func _on_player_ship_start_close_call() -> void:
	isNearAsteroid = true
	$DangerLabel.visible = true

func _on_player_ship_scoring_close_call(_closeCallScore: Variant) -> void:
	isNearAsteroid = false
	$DangerLabel.visible = false
