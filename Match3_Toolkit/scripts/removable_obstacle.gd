extends Piece

signal obstacle_destroyed()

func _ready():
	self.obstacle_destroyed.connect(get_node("/root/game_window/GoalCounter")._on_obstacle_destroyed)
	super._ready()

func destroy():
	emit_signal("obstacle_destroyed")
	super.destroy()

func set_color(color, sprite):
	pass

func take_damage(amount):
	pass

func _on_adjacent_match():
	if matched:
		return
	dim()
	matched = true
	emit_signal("obstacle_destroyed")
