extends Control


onready var _animation_player: AnimationPlayer = $AnimationPlayer


func expand() -> void:
	_animation_player.stop(true)
	_animation_player.play("expand")

