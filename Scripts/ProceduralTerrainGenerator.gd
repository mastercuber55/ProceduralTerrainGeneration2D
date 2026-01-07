extends TileMapLayer

const CHUNK_SIZE := 8
const TILE_SIZE := 16
const RENDER_DISTANCE := 3 # Chunks

const TERRAIN_LEVELS := [
	{ "max": -0.4, "tile": "Dirt",  "terrainID": 0 },
	{ "max": 0.0,  "tile": "Plain Grass",   },
	{ "max": 0.2,  "tile": "Grassy Grass",  },
	{ "max": 1.0,  "tile": "Flowery Grass", }
]

var noise := FastNoiseLite.new()
var lookupTable := {}
var chunks = {}

func _ready() -> void:
	
	_buildTileLookUp()
	
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.05

func _process(_delta: float) -> void:
	var playerPos = $"../Player".global_position
	
	var chunkCoords = Vector2i(
		floor(playerPos.x / (CHUNK_SIZE * TILE_SIZE)),
		floor(playerPos.y / (CHUNK_SIZE * TILE_SIZE))
	)
	
	for x in range(chunkCoords.x - 2, chunkCoords.x + 3):
		for y in range(chunkCoords.y - 2, chunkCoords.y + 3):
			var targetChunk = Vector2i(x, y)
			if not chunks.has(targetChunk):
				_genChunk(targetChunk)
				chunks[targetChunk] = true # marking as Active -> true
				
	for chunk in chunks.keys():
		if 	abs(chunk.x - chunkCoords.x) > RENDER_DISTANCE or\
			abs(chunk.y - chunkCoords.y) > RENDER_DISTANCE:
				_remChunk(chunk)
				chunks.erase(chunk)

func _genChunk(chunk: Vector2i):	
	var start := chunk * CHUNK_SIZE
	var groupTiles : Dictionary = {}
	
	for x in range(start.x, start.x + CHUNK_SIZE):
		for y in range(start.y, start.y + CHUNK_SIZE):
			var n = noise.get_noise_2d(x, y)
			var data := _getTile(n)
			
			if data.has("terrainID"):
				var terrainID = data["terrainID"]
				if not groupTiles.has(terrainID):
					groupTiles[terrainID] = []
				groupTiles[terrainID].append(Vector2i(x, y))
			else:
				var lookupData = lookupTable[data.tile]
				set_cell(Vector2i(x, y), lookupData.srcID, lookupData.coords)
	
	if groupTiles.is_empty():
		return
	
	for group in groupTiles:
		set_cells_terrain_connect(groupTiles[group], 0, group)
	
func _remChunk(chunk: Vector2i):	
	var start = chunk * CHUNK_SIZE
	
	for x in range(start.x, start.x + CHUNK_SIZE):
		for y in range(start.y, start.y + CHUNK_SIZE):
			set_cell(Vector2i(x, y), -1)
			
func _getTile(n: float) -> Dictionary:
	for level in TERRAIN_LEVELS:
		if n <= level.max:
			return level
	return TERRAIN_LEVELS[0]

func _buildTileLookUp():
	
	var srcCount := tile_set.get_source_count()
	
	for iSrc in range(srcCount):
		var srcID := tile_set.get_source_id(iSrc)
		var src = tile_set.get_source(srcID)
		
		if src is TileSetAtlasSource:
			for iTiles in range(src.get_tiles_count()):
				var coords := src.get_tile_id(iTiles)	
				var tileData = src.get_tile_data(coords, 0)
				
				if tileData == null:
					continue
					
				var terrainVal : StringName = tileData.get_custom_data("TileName")
				
				if terrainVal.is_empty():
					continue
					
				lookupTable[terrainVal] = { "srcID": srcID, "coords": coords,  }
