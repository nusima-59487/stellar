extends CharacterBody2D
class_name Junk


var all_stage = ["big","med","smol"]
var all_hp = [10, 5, 2]

var hitbox_ready := false

@export var health: int = 10 # todo: scale this based on # seconds survived
@export var stage: int = 0
@export var dir = true
@export var C_SPEED = 40.0
@export var T_SPEED = 130.0 * GameInstance.junk_speed_multiplier

@onready var JUNK = preload("res://scenes/junk.tscn"); 

func _ready() -> void:
	await get_tree().create_timer(.3).timeout # first .3 second invincible
	hitbox_ready = true; 

func _physics_process(_shit) -> void:
	$AnimatedSprite2D.animation = all_stage[stage]
	var target_pos := Vector2.ZERO; 
	var my_pos = self.position; 
	var direction = target_pos - my_pos
	# Calculate angle to target
	var angle_to_target := atan2(direction.y, direction.x)
	var perpendicular_angle := atan2(direction.y, direction.x) + PI/2
	# Set velocity based on angle
	
	if dir == true:
		velocity.x = C_SPEED * cos(angle_to_target) + T_SPEED * cos(perpendicular_angle)
		velocity.y = C_SPEED * sin(angle_to_target) + T_SPEED * sin(perpendicular_angle)
	elif dir == false:
		velocity.x = C_SPEED * cos(angle_to_target) - T_SPEED * cos(perpendicular_angle)
		velocity.y = C_SPEED * sin(angle_to_target) - T_SPEED * sin(perpendicular_angle)
	move_and_slide()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		break_junk()

func break_junk() -> void:
	if self.stage == 2:
		queue_free()
		return

	var JUNK1 = preload("res://scenes/junk.tscn")
	var junk_instance1 = JUNK1.instantiate()
	junk_instance1.position = self.position + Vector2(2, 2)
	junk_instance1.rotation = self.rotation - PI/2
	junk_instance1.stage = self.stage + 1
	junk_instance1.dir = true
	junk_instance1.health = all_hp[junk_instance1.stage]
	junk_instance1.modulate = Color(0.85, 0.341, 0.293, 1.0)
	get_tree().current_scene.call_deferred("add_child", junk_instance1)

	var JUNK2 = preload("res://scenes/junk.tscn")
	var junk_instance2 = JUNK2.instantiate()
	junk_instance2.position = self.position + Vector2(-2, -2)
	junk_instance2.rotation = self.rotation - PI/2
	junk_instance2.stage = self.stage + 1
	junk_instance2.dir = false
	junk_instance2.health = all_hp[junk_instance2.stage]
	junk_instance2.modulate = Color(0.85, 0.341, 0.293, 1.0)
	get_tree().current_scene.call_deferred("add_child", junk_instance2)

	self_modulate = Color(0.85, 0.341, 0.293, 1.0)
	await get_tree().create_timer(0.1).timeout

	# Reset all three
	if junk_instance1 && junk_instance2:
		self_modulate = Color(1, 1, 1, 1)
		junk_instance1.modulate = Color(1, 1, 1, 1)
		junk_instance2.modulate = Color(1, 1, 1, 1)

	await get_tree().create_timer(0.1).timeout
	queue_free()
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		pass
	elif body is Junk && self.hitbox_ready && body.hitbox_ready:
		break_junk()
		
