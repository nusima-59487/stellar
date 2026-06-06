extends Node2D

var xp_needed = [50, 100, 150, 200, 300, 400, 500, 600]
var current_xp_needed_index: int = 0
var xp_count: int = 0; 
var updates_available: Dictionary = {
	"bullet_stream": 4, 
	"bullet_speed": 20, 
	"bullet_damage": 16, 
	"bullet_autofire_speed": 3, 
	"increase_max_earth_health": 15,
	"regen_earth_health": 10, 
	"lazer_unlock": 3, 
	"reduce_damage_taken": 7, 
	"slow_junk": 8, 
}
var update_stages: Dictionary = {
	"bullet_stream": [1, 2, 3], 
	"bullet_speed": [410, 470, 530, 590, 650, 710, 770], 
	"bullet_damage": [18, 26, 34, 42, 50, 58, 66], 
	"bullet_autofire_speed": [1, 2, 3, 5, 8, 16, 25], 
	"increase_max_earth_health": [], 
	"regen_earth_health": [], 
	"lazer_unlock": [true], 
	"lazer_damage": [35, 45, 60, 75, 90, 105, 120], 
	"lazer_time": [6, 7, 8, 9, 10, 11, 12], 
	"increase_lazer_cooldown": [], 
	"reduce_damage_taken": [], 
	"slow_junk": [], 
	"stellar_1": [true], 
	"stellar_2": [true], 
	"stellar_3": [true]
}

var update_titles: Dictionary = {
	"bullet_stream": "Increase bullet streams", 
	"bullet_speed": "Increase bullet speed", 
	"bullet_damage": "Increase bullet damage", 
	"bullet_autofire_speed": "Increase bullet autofire speed", 
	"increase_max_earth_health": "Increase max earth health", 
	"regen_earth_health": "Restore earth health", 
	"lazer_unlock": "Unlock Lazer (RMB)", 
	"lazer_damage": "Increase lazer damage", 
	"lazer_time": "Increase Lazer duration", 
	"increase_lazer_cooldown": "Decrease Lazer cooldown", 
	"reduce_damage_taken": "Earth Shield", 
	"slow_junk": "Slow junk", 
	"stellar_1": "STELLAR 1", 
	"stellar_2": "stellar_2", 
	"stellar_3": "stellar_3"
}

var update_count: Dictionary = {}



@onready var experience_bar: TextureProgressBar = $ExpCanvasLayer/ExperienceBar
@onready var abilities_canvas_layer: CanvasLayer = $AbilitiesCanvasLayer
@onready var label3: Label = $AbilitiesCanvasLayer/CenterContainer/ColorRect/Label
@onready var label2: Label = $AbilitiesCanvasLayer/CenterContainer2/ColorRect/Label
@onready var label: Label = $AbilitiesCanvasLayer/CenterContainer3/ColorRect/Label
@onready var button: Button = $AbilitiesCanvasLayer/CenterContainer3/Button
@onready var button2: Button = $AbilitiesCanvasLayer/CenterContainer2/Button3
@onready var button3: Button = $AbilitiesCanvasLayer/CenterContainer/Button2
@onready var animated_sprite_2d: AnimatedSprite2D = $AbilitiesCanvasLayer/CenterContainer3/AnimatedSprite2D3
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AbilitiesCanvasLayer/CenterContainer2/AnimatedSprite2D2
@onready var animated_sprite_2d_3: AnimatedSprite2D = $AbilitiesCanvasLayer/CenterContainer/AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	abilities_canvas_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	experience_bar.max_value = xp_needed[current_xp_needed_index]
	experience_bar.value = xp_count


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_xp (count: int) -> void: 
	xp_count += count
	var xp_required = xp_needed[current_xp_needed_index] if current_xp_needed_index < xp_needed.size() else 700
	if xp_count >= xp_required: 
		current_xp_needed_index += 1
		xp_count = 0
		print("Level up! Current level: " + str(current_xp_needed_index))
		abilities_canvas_layer.visible = true; 
		get_tree().paused = true;
		var choice1 = _pull_update()
		var choice2 = _pull_update()
		var choice3 = _pull_update()
		label.text = update_titles[choice1]
		button.text = choice1
		animated_sprite_2d.animation = choice1
		label2.text = update_titles[choice2]
		button2.text = choice2
		animated_sprite_2d_2.animation = choice2
		label3.text = update_titles[choice3]
		button3.text = choice3
		animated_sprite_2d_3.animation = choice3
	update_progress_bar()

