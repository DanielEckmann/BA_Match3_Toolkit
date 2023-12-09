extends Panel

var time = 0.0
var seconds = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	seconds = fmod(time, 60)
	$TimerLabel.text = "%02d" % seconds
