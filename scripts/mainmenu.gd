extends Node
@export var gameScene: PackedScene

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(gameScene)

func _on_button_2_pressed() -> void:
	get_tree().quit()
