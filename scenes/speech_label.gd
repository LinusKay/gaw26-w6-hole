extends RichTextLabel

@onready var speech_timer: Timer = $SpeechTimer
var fading: bool = false
@onready var point: TextureRect = $"../Point"
@onready var foghornaudio: AudioStreamPlayer = $"../Point/foghornaudio"

func _ready() -> void:
	Player.speech.connect(speech)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if fading:
		modulate.a -= 0.01
		point.modulate.a -= 0.01
	if modulate.a <= 0:
		fading = false


func speech(words: String) -> void:
	modulate.a = 1
	point.modulate.a = 1
	text = words
	speech_timer.start(2.0)
	foghornaudio.play()



func _on_speech_timer_timeout() -> void:
	fading = true
