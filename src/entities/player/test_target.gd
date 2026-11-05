extends StaticBody2D

@export var health: int = 30

func take_damage(amount: int) -> void:
    health -= amount
    print(health)
    if health <= 0:
        queue_free() #delete the target when it dies
