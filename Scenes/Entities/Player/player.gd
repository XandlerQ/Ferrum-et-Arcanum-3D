extends CharacterBody3D;
class_name Player;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.003);
		$Camera.rotate_x(-event.relative.y * 0.003);
		$Camera.rotation.x = clamp($Camera.rotation.x, -PI/2, PI/2);

func _process(delta):
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit();

func _physics_process(delta):
	# Add the gravity.
	
	var movementDirectionInput: Vector2 = $PlayerInput.get_movement_direction_input();
	var direction = (transform.basis * Vector3(movementDirectionInput.x, 0, movementDirectionInput.y)).normalized()
	var direction2: Vector2;
	direction2.x = direction.x;
	direction2.y = direction.z;
	var runningInput: bool = $PlayerInput.get_run_input();
	var dashInput: bool = $PlayerInput.get_dash_input();
	if (dashInput):
		$EntityMovement.dash_in_direction(delta, direction2);
	elif (runningInput):
		$EntityMovement.run_in_direction(delta, direction2);
	else:
		$EntityMovement.walk_in_direction(delta, direction2);
	
	$EntityMovement.fall(delta);

	# Handle jump.
	if Input.is_action_just_pressed("Jump"):
		$EntityMovement.jump();
	move_and_slide();
	
	$Camera.camera_movement(delta, VectorConverter.convert_vector_3_2(velocity).length(), is_on_floor());
