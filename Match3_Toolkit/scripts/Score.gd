extends Panel

var score = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ScoreLabel.text = "%d" % score

func _on_grid_score_update(value):
	score += value
