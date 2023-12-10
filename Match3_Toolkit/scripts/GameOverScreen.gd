extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


func _on_grid_game_over():
	visible = true


func _on_reset_button_pressed():
	visible = false
