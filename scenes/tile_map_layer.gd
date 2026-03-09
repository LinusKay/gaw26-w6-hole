extends TileMapLayer

@export var picked_up: bool = true


func _pickup() -> void:
	hide()
