extends AudioStreamPlayer

# Adjusting pitch scale dynamically based on time scale
func _process(_delta):
	# Match pitch to the time scale, lerping for smooth transition
	var targetPitch = Engine.time_scale  
	self.pitch_scale = lerp(self.pitch_scale, targetPitch, 0.1)
