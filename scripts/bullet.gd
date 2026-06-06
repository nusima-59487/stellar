extends CharacterBody2D
class_name Bullet

var damage: int; 
var speed: int; 
@onready var player: CharacterBody2D = $"../Player"
@onready var ui: Node2D = $"../UI"
var og_location: Vector2; 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	og_location = global_position
	damage = GameInstance.bullet_damage; 
	speed = GameInstance.bullet_speed; 
	print(speed)
	
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	velocity = forward_direction * speed



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	move_and_slide()
	if (self.global_position - og_location).length() > 1000:
		queue_free()

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body is Junk: 
		var body_stage = body.stage
		body.take_damage(damage)
		ui.add_xp(damage); 
		queue_free()
