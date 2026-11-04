class_name LevelLoader
extends Node

@onready var level_root: Node2D = %LevelRoot


func load_level(level_path: String):
	for child in level_root.get_children():
		child.queue_free()
	
	var level_scene = load(level_path) as PackedScene
	if level_scene:
		var level_instance = level_scene.instantiate()
		level_root.add_child(level_instance)
