extends CharacterBody2D
class_name Bullet

@export var damage: int = 10
@export var speed = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	velocity = forward_direction * speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move_and_slide()

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body is Junk: 
		body.take_damage(damage)
		queue_free()
