extends CanvasLayer

@onready var label_capacity: Label = $Control/VBoxContainer/LabelCapacity
@onready var label_load: Label = $Control/VBoxContainer/LabelLoad

@onready var portrait: TextureRect = $Control/Portrait
@onready var portraits: Array[CompressedTexture2D] = [
	preload("res://sprites/portrait/portrait_blush.png"),
	preload("res://sprites/portrait/portrait_happy.png"),
	preload("res://sprites/portrait/portrait_neutral.png"),
	preload("res://sprites/portrait/portrait_cool.png"),
	preload("res://sprites/portrait/portrait_uhoh.png"),
	preload("res://sprites/portrait/portrait_eye.png"),
	preload("res://sprites/portrait/portrait_stuck.png"),
	preload("res://sprites/portrait/portrait_angle.png"),
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label_capacity.text = "Power: " + str(Player.weight_capacity)
	label_load.text = "Load: " + str(Player.get_current_weight())


func _on_timer_timeout() -> void:
	portrait.texture = portraits.pick_random()
