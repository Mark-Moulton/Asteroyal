extends Label

func _ready():
	#Rapidly flash alpha for danger label
	var tween = create_tween()
	tween.set_loops(-1)
	tween.tween_property(self, "modulate:a", 0, 0.1)
	tween.tween_property(self, "modulate:a", 1, 0.1) 
