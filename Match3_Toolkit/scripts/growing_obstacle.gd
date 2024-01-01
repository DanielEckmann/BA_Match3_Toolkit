extends Piece

signal grow_obstacle(pos)
signal grow_obstacle_destroyed()

func _ready():
	self.grow_obstacle.connect(get_parent()._on_grow_obstacle)
	self.grow_obstacle_destroyed.connect(get_parent()._on_grow_obstacle_destroyed)
	super._ready()

func destroy():
	emit_signal("grow_obstacle_destroyed")
	super.destroy()

func set_color(color, sprite):
	pass

func take_damage(amount):
	pass

func _on_adjacent_match():
	dim()
	matched = true
	emit_signal("grow_obstacle_destroyed")

func _on_turn_end():
	emit_signal("grow_obstacle", self.pos)
