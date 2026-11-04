extends Area2D

@export var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += direction * speed * delta #MATH!



func _on_lifetime_timeout() -> void: # will run 2 seconds after bullet is fired
	queue_free() #delete
