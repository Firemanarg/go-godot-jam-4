extends Control


var reference = null


func _ready():
	pass


func _process(delta):
	pass


func set_reference(reference):
	if self.reference:
		self.reference.queue_free()
	reference
