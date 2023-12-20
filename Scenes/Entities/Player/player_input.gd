extends Node3D
class_name PlayerInput;

func get_movement_direction_input() -> Vector2:
	return Input.get_vector("Left", "Right", "Forward", "Backward");

func get_run_input() -> bool:
	return Input.is_action_pressed("Run");

func get_dash_input() -> bool:
	return Input.is_action_just_pressed("Dash");

func get_jump_input() -> bool:
	return Input.is_action_just_pressed("Jump");

func get_attack_input() -> bool:
	return Input.is_action_just_pressed("Attack");
