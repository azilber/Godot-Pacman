
extends Sprite

onready var tilemap = get_parent()

var speed = 100
var current_path = []

func _ready():
    set_process(true)
    #set_process_input(true)

func _input(event):
    if event.type == InputEvent.MOUSE_BUTTON and event.button_index == 1 and event.is_pressed() and !event.is_echo():
        var clicked_tile = tilemap.world_to_map_with_offset(event.pos)
        var ghost_tile   = tilemap.world_to_map(get_pos())
        current_path = tilemap.get_path_to_from(clicked_tile, ghost_tile)

    if event.type == InputEvent.MOUSE_BUTTON and event.button_index == 2 and event.is_pressed() and !event.is_echo():
        set_pos(event.pos - tilemap.get_pos())
        current_path = []

func _process(delta):
    #handle_movement_to_a_path(delta)
    handle_movement_random(delta)
    update() #Debug

# Draws current_path to the screen (for debugging pathfinding)
func _draw():
    for pos in current_path:
        draw_circle(Vector2(pos.x, pos.y) + Vector2(8, 8) - get_pos() , 3, Color(1, 0, 0, 1))

# Handles the movement of ghost
func handle_movement_to_a_path(delta):
    if current_path.size() <= 0:
        return

    var target_pos = Vector2(current_path[0].x, current_path[0].y)

    # If we're not at our direction yet (or we just got a new one) move towards it
    var move_direction = (target_pos - get_pos()).normalized()
    set_pos(get_pos() + (move_direction * speed * delta))

    if get_pos().distance_to(target_pos) < 1:
        set_pos(target_pos)
        current_path.remove(0)

# Handles the movement of ghost randomly
# Ghost checks every time he moves a tile in which directions he can move
# Then picks one that isn't the way he came unless it's a dead end
# Uses current_path to store where to move
func handle_movement_random(delta):
    if current_path.size() <= 0:
        # If there is no path get a random moveable direction and set it as the current_path 
        current_path.append(get_random_moveable_direction())
        return

    # We already have a method to move along a path so call that
    handle_movement_to_a_path(delta)

# Gets a random position for the ghost to move
# Takes into account direction ghost came and will only move that direction 
# if no other directions are available 
func get_random_moveable_direction():
    # Get the current position of the ghost
    var current_pos = tilemap.world_to_map(get_pos())

    # Get all 4 directions a ghost can move relative from the current position
    # For left we check -1 tile to the left on the x axis and y stays the same 
    var left  = Vector2(current_pos.x - 1, current_pos.y)
    var right = Vector2(current_pos.x + 1, current_pos.y)
    var up    = Vector2(current_pos.x, current_pos.y - 1)
    var down  = Vector2(current_pos.x, current_pos.y + 1)

    # Open an array to store the directions the ghost can move into
    var moveable_positions = []

    # Check against the directions
    for dir in [left, right, up, down]:
        # If any of the directions are NOT a wall we add them to the moveable_positions array
        if not tilemap.tile_at_pos_is_wall(dir):            
            moveable_positions.append(dir)
    
    # If there are no moveable_positions something has gone wrong
    # Instead of crashing by returning moveable_positions[0] which wont exist we return our current position
    # Effectively making the ghost stand still
    # Also cry about it in the output
    if moveable_positions.size() == 0:
        print("ERROR: No moveable path for ghost")
        return get_pos()
    
    # However, if there are positions available to move into randomly get one from the array
    var rand = randi() % moveable_positions.size()

    # Then return that position as a world vector
    return tilemap.map_to_world(moveable_positions[rand])