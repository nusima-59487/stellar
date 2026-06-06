extends CanvasLayer

@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var _max := 1.0


func _process(_delta: float) -> void:
	if progress_bar == null or progress_bar.max_value <= 0.0:
		return
	# Pulse the bar when Earth is in critical condition.
	var frac := progress_bar.value / progress_bar.max_value
	if frac <= 0.3:
		var p := 0.55 + 0.45 * sin(Time.get_ticks_msec() / 110.0)
		progress_bar.modulate = Color(1.0, p, p)
	else:
		progress_bar.modulate = Color(1, 1, 1)


func update(current_val: int, max_val: int) -> void:
	_max = float(max_val)
	progress_bar.max_value = float(max_val)
	var tw := create_tween()
	tw.tween_property(progress_bar, "value", float(current_val), 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	rich_text_label.text = str(maxi(0, current_val)) + " / " + str(max_val)
	var frac := clampf(float(current_val) / _max, 0.0, 1.0)
	# Green when healthy, red when low (slightly > 1 so it blooms).
	progress_bar.tint_progress = Color(1.0, 0.25, 0.25).lerp(Color(0.35, 1.05, 0.45), frac)
