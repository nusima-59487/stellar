extends Node

var _animated_sprite_2d: AnimatedSprite2D; 

# init
var bullet_speed: int = 350;
var bullet_damage: int = 10;
var bullet_sterams_count: int = 1; # max 3
var bullet_autofire_speed: int = 0; # max 25 believe me or your computer will crash
var earth_health: int = 80;
var lazer_unlocked: bool = false; # base false
var lazer_damage: int = 25;
var lazer_time: int = 5;
var lazer_cooldown_secs: int = 10;
var lazer_width: int = 10;
var damage_reduction_multiplier: float = 1.0; # base 1, goes up by small amt every wave
var junk_speed_multiplier: float = 1.0; # base 1, goes up by small amt every wave
# var spacecraft_speed = 15.0; 

var stellar_1_unlocked: bool = false;
var stellar_2_unlocked: bool = false;
var stellar_3_unlocked: bool = false;

func add_bullet_stream_count () -> void: 
	if bullet_sterams_count < 3: 
		bullet_sterams_count += 1; 
	if _animated_sprite_2d != null: 
		_animated_sprite_2d.animation = "ship" + str(bullet_sterams_count)