func update_progress_bar() -> void:
	experience_bar.max_value = xp_needed[current_xp_needed_index] if current_xp_needed_index < xp_needed.size() else 700
	experience_bar.value = xp_count


func apply_update (key: String) -> void: 
	var is_upgrade_path_end = _upgrade_stats(key, update_count.get(key, -1))
	if is_upgrade_path_end: 
		updates_available.erase(key)

func _pull_update () -> String: 
	## Calculate the total weights
	var totalWeights : int = 0
	for key in updates_available:
		totalWeights += updates_available[key]
	var keyGenerated : bool = false
	while !keyGenerated:
		## Generate a random weight
		var randomWeight : int = randi_range(0, totalWeights)

		## Pick a random item based on the random weight
		for update_key in updates_available:
			randomWeight -= updates_available[update_key]

			if randomWeight < 0:
				keyGenerated = true
				return update_key
	return "" # should never reach


### @return if it is the end of the stat upgrade path
func _upgrade_stats (stat_key: String, current_stage_idx: int) -> bool: 
	var updated_stage_idx = current_stage_idx + 1
	var is_infinite_upgrade = update_stages[stat_key].size() == 0
	var new_stat_val = update_stages[stat_key][updated_stage_idx] if not is_infinite_upgrade else 0
	update_count[stat_key] = updated_stage_idx
	match stat_key:
		"bullet_stream":
			GameInstance.add_bullet_stream_count()
		"bullet_speed":
			GameInstance.bullet_speed = new_stat_val; 
		"bullet_damage": 
			GameInstance.bullet_damage = new_stat_val; 
		"bullet_autofire_speed":
			GameInstance.bullet_autofire_speed = new_stat_val; 
		"increase_max_earth_health":
			GameInstance.max_earth_health += 15; 
		"regen_earth_health":
			GameInstance.earth_ref.hp += 15; 
			if GameInstance.earth_ref.hp > GameInstance.max_earth_health: 
				GameInstance.earth_ref.hp = GameInstance.max_earth_health
		"lazer_unlock":
			GameInstance.lazer_unlocked = new_stat_val; 
			updates_available.merge({	
				"lazer_damage": 9, 
				"lazer_time": 6, 
				"increase_lazer_cooldown": 5, 
				"stellar_1": 1, 
				"stellar_2": 1, 
				"stellar_3": 1
			})
		"lazer_damage":
			GameInstance.lazer_damage = new_stat_val; 
		"lazer_time":
			GameInstance.lazer_time = new_stat_val; 
		"increase_lazer_cooldown":
			GameInstance.lazer_cooldown_secs -= 1
			return GameInstance.lazer_cooldown_secs <= 0
		"reduce_damage_taken":
			GameInstance.damage_reduction_multiplier -= 0.06; 
			return GameInstance.damage_reduction_multiplier <= 0.2
		"slow_junk":
			GameInstance.junk_speed_multiplier -= 0.06; 
			return GameInstance.junk_speed_multiplier <= 0.4
		"stellar_1":
			GameInstance.stellar_1_unlocked = new_stat_val; 
		"stellar_2":
			GameInstance.stellar_2_unlocked = new_stat_val; 
		"stellar_3":
			GameInstance.stellar_3_unlocked = new_stat_val;
		_:
			pass

	GameInstance.stats_updated.emit()
	if is_infinite_upgrade:
		return false
	var e = update_stages[stat_key]
	var f = e[updated_stage_idx+1] if updated_stage_idx+1 < e.size() else null
	return f == null


func _on_button1_pressed() -> void:
	print("hi")
	apply_update(button.text); 
	abilities_canvas_layer.visible = false; 
	get_tree().paused = false

func _on_button2_pressed() -> void:
	print("hi")
	apply_update(button2.text); 
	abilities_canvas_layer.visible = false; 
	get_tree().paused = false





func _on_button_3_pressed() -> void:
	print("hi")
	apply_update(button3.text); 
	abilities_canvas_layer.visible = false; 
	get_tree().paused = false
