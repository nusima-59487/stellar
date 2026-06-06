extends CharacterBody2D
class_name Bullet

var damage: int; 
var speed: int; 
@onready var player: CharacterBody2D = $"../Player"
@onready var experience_bar: TextureProgressBar = $"../UI/CanvasLayer/ExperienceBar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	experience_bar.max_value = 50
	experience_bar.value = player.xp
	
	damage = GameInstance.bullet_damage; 
	speed = GameInstance.bullet_speed; 
	
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	velocity = forward_direction * speed



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move_and_slide()
	if (self.global_position - Vector2.ZERO).length() > 1000:
		queue_free()

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body is Junk: 
		body.take_damage(damage)
		player.xp += damage
		experience_bar.value = player.xp
		print(experience_bar.value)
		queue_free()
