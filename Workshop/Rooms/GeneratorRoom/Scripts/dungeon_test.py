import random as rndm
TOTAL_RUNS = 3
MAX_ATTEMPTS = 40
ROOMS_PER_RUN = 10
ROOM_MIN_WIDTH = 5
ROOM_MAX_WIDTH = 17

ROOM_MIN_HEIGHT = 4
ROOM_MAX_HEIGHT = 14

WIDTH = 60
HEIGHT = 20

def create_field():
    field = []

    for y in range(HEIGHT):
        row = []

        for x in range(WIDTH):
            row.append(False)

        field.append(row)

    return field

def generate_rooms(fields, rooms_to_create, iteration):
    for i in range(rooms_to_create):

        for attempt in range(MAX_ATTEMPTS):
            room_width = rndm.randint(ROOM_MIN_WIDTH, max(ROOM_MIN_WIDTH, ROOM_MAX_WIDTH - iteration))
            room_height = rndm.randint(ROOM_MIN_HEIGHT, max(ROOM_MIN_HEIGHT, ROOM_MAX_HEIGHT - iteration))

            origin_x = rndm.randint(0, WIDTH - room_width)
            origin_y = rndm.randint(0, HEIGHT - room_height)

            if area_is_clear(fields, origin_x, origin_y, room_width, room_height):
                stamp(fields, origin_x, origin_y, room_width, room_height)
                break

def stamp(field, origin_x, origin_y, width, height):
    for y in range(origin_y, origin_y + height):
        for x in range(origin_x, origin_x + width):
            field[y][x] = not field[y][x]

field = create_field()
layers = []

def area_is_clear(field, origin_x, origin_y, width, height):
    for y in range(origin_y, origin_y + height):
        for x in range(origin_x, origin_x + width):
            if field[y][x]:
                return False

    return True

for i in range(TOTAL_RUNS):
    layer = create_field()
    generate_rooms(layer, ROOMS_PER_RUN, i)
    layers.append(layer)

for layer in layers:
    for y, row in enumerate(layer):
        for x, cell in enumerate(row):
            if cell:
                field[y][x] = not field[y][x]

def print_field(field):
    for row in field:
        for cell in row:
            if cell:
                print(".", end="")
            else:
                print("#", end="")
        print()

print_field(field)