extends Panel

var time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	$TimerLabel.text = "%d" % time


func _on_reset_button_pressed():
	time = 0.0
