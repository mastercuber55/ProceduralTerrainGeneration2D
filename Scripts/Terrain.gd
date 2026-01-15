extends Node2D

const RENDER_DISTANCE := 2
const TILE_SIZE := 16
const CHUNK_SIZE := 8

var lastChunk : Vector2i
var currentChunk : Vector2i
var LoadedChunks : Array[Vector2i]

@export var generator : NoiseGenerator
@export var player : CharacterBody2D

func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	currentChunk = Vector2i(
		floor(player.global_position.x / (CHUNK_SIZE * TILE_SIZE)),
		floor(player.global_position.y / (CHUNK_SIZE * TILE_SIZE))
	)
	
	if currentChunk == lastChunk:
		return
		
	lastChunk = currentChunk
	updateChunks()

func updateChunks():
	
	for x in range(-RENDER_DISTANCE, RENDER_DISTANCE + 1):
		for y in range(-RENDER_DISTANCE, RENDER_DISTANCE + 1):
			var targetChunk = currentChunk + Vector2i(x, y)
			LoadedChunks.append(targetChunk)
			WorkerThreadPool.add_task(generator.generate_chunk.bind(targetChunk))
			
	for chunk in LoadedChunks:
		var distance = abs(chunk - currentChunk)
		if distance.x > RENDER_DISTANCE + 1 or distance.y > RENDER_DISTANCE + 1:
			WorkerThreadPool.add_task(generator.erase_chunk.bind(chunk))
			LoadedChunks.erase(chunk)
