import random
import math

# ------------------------------------------------------------
# Weighted Shape-Walk Cave Prototype
# ------------------------------------------------------------
# Idea:
#   1. Start with a solid wall field.
#   2. Stamp rounded blobs ("chambers").
#   3. Each new blob rolls its own radius BEFORE placement.
#   4. Center spacing is derived from BOTH blob radii so there is
#      exactly one wall cell between their floor footprints.
#   5. Direction choice is weighted against immediate backtracking.
#   6. Punch the one-wall membranes between consecutive blobs.
#
# This is intentionally tiny and stupid. We are testing SHAPE,
# not building production architecture.
# ------------------------------------------------------------

WIDTH = 60
HEIGHT = 30

SEED = random.randint(0, 2**32 - 1)
STEPS = 12              # number of blobs
MIN_RADIUS = 3          # radius 2 => about a 5x5 rounded blob
MAX_RADIUS = 5
WALL_GAP = -1    # desired number of wall cells between blobs
MAX_PLACE_ATTEMPTS = 50

# Edge roughening. 0.0 disables it.
EDGE_NOISE_CHANCE = 0.3

# Direction weighting relative to previous movement:
# forward, left, right, reverse
DIR_WEIGHTS = (6.0, 3.0, 3.0, 0.35)

rng = random.Random(SEED)

DIRS = [
    (0, -1),   # north
    (1, -1),
    (1, 0),    # east
    (1, 1),
    (0, 1),    # south
    (-1, 1),
    (-1, 0),   # west
    (-1, -1)
]

grid = [["#" for _ in range(WIDTH)] for _ in range(HEIGHT)]


def in_bounds(x, y):
    return 0 <= x < WIDTH and 0 <= y < HEIGHT


def circle_cells(cx, cy, radius):
    """
    Rounded stamp.
    Radius 2 produces:
      . . .
     . . . . .
     . . . . .
     . . . . .
      . . .
    approximately, depending on discrete circle geometry.
    """
    cells = set()
    r2 = radius * radius

    for y in range(cy - radius, cy + radius + 1):
        for x in range(cx - radius, cx + radius + 1):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r2:
                cells.add((x, y))

    return cells


def cells_fit_board(cells, margin=1):
    # Keep at least one permanent wall cell at the map edge.
    for x, y in cells:
        if x < margin or y < margin or x >= WIDTH - margin or y >= HEIGHT - margin:
            return False
    return True


def orthogonal_neighbors(x, y):
    for dx, dy in DIRS:
        yield x + dx, y + dy


def valid_against_existing(candidate, occupied):
    """
    Candidate may not overlap existing floor and may not touch it
    orthogonally. That guarantees at least one wall cell remains
    between separate blobs before connection punching.
    """
    """if candidate & occupied:
        return False

    for x, y in candidate:
        for nx, ny in orthogonal_neighbors(x, y):
            if (nx, ny) in occupied:
                return False
"""
    return True


def relative_direction_choices(last_dir_index):
    if last_dir_index is None:
        return list(range(4)), [1, 1, 1, 1]

    forward = last_dir_index
    right = (last_dir_index + 1) % 4
    reverse = (last_dir_index + 2) % 4
    left = (last_dir_index - 1) % 4

    fw, lw, rw, bw = DIR_WEIGHTS
    return [forward, left, right, reverse], [fw, lw, rw, bw]


def choose_direction(last_dir_index):
    choices, weights = relative_direction_choices(last_dir_index)
    return rng.choices(choices, weights=weights, k=1)[0]


def stamp(cells, char="."):
    for x, y in cells:
        if in_bounds(x, y):
            grid[y][x] = char


def print_grid(title):
    print()
    print(title)
    print("=" * len(title))
    for row in grid:
        print("".join(row))


def roughen_edges(all_blob_cells):
    """
    Tiny visual experiment:
    randomly shave some exposed floor boundary cells back to wall.
    We avoid cells with <=1 floor neighbor so we don't aggressively
    destroy thin pieces.
    """
    all_floor = set().union(*all_blob_cells)

    shave = set()

    for x, y in list(all_floor):
        neighbor_count = sum((nx, ny) in all_floor for nx, ny in orthogonal_neighbors(x, y))

        # exposed-ish boundary cell
        if neighbor_count in (2, 3) and rng.random() < EDGE_NOISE_CHANCE:
            shave.add((x, y))

    for x, y in shave:
        grid[y][x] = "#"


def punch_between(a, b):
    """
    Consecutive centers are placed cardinally.
    Walk the straight line between them and carve wall membrane cells.
    Existing blob floor stays floor.
    """
    ax, ay = a
    bx, by = b

    dx = 0 if ax == bx else (1 if bx > ax else -1)
    dy = 0 if ay == by else (1 if by > ay else -1)

    x, y = ax, ay

    while (x, y) != (bx, by):
        x += dx
        y += dy
        if grid[y][x] == "#":
            grid[y][x] = "."


# ------------------------------------------------------------
# GENERATE
# ------------------------------------------------------------

blobs = []
centers = []
radii = []
occupied = set()

# Start near center.
cx = WIDTH // 2
cy = HEIGHT // 2
radius = rng.randint(MIN_RADIUS, MAX_RADIUS)

first = circle_cells(cx, cy, radius)
blobs.append(first)
centers.append((cx, cy))
radii.append(radius)
occupied |= first

last_dir = None

for step in range(1, STEPS):
    previous_center = centers[-1]
    previous_radius = radii[-1]

    placed = False

    # IMPORTANT:
    # Roll the next blob radius BEFORE placement.
    next_radius = rng.randint(MIN_RADIUS, MAX_RADIUS)

    for _ in range(MAX_PLACE_ATTEMPTS):
        dir_index = choose_direction(last_dir)
        dx, dy = DIRS[dir_index]

        # For discrete radius-r circles aligned on a cardinal axis:
        #
        # floor edge A -> WALL_GAP wall cells -> floor edge B
        #
        # center spacing = rA + rB + WALL_GAP + 1
        #
        # Example rA=2, rB=2, gap=1:
        # centers are 6 cells apart:
        # ... floor | # | floor ...
        spacing = previous_radius + next_radius + WALL_GAP + 1

        nx = previous_center[0] + dx * spacing
        ny = previous_center[1] + dy * spacing

        candidate = circle_cells(nx, ny, next_radius)

        if not cells_fit_board(candidate, margin=1):
            continue

        if not valid_against_existing(candidate, occupied):
            continue

        blobs.append(candidate)
        centers.append((nx, ny))
        radii.append(next_radius)
        occupied |= candidate
        last_dir = dir_index
        placed = True
        break

    if not placed:
        print(f"Stopped early at blob {step + 1}: no legal placement found.")
        break


# Stamp raw separated blobs.
for blob in blobs:
    stamp(blob, ".")

print_grid("RAW BLOBS — one-wall membranes, no punching")

# Optional silhouette noise.
if EDGE_NOISE_CHANCE > 0:
    roughen_edges(blobs)

# Punch consecutive blob connections.
for i in range(len(centers) - 1):
    punch_between(centers[i], centers[i + 1])

print_grid("FINAL CAVE — roughened + punched")

print()
print("Seed:", SEED)
print("Blobs placed:", len(blobs))
print("Centers / radii:")
for i, (center, radius) in enumerate(zip(centers, radii), start=1):
    print(f"  {i:02d}: center={center}, radius={radius}")