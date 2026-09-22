import random as rndm
TOTAL_RUNS = 10
MAX_ATTEMPTS = 40
ROOMS_PER_RUN = 100

ROOM_MIN_RADIUS_X = 4
ROOM_MAX_RADIUS_X = 17

ROOM_MIN_RADIUS_Y = 4
ROOM_MAX_RADIUS_Y = 15

WIDTH = 99
HEIGHT = 66

def generate_random_room(field, iteration):
    radius_x = rndm.randint(ROOM_MIN_RADIUS_X, max(ROOM_MIN_RADIUS_X, ROOM_MAX_RADIUS_X - iteration))
    radius_y = rndm.randint(ROOM_MIN_RADIUS_Y, max(ROOM_MIN_RADIUS_Y, ROOM_MAX_RADIUS_Y - iteration))

    origin_x = rndm.randint(radius_x, WIDTH - radius_x - 1)
    origin_y = rndm.randint(radius_y, HEIGHT - radius_y - 1)

    generate_room(field, origin_x, origin_y, radius_x, radius_y)

def create_field():
    field = []

    for y in range(HEIGHT):
        row = []

        for x in range(WIDTH):
            row.append(0)

        field.append(row)

    return field

def print_field(field):
    for row in field:
        for cell in row:
            if cell == 0:
                print("0", end="")
            elif cell == 1:
                print(".", end="")
            elif cell == 2:
                print("#", end="")
        print()

field = create_field()

origin_x = WIDTH // 2
origin_y = HEIGHT // 2

field[origin_y][origin_x] = 1

radius_x = 2
radius_y = 2


def generate_room(field, origin_x, origin_y, radius_x, radius_y):
    for y in range(origin_y - radius_y, origin_y + radius_y + 1):
        for x in range(origin_x - radius_x, origin_x + radius_x + 1):

            distance_x = abs(x - origin_x)
            distance_y = abs(y - origin_y)

            if distance_x == radius_x or distance_y == radius_y:
                field[y][x] = 2
            else:
                field[y][x] = 1

for i in range(ROOMS_PER_RUN):
    generate_random_room(field, i)

print_field(field)