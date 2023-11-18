class_name MathUtil

extends Object

static func angle_diff(from: float, to: float) -> float:
	return fposmod(to - from + PI, TAU) - PI

static func delta_lerp(from: Variant, to: Variant, weight: float, delta: float) -> Variant:
	return lerp(from, to, 1.0 - pow(1.0 - weight, delta))
