extends CanvasLayer

@onready var label_capacity: RichTextLabel = $Control/VBoxContainer/LabelCapacity
@onready var label_load: RichTextLabel = $Control/VBoxContainer/LabelLoad
@onready var speech_label: RichTextLabel = $Control/SpeechLabel
@onready var speech_timer: Timer = $Control/SpeechLabel/SpeechTimer
@onready var texyoudoneit: TextureRect = $Control/youdoneit
@onready var youdoneitaudio: AudioStreamPlayer = $Control/youdoneit/youdoneitaudio

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
	preload("res://sprites/portrait/portrait_nerd.png"),
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.youdoneit.connect(youdoneit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label_capacity.text = "Power: " + str(Player.weight_capacity)
	label_load.text = "Load: " + str(Player.get_current_weight())


func _on_timer_timeout() -> void:
	portrait.texture = portraits.pick_random()

func youdoneit() -> void:
	if not Player.alldone:
		texyoudoneit.show()
		youdoneitaudio.play()
