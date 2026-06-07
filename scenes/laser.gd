extends Node2D

var damage: int = GameInstance.lazer_damage; 
var fire_timer = 0.0
var fire_rate = 0.1  # damage every 0.1 seconds
var cooldown = GameInstance.lazer_cooldown_secs
var laser_time = GameInstance.lazer_time
@onready var player: CharacterBody2D = $".."
@onready var experience_bar: TextureProgressBar = $"../../UI/ExpCanvasLayer/ExperienceBar"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameInstance.stats_updated.connect(_on_stats_updated)
	pass # Replace with function body.
func _on_stats_updated (): 
	damage = GameInstance.lazer_damage
	cooldown = GameInstance.lazer_cooldown_secs
	laser_time = GameInstance.lazer_time

func _process(delta: float) -> void:
	$RayCast2D.force_raycast_update()
	fire_timer -= delta
	
	if $RayCast2D.is_colliding() && $Line2D.visible:
		var hit_pos = $RayCast2D.get_collision_point()
		var collider = $RayCast2D.get_collider()
		
		$Line2D.set_point_position(1, to_local(hit_pos))
		
		if collider is Junk and fire_timer <= 0.0:
			collider.take_damage(damage)
			player.xp += damage
			experience_bar.value = player.xp
			fire_timer = fire_rate
	else:
		$Line2D.set_point_position(1, $RayCast2D.target_position)
