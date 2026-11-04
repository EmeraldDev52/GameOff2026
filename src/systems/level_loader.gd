class_name LevelLoader
extends Node

@onready var level_root: Node2D = %LevelRoot

const level_folder: String = "res://src/levels/"

func load_level(level_name: String):
	var path = "{folder}/{name}/{name}.tscn".format({
		"folder": level_folder,
		"name": level_name
	})
	
	for child in level_root.get_children():
		child.queue_free()
	
	var level_scene = load(path) as PackedScene
	if level_scene:
		var level_instance = level_scene.instantiate()
		level_root.add_child(level_instance)


func time_travel(version: String = ""):
	if version == "past" or version == "present":
		for child in level_root.get_children():
			if child is Level:
				child.switch_to_version(version)
	else:
		for child in level_root.get_children():
			if child is Level:
				child.toggle_level_version()
