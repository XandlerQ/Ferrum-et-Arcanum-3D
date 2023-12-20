extends Node3D;
class_name VectorConverter;

static func convert_vector_3_2(vector: Vector3) -> Vector2:
	var rVector: Vector2;
	rVector.x = vector.x;
	rVector.y = vector.z;
	return rVector;

static func convert_vector_2_3(vector: Vector2) -> Vector3:
	var rVector: Vector3;
	rVector.x = vector.x;
	rVector.z = vector.y;
	return rVector;
