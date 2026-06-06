extends CanvasLayer

@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var rich_text_label: RichTextLabel = $RichTextLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update(current_val: int, max_val: int) -> void: 
	progress_bar.max_value = float(max_val); 
	progress_bar.value = float(current_val); 
	if current_val <= 0: 
		current_val = 0
	rich_text_label.text = str(current_val) + " / " + str(max_val);
