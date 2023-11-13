extends Piece

signal jellyfish_destroyed()

func _ready():
	
	super._ready()

func destroy():
	emit_signal("jellyfish_destroyed")
	super.destroy()
