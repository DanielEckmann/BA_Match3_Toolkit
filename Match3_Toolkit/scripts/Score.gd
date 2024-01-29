extends Label

var score = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$".".text = "%d" % score

func _on_grid_score_update(value, color):
	score += value

func get_score():
	return score

func _on_reset_button_pressed():
	score = 0
