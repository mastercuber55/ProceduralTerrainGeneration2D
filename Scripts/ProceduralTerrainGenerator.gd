extends Node2D

@export var config: GenerationRules

var noise := FastNoiseLite.new()
var lookupTable := {}
var chunks = {}

@onready var ground := $"../Ground"
@onready var plants := $"../Plants"

func _ready() -> void:
	
	_buildTileLookUp()
	
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.05

func _process(_delta: float) -> void:
	var playerPos = %Player.global_position
	
	var chunkCoords = Vector2i(
		floor(playerPos.x / (config.chunk_size * config.tile_size)),
		floor(playerPos.y / (config.chunk_size * config.tile_size))
	)
	
	for x in range(chunkCoords.x - 2, chunkCoords.x + 3):
		for y in range(chunkCoords.y - 2, chunkCoords.y + 3):
			var targetChunk = Vector2i(x, y)
			if not chunks.has(targetChunk):
				_genChunk(targetChunk)
				chunks[targetChunk] = true # marking as Active -> true
				
	for chunk in chunks.keys():
		if 	abs(chunk.x - chunkCoords.x) > config.render_distance or\
			abs(chunk.y - chunkCoords.y) > config.render_distance:
				_remChunk(chunk)
				chunks.erase(chunk)

# TODO: make each plant be a dedicated scene with health and animation
func _genPlant(n, pos):
	
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(pos) + n
	var roll := rng.randf()
	
	for z in config.plant_chances:
		if roll < z.chance:
			plants.set_cell(pos, 0, z.tile)
			return

func _genChunk(chunk: Vector2i):	
	var start = chunk * config.chunk_size
	var groupTiles : Dictionary = {}
	
	for x in range(start.x, start.x + config.chunk_size):
		for y in range(start.y, start.y + config.chunk_size):
			var n = noise.get_noise_2d(x, y)
			var data := _getTile(n)
			
			_genPlant(n, Vector2i(x, y))
			
			if data.has("terrainID"):
				var terrainID = data["terrainID"]
				if not groupTiles.has(terrainID):
					groupTiles[terrainID] = []
				groupTiles[terrainID].append(Vector2i(x, y))
			else:
				var lookupData = lookupTable[data.tile]
				ground.set_cell(Vector2i(x, y), lookupData.srcID, lookupData.coords)
	
	if groupTiles.is_empty():
		return
	
	for group in groupTiles:
		ground.set_cells_terrain_connect(groupTiles[group], 0, group)
	
func _remChunk(chunk: Vector2i):	
	var start = chunk * config.chunk_size
	
	for x in range(start.x, start.x + config.chunk_size):
		for y in range(start.y, start.y + config.chunk_size):
			ground.set_cell(Vector2i(x, y), -1)
			
func _getTile(n: float) -> Dictionary:
	for level in config.terrain_levels:
		if n <= level.max:
			return level
	return config.terrain_levels[0]

func _buildTileLookUp():
	
	var srcCount : int = ground.tile_set.get_source_count()
	
	for iSrc in range(srcCount):
		var srcID = ground.tile_set.get_source_id(iSrc)
		var src = ground.tile_set.get_source(srcID)
		
		if src is TileSetAtlasSource:
			for iTiles in range(src.get_tiles_count()):
				var coords = src.get_tile_id(iTiles)	
				var tileData = src.get_tile_data(coords, 0)
				
				if tileData == null:
					continue
					
				var terrainVal : StringName = tileData.get_custom_data("TileName")
				
				if terrainVal.is_empty():
					continue
					
				lookupTable[terrainVal] = { "srcID": srcID, "coords": coords,  }
