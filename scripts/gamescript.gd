extends Node

var screenSize: Vector2
var left: float
var right: float
var top: float
var bottom: float
var score: int = 0
@export var spawnTimer: float = 0.5 
@export var asteroidSpawnerScene: PackedScene

func _ready() -> void:
	# Get the viewport's size (in pixels)
	screenSize = get_viewport().size
	var canvasOffset: Vector2 = get_viewport().get_canvas_transform().origin
	
	#Set edges of screen
	left = -canvasOffset.x
	top = -canvasOffset.y
	right = left + screenSize.x 
	bottom = top + screenSize.y 
	
	start_spawn_timer()

func wrap_object(object: Node2D) -> void:
	var pos: Vector2 = object.global_position
	var wrapped: bool = false
	#Check position values and wrap to opposite edge
	# Horizontal wrap.
	if pos.x < left:
		pos.x = right
		wrapped = true
	elif pos.x > right:
		pos.x = left
		wrapped = true

	# Vertical wrap.
	if pos.y < top:
		pos.y = bottom
		wrapped = true
	elif pos.y > bottom:
		pos.y = top
		wrapped = true

	#Applies wrapping all at once
	if wrapped:
		object.global_position = pos

func start_spawn_timer() -> void:
	#Creates a new timer used to trigger asteroid spawns
	var timer = Timer.new()
	timer.wait_time = spawnTimer
	timer.one_shot = false  # Repeat indefinitely
	add_child(timer)  # Add the timer as a child of the GameManager
	timer.start()
	timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	# Instantiate a new AsteroidSpawner
	if asteroidSpawnerScene:
		var spawner_instance = asteroidSpawnerScene.instantiate()
		# Set its position to a random location within the bounds of the screen
		spawner_instance.global_position = Vector2(
			randf_range(left, right),
			randf_range(top, bottom)
		)
		# Add the spawner to the scene tree
		add_child(spawner_instance)

func _process(_delta):
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()
		

#plays asteroid destroyed sfx
func _on_asteroid_play_sfx() -> void:
	$AudioStreamPlayerSFX.play(0.0)

#plays player destroyed sfx and triggers game over screen
func _on_player_ship_play_death_sfx() -> void:
	$AudioStreamPlayerShipDeath.play(0.0)
	$Score.visible = false
	$PanelContainer/VBoxContainer/Label.text = "Score: " + str(score)
	$PanelContainer.visible = true

#plays giant asteroid destroyed sfx
func _on_asteroid_giant_play_giant_sfx() -> void:
	$AudioStreamPlayerGiantSFX.play(0.0)

#Updates score based, increase is given by bullet based on size of asteroid that it destroyed
func _on_score_update(increase) -> void:
	score = score + increase
	$Score/Label.text = "Score: " + str(score)

#Updates score when close call (being near asteroid) ends based on time spent near
func _on_player_ship_scoring_close_call(closeCallScore: Variant) -> void:
	score = score + closeCallScore
	$Score/Label.text = "Score: " + str(score)

#Restart button on game over screen
func _on_button_pressed() -> void:
	get_tree().reload_current_scene()

#Quit button on game over screen
func _on_button_2_pressed() -> void:
	get_tree().quit()
