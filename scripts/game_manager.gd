extends Node

var bullet_speed: int; # base 200
var bullet_damage: int; # base 10
var bullet_sterams_count: int; # 1-3
var bullet_autoclick_speed: int; # base 0 = not enabled
var earth_health: int; # base 80
var lazer_unlocked: bool; # base false
var lazer_damage: int; 
var lazer_time: int; 
var lazer_cooldown_secs: int; 
var lazer_width: int; 
var damage_reduction_multiplier: float; # base 1, goes up by small amt every wave
var junk_speed_multiplier: float; # base 1, goes up by small amt every wave
