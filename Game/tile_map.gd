extends TileMap


@export var block_spawners : Array[Vector2i]


## We can consider a cell in bounds if the ground floor has a tile
## Ground floor is layer 0
func in_bounds(cell: Vector2i) -> bool:
    return get_cell_source_id(0, cell) != -1


func is_empty(cell: Vector2i) -> bool:
    return get_cell_source_id(1, cell) == -1 \
            && get_cell_source_id(2, cell) == -1


func map_to_global(cell: Vector2i) -> Vector2:
    return to_global(map_to_local(cell))


func block_pickup(target_cell: Vector2i) -> void:
    if block_spawners.has(target_cell):
        return
    
    erase_cell(2, target_cell)