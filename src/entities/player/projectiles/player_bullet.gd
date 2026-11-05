extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10

var direction: Vector2 = Vector2.ZERO
var has_hit: bool = false

func _physics_process(delta: float) -> void:
	position += direction * speed * delta #MATH!



func _on_lifetime_timeout() -> void: # will run 2 seconds after bullet is fired
	queue_free() #delete


func _on_body_entered(body: Node2D) -> void:
	if has_hit:
		return
	has_hit = true
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free() #delete the bullet when it hits a body
