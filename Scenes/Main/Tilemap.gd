extends TileMap

export(int) var PILL_TILE_ID     = 16
export(int) var PILL_BIG_TILE_ID = 17
export(int) var PACMAN_TILE_ID   = 18

export(int) var MAP_WIDTH  = 28
export(int) var MAP_HEIGHT = 31

var spawn_position

onready var astar = AStar.new()

# "Public" functions

# Removes the dot at a given tile position if there is one
# And fires off signals that a dot has been eaten
func eat_dot_at(pos):
    if(get_cellv(pos) == PILL_TILE_ID):
        set_cellv(pos, -1)
    if(get_cellv(pos) == PILL_BIG_TILE_ID):
        set_cellv(pos, -1)

# Checks that a tile at a position is a wall
func tile_at_pos_is_wall(pos):
    return tile_id_is_wall(get_cellv(pos))

# Gets a path of Vector3s from grid positions
func get_path_to_from(to, from):
    var to_id   = get_node_id_atv(to)
    var from_id = get_node_id_atv(from)
    return astar.get_point_path(from_id, to_id)

# "Private" methods
func _ready():
    #set_process_input(true)
    make_walls_tile_aware()
    generate_path_nodes()
    set_spawn_position()

func _input(event):
    if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == 1 and event.is_pressed() and !event.is_echo()):
        toggle_wall_at(world_to_map_with_offset(event.pos))

func world_to_map_with_offset(pos):
    pos -= get_global_pos()
    return world_to_map(pos)

func toggle_wall_at(pos):
    if tile_id_is_wall(get_cellv(pos)):
        set_cellv(pos, -1)
    else:
        set_cellv(pos, 0)
    make_walls_tile_aware()

func make_walls_tile_aware():
    for cell in get_used_cells():
        if(tile_id_is_wall(get_cellv(cell))):
            var north = tile_id_is_wall(get_cell(cell.x, cell.y - 1))
            var east  = tile_id_is_wall(get_cell(cell.x + 1, cell.y))
            var south = tile_id_is_wall(get_cell(cell.x, cell.y + 1))
            var west  = tile_id_is_wall(get_cell(cell.x - 1, cell.y))

            var tile = north*1 + west*2 + south*4 + east*8
            set_cell(cell.x, cell.y, tile)

func tile_id_is_wall(id):
    return (id >= 0 && id <= 15)

func set_spawn_position():
    for cell in get_used_cells():
        if(get_cellv(cell) == PACMAN_TILE_ID):
            spawn_position = cell
            set_cellv(cell, -1)
            return
    print("No spawn position in map!")
    spawn_position = Vector2(-1, -1)

# Generate the nodes to be places in the AStar class
func generate_path_nodes():

    # Remove any previous pathing data
    astar.clear()

    # Look at every cell and add a node to that position
    for x in range(MAP_WIDTH):
        for y in range(MAP_HEIGHT):
            # The id is the position on the grid the node is
            # This makes it easy and quick to find later when adding neighbours
            var id = (y * MAP_WIDTH) + x

            # Add the world position to hand back when we ask for a path
            var pos = map_to_world(Vector2(x,y))

            # Astar works with Vector3 and we're in 2d, so we'll ignore the Z axis with a 0
            astar.add_point(id, Vector3(pos.x, pos.y, 0))

    # Now connect the nodes neighbours
    for x in range(MAP_WIDTH):
        for y in range(MAP_HEIGHT):
            # Skip this cell if it's a wall, it will have no neighbours
            if(tile_at_pos_is_wall(Vector2(x,y))):
                continue

            # Get the tile id for the current cell
            var cell_id = (y * MAP_WIDTH) + x

            # UP: If we're not on the first row and the tile above is not a wall add as neighbour
            if(y > 0 && !tile_at_pos_is_wall(Vector2(x, y - 1))):
                astar.connect_points(cell_id, get_node_id_at(x, y - 1))

            # DOWN: If we're under MAP_HEIGHT - 1 and the tile below is not a wall add as neighbour
            if(y < MAP_HEIGHT && !tile_at_pos_is_wall(Vector2(x, y + 1))):
                astar.connect_points(cell_id, get_node_id_at(x, y + 1))

            # LEFT: If we're not on the first column and the tile left is not a wall add as neighbour
            if(x > 0 && !tile_at_pos_is_wall(Vector2(x - 1, y))):
                astar.connect_points(cell_id, get_node_id_at(x - 1, y))

            # RIGHT: If we're not on the last column and the tile right is not a wall add as neighbour
            if(x < MAP_WIDTH && !tile_at_pos_is_wall(Vector2(x + 1, y))):
                astar.connect_points(cell_id, get_node_id_at(x + 1, y))

func get_node_id_atv(pos):
    return (pos.y * MAP_WIDTH) + pos.x

func get_node_id_at(x, y):
    return (y * MAP_WIDTH) + x
