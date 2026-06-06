extends CharacterBody2D
class_name Bullet

@export var damage: int = 10
@export var speed = 200
var player: CharacterBody2D
var experience_bar: TextureProgressBar; 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $"../Player"
	experience_bar = $"../UI/CanvasLayer/ExperienceBar"
	experience_bar.max_value = 50
	experience_bar.value = player.xp
	
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	velocity = forward_direction * speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move_and_slide()

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body is Junk: 
		body.take_damage(damage)
		player.xp += damage
		experience_bar.value = player.xp
		print(experience_bar.value)
		queue_free()
