
extends Sprite

onready var tilemap = get_parent()

var speed = 100

var current_path = []

func _ready():
    set_process(true)
    set_process_input(true) # debug

func _input(event):
    if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == 1 and event.is_pressed() and !event.is_echo()):
        var clicked_tile = tilemap.world_to_map_with_offset(event.pos)
        var ghost_tile   = tilemap.world_to_map(get_pos())

        print("Path from: " + str(ghost_tile) + " to: " +  str(clicked_tile))

        current_path = tilemap.get_path_to_from(clicked_tile, ghost_tile)
        print(current_path)

    if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == 2 and event.is_pressed() and !event.is_echo()):
        set_pos(event.pos - tilemap.get_pos())
        current_path = []

func _process(delta):
    handle_movement(delta)
    update() #Debug

func _draw():
    for pos in current_path:
        draw_circle(Vector2(pos.x, pos.y) + Vector2(8, 8) - get_pos() , 3, Color(1, 0, 0, 1))


# Handles the movement of ghost
func handle_movement(delta):
    if(current_path.size() <= 0):
        return

    var target_pos = Vector2(current_path[0].x, current_path[0].y)

    # If we're not at our direction yet (or we just got a new one) move towards it
    var move_direction = (target_pos - get_pos()).normalized()
    set_pos(get_pos() + (move_direction * speed * delta))

    if(get_pos().distance_to(target_pos) < 1):
        set_pos(target_pos)
        current_path.remove(0)
