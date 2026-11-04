extends Node2D

@onready var present: Node2D = $Present
@onready var past: Node2D = $Past

var current_version: String


func _ready() -> void:
	switch_to_present()


func enable(node: Node):
	node.process_mode = Node.PROCESS_MODE_INHERIT
	node.show()


func disable(node: Node):
	node.process_mode = Node.PROCESS_MODE_DISABLED
	node.hide()


func switch_to_present():
	enable(present)
	disable(past)
	current_version = "present"


func switch_to_past():
	enable(past)
	disable(present)
	current_version = "past"


func toggle_level_version():
	if current_version == "present":
		switch_to_past()
	else:
		switch_to_present()
