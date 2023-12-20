extends Camera3D;

@export var cameraOriginPosition: Vector3 = Vector3(0, 0.5, 0);

@export var baseFOV: float = 90;
@export var velocityFOVModifier: float = 0.;
@export var FOVChangeSpeed: float = 4;

@export var headBobIdle: float = 0.015;
@export var headBobFrequency: float = 3.0;
@export var headBobYAmplitude: float = 0.04;
@export var headBobXAmplitude: float = 0.02;
var headBobT: float = 0;

func normalize_head_bob_T() -> void:
	if (headBobT * headBobFrequency > 4 * PI):
		headBobT = (headBobT * headBobFrequency - 4 * PI) / headBobFrequency;

func camera_movement(delta: float, entityVelocity: float, isOnFloor: bool) -> void:
	head_bob(delta, entityVelocity, isOnFloor);
	FOV_change(delta, entityVelocity);

func head_bob(delta: float, entityVelocity: float, isOnFloor: bool) -> void:
	headBobT += (delta * entityVelocity + headBobIdle * float(entityVelocity == 0)) * float(isOnFloor);
	normalize_head_bob_T();
	var cameraPosition: Vector3 = cameraOriginPosition;
	cameraPosition.y = cameraOriginPosition.y + sin(headBobT * headBobFrequency) * headBobYAmplitude;
	cameraPosition.x = cameraOriginPosition.x + cos(headBobT * headBobFrequency / 2) * headBobXAmplitude;
	transform.origin = cameraPosition;

func FOV_change(delta: float, entityVelocity: float):
	if $"..".has_node("EntityMovement"):
		var maxHorizontalSpeed: float = $"../EntityMovement".maxHorizontalSpeed;
		var modifier: float = entityVelocity / maxHorizontalSpeed;
		if (modifier < 0.5): modifier = 0;
		var targetFOV: float = baseFOV + modifier * velocityFOVModifier;
		if (fov == targetFOV): return;
		fov = lerp(fov, targetFOV, delta * FOVChangeSpeed);
