extends SceneTree

const ORIGIN: String = "Workshop/ToolShed/Completed_Tool_Builds/RapidGenerationInspection/benchmark_rapid_generator.gd"
const SIZE: int = 5
const WARMUPS: int = 100
const SAMPLES: int = 2000


func _init() -> void:
	for index: int in range(WARMUPS):
		RapidRoomGenerator.make_seeded_map(SIZE, index)
	var samples: PackedInt64Array = []
	var total_usec: int = 0
	for index: int in range(SAMPLES):
		var started_usec: int = Time.get_ticks_usec()
		var data: RapidRoomMapData = RapidRoomGenerator.make_seeded_map(SIZE, index + WARMUPS)
		var elapsed_usec: int = Time.get_ticks_usec() - started_usec
		if data == null:
			push_error("%s: Rapid returned null at sample %d." % [ORIGIN, index])
			quit(1)
			return
		samples.append(elapsed_usec)
		total_usec += elapsed_usec
	samples.sort()
	print("%s: size=%d warmups=%d samples=%d mean=%.3fms median=%.3fms p95=%.3fms p99=%.3fms max=%.3fms" % [
		ORIGIN,
		SIZE,
		WARMUPS,
		SAMPLES,
		float(total_usec) / float(SAMPLES) / 1000.0,
		float(samples[SAMPLES / 2]) / 1000.0,
		float(samples[int(floor(float(SAMPLES) * 0.95))]) / 1000.0,
		float(samples[int(floor(float(SAMPLES) * 0.99))]) / 1000.0,
		float(samples[SAMPLES - 1]) / 1000.0,
	])
	quit(0)
