import random as rndm
import csv
from collections import deque


# ============================================================
# TEST CONFIGURATION
# ============================================================

TOTAL_SEEDS = 10_000

WIDTH = 121
HEIGHT = 41

ROOMS_PER_RUN = 100

ROOM_MIN_RADIUS_X = 5
ROOM_MAX_RADIUS_X = 15

ROOM_MIN_RADIUS_Y = 5
ROOM_MAX_RADIUS_Y = 15

RESULTS_FILE = "frontier_results.csv"
WORST_FILE = "frontier_worst_seeds.txt"

WORST_SEEDS_TO_SAVE = 25

CROSS_SHAPE = [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)]
DESTINY_SHAPE = [
    (dx, dy)
    for dy in range(-1, 2)
    for dx in range(-1, 2)
]


# ============================================================
# FIELD
# ============================================================

def create_field():
    field = []

    for y in range(HEIGHT):
        row = []

        for x in range(WIDTH):
            row.append(0)

        field.append(row)

    return field


# ============================================================
# FRONTIER PRIMITIVE
# ============================================================

def generate_room(field, origin_x, origin_y, radius_x, radius_y):
    for y in range(origin_y - radius_y, origin_y + radius_y + 1):
        for x in range(origin_x - radius_x, origin_x + radius_x + 1):

            distance_x = abs(x - origin_x)
            distance_y = abs(y - origin_y)

            if distance_x == radius_x or distance_y == radius_y:
                field[y][x] = 2
            else:
                field[y][x] = 1


def generate_random_room(field, iteration):
    max_radius_x = max(
        ROOM_MIN_RADIUS_X,
        ROOM_MAX_RADIUS_X - iteration
    )

    max_radius_y = max(
        ROOM_MIN_RADIUS_Y,
        ROOM_MAX_RADIUS_Y - iteration
    )

    radius_x = rndm.randint(
        ROOM_MIN_RADIUS_X,
        max_radius_x
    )

    radius_y = rndm.randint(
        ROOM_MIN_RADIUS_Y,
        max_radius_y
    )

    origin_x = rndm.randint(
        radius_x,
        WIDTH - radius_x - 1
    )

    origin_y = rndm.randint(
        radius_y,
        HEIGHT - radius_y - 1
    )

    generate_room(
        field,
        origin_x,
        origin_y,
        radius_x,
        radius_y
    )


def generate_dungeon(seed):
    rndm.seed(seed)

    field = create_field()

    for iteration in range(ROOMS_PER_RUN):
        generate_random_room(field, iteration)

    return field


# ============================================================
# CONNECTIVITY ANALYSIS
# ============================================================

def find_floor_regions(field):
    visited = set()
    regions = []

    for y in range(HEIGHT):
        for x in range(WIDTH):

            if field[y][x] != 1:
                continue

            if (x, y) in visited:
                continue

            region = flood_fill(
                field,
                x,
                y,
                visited
            )

            regions.append(region)

    return regions


def flood_fill(field, start_x, start_y, visited):
    region = []
    queue = deque()

    queue.append((start_x, start_y))
    visited.add((start_x, start_y))

    while queue:
        x, y = queue.popleft()

        region.append((x, y))

        neighbors = [
            (x + 1, y),
            (x - 1, y),
            (x, y + 1),
            (x, y - 1),
        ]

        for neighbor_x, neighbor_y in neighbors:

            if neighbor_x < 0 or neighbor_x >= WIDTH:
                continue

            if neighbor_y < 0 or neighbor_y >= HEIGHT:
                continue

            if field[neighbor_y][neighbor_x] != 1:
                continue

            if (neighbor_x, neighbor_y) in visited:
                continue

            visited.add((neighbor_x, neighbor_y))
            queue.append((neighbor_x, neighbor_y))

    return region


# ============================================================
# CRUDE CONNECTIVITY MUTATIONS
# ============================================================

def copy_field(field):
    return [row[:] for row in field]


def build_region_labels(field, regions):
    labels = [[-1 for _ in range(WIDTH)] for _ in range(HEIGHT)]

    for region_id, region in enumerate(regions):
        for x, y in region:
            labels[y][x] = region_id

    return labels


def cardinal_neighbors(x, y):
    return [
        (x + 1, y),
        (x - 1, y),
        (x, y + 1),
        (x, y - 1),
    ]


def region_frontier_walls(field, region):
    walls = set()

    for x, y in region:
        for neighbor_x, neighbor_y in cardinal_neighbors(x, y):
            if neighbor_x < 0 or neighbor_x >= WIDTH:
                continue
            if neighbor_y < 0 or neighbor_y >= HEIGHT:
                continue
            if field[neighbor_y][neighbor_x] == 2:
                walls.add((neighbor_x, neighbor_y))

    return walls


def regions_touched_by_stamp(labels, center_x, center_y, shape):
    touched = set()
    stamp_cells = []

    for dx, dy in shape:
        x = center_x + dx
        y = center_y + dy

        if x < 0 or x >= WIDTH:
            continue
        if y < 0 or y >= HEIGHT:
            continue

        stamp_cells.append((x, y))

    for x, y in stamp_cells:
        region_id = labels[y][x]
        if region_id != -1:
            touched.add(region_id)

        for neighbor_x, neighbor_y in cardinal_neighbors(x, y):
            if neighbor_x < 0 or neighbor_x >= WIDTH:
                continue
            if neighbor_y < 0 or neighbor_y >= HEIGHT:
                continue

            region_id = labels[neighbor_y][neighbor_x]
            if region_id != -1:
                touched.add(region_id)

    return touched


def choose_stamp_for_region(field, labels, region_id, region, shape):
    best = None

    for center_x, center_y in region_frontier_walls(field, region):
        touched = regions_touched_by_stamp(
            labels,
            center_x,
            center_y,
            shape
        )

        # A door stamp only counts if it can join this region to
        # at least one OTHER original floor region.
        if region_id not in touched or len(touched) < 2:
            continue

        destroyed = 0
        void_destroyed = 0

        for dx, dy in shape:
            x = center_x + dx
            y = center_y + dy

            if x < 0 or x >= WIDTH:
                continue
            if y < 0 or y >= HEIGHT:
                continue

            if field[y][x] != 1:
                destroyed += 1

            if field[y][x] == 0:
                void_destroyed += 1

        score = (
            -len(touched),
            void_destroyed,
            destroyed,
            center_y,
            center_x,
        )

        if best is None or score < best[0]:
            best = (score, center_x, center_y, touched)

    return best


def apply_stamp(field, center_x, center_y, shape):
    mutated = 0

    for dx, dy in shape:
        x = center_x + dx
        y = center_y + dy

        if x < 0 or x >= WIDTH:
            continue
        if y < 0 or y >= HEIGHT:
            continue

        if field[y][x] != 1:
            mutated += 1
            field[y][x] = 1

    return mutated


def repair_with_shape(field, shape):
    repaired = copy_field(field)
    original_regions = find_floor_regions(field)
    labels = build_region_labels(field, original_regions)

    chosen_centers = set()
    stamps = 0
    mutated_cells = 0
    regions_with_candidate = 0

    for region_id, region in enumerate(original_regions):
        choice = choose_stamp_for_region(
            field,
            labels,
            region_id,
            region,
            shape
        )

        if choice is None:
            continue

        regions_with_candidate += 1
        _, center_x, center_y, _ = choice

        # Two neighboring regions may independently choose the same breach.
        # Apply it once.
        if (center_x, center_y) in chosen_centers:
            continue

        chosen_centers.add((center_x, center_y))
        stamps += 1
        mutated_cells += apply_stamp(
            repaired,
            center_x,
            center_y,
            shape
        )

    return repaired, {
        "stamps": stamps,
        "mutated_cells": mutated_cells,
        "regions_with_candidate": regions_with_candidate,
        "regions_without_candidate": (
            len(original_regions) - regions_with_candidate
        ),
    }


# ============================================================
# MAP ANALYSIS
# ============================================================

def analyze_field(field):
    floor_count = 0
    wall_count = 0
    untouched_count = 0

    for row in field:
        for cell in row:

            if cell == 0:
                untouched_count += 1

            elif cell == 1:
                floor_count += 1

            elif cell == 2:
                wall_count += 1

    regions = find_floor_regions(field)

    region_sizes = []

    for region in regions:
        region_sizes.append(len(region))

    if region_sizes:
        largest_region = max(region_sizes)
        smallest_region = min(region_sizes)
    else:
        largest_region = 0
        smallest_region = 0

    if floor_count > 0:
        largest_region_percent = (
            largest_region / floor_count
        ) * 100
    else:
        largest_region_percent = 0.0

    isolated_regions = 0

    for size in region_sizes:
        if size < 10:
            isolated_regions += 1

    return {
        "floor_count": floor_count,
        "wall_count": wall_count,
        "untouched_count": untouched_count,
        "region_count": len(regions),
        "largest_region": largest_region,
        "largest_region_percent": largest_region_percent,
        "smallest_region": smallest_region,
        "isolated_regions": isolated_regions,
    }


# ============================================================
# ASCII OUTPUT
# ============================================================

def field_to_text(field):
    lines = []

    for row in field:
        line = ""

        for cell in row:

            if cell == 0:
                line += "0"

            elif cell == 1:
                line += "."

            elif cell == 2:
                line += "#"

        lines.append(line)

    return "\n".join(lines)


# ============================================================
# TEST HARNESS
# ============================================================

def run_tests():
    results = []

    print("FRONTIER GENERATOR ABUSE TEST")
    print("=============================")
    print(f"Seeds: {TOTAL_SEEDS}")
    print(f"Field: {WIDTH} x {HEIGHT}")
    print(f"Rooms per seed: {ROOMS_PER_RUN}")
    print()

    for seed in range(TOTAL_SEEDS):

        field = generate_dungeon(seed)

        analysis = analyze_field(field)

        cross_field, cross_mutation = repair_with_shape(
            field,
            CROSS_SHAPE
        )
        cross_analysis = analyze_field(cross_field)

        destiny_field, destiny_mutation = repair_with_shape(
            field,
            DESTINY_SHAPE
        )
        destiny_analysis = analyze_field(destiny_field)

        result = {
            "seed": seed,
            **analysis,
            "cross_regions": cross_analysis["region_count"],
            "cross_stamps": cross_mutation["stamps"],
            "cross_mutated_cells": cross_mutation["mutated_cells"],
            "cross_regions_with_candidate": cross_mutation["regions_with_candidate"],
            "cross_regions_without_candidate": cross_mutation["regions_without_candidate"],
            "destiny_regions": destiny_analysis["region_count"],
            "destiny_stamps": destiny_mutation["stamps"],
            "destiny_mutated_cells": destiny_mutation["mutated_cells"],
            "destiny_regions_with_candidate": destiny_mutation["regions_with_candidate"],
            "destiny_regions_without_candidate": destiny_mutation["regions_without_candidate"],
        }

        results.append(result)

        if (seed + 1) % 1000 == 0:
            print(
                f"Completed {seed + 1:,} / "
                f"{TOTAL_SEEDS:,}"
            )

    write_csv(results)
    write_worst_seeds(results)

    print_summary(results)


# ============================================================
# FILE OUTPUT
# ============================================================

def write_csv(results):
    fieldnames = [
        "seed",
        "floor_count",
        "wall_count",
        "untouched_count",
        "region_count",
        "largest_region",
        "largest_region_percent",
        "smallest_region",
        "isolated_regions",
        "cross_regions",
        "cross_stamps",
        "cross_mutated_cells",
        "cross_regions_with_candidate",
        "cross_regions_without_candidate",
        "destiny_regions",
        "destiny_stamps",
        "destiny_mutated_cells",
        "destiny_regions_with_candidate",
        "destiny_regions_without_candidate",
    ]

    with open(
        RESULTS_FILE,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames
        )

        writer.writeheader()
        writer.writerows(results)


def write_worst_seeds(results):
    ranked = sorted(
        results,
        key=lambda result: (
            result["largest_region_percent"],
            -result["region_count"]
        )
    )

    worst = ranked[:WORST_SEEDS_TO_SAVE]

    with open(
        WORST_FILE,
        "w",
        encoding="utf-8"
    ) as file:

        for result in worst:

            seed = result["seed"]

            field = generate_dungeon(seed)

            file.write("=" * WIDTH)
            file.write("\n")

            file.write(
                f"SEED: {seed}\n"
            )

            file.write(
                f"REGIONS: "
                f"{result['region_count']}\n"
            )

            file.write(
                f"LARGEST REGION: "
                f"{result['largest_region_percent']:.2f}%\n"
            )

            file.write(
                f"SMALLEST REGION: "
                f"{result['smallest_region']}\n"
            )

            file.write(
                f"ISOLATED REGIONS (<10): "
                f"{result['isolated_regions']}\n"
            )

            file.write("\n")

            file.write(
                field_to_text(field)
            )

            file.write("\n\n")


# ============================================================
# SUMMARY
# ============================================================

def print_summary(results):
    total = len(results)

    average_regions = sum(
        result["region_count"] for result in results
    ) / total

    average_cross_regions = sum(
        result["cross_regions"] for result in results
    ) / total

    average_destiny_regions = sum(
        result["destiny_regions"] for result in results
    ) / total

    average_cross_stamps = sum(
        result["cross_stamps"] for result in results
    ) / total

    average_destiny_stamps = sum(
        result["destiny_stamps"] for result in results
    ) / total

    average_cross_mutated = sum(
        result["cross_mutated_cells"] for result in results
    ) / total

    average_destiny_mutated = sum(
        result["destiny_mutated_cells"] for result in results
    ) / total

    average_cross_without_candidate = sum(
        result["cross_regions_without_candidate"] for result in results
    ) / total

    average_destiny_without_candidate = sum(
        result["destiny_regions_without_candidate"] for result in results
    ) / total

    cross_fully_connected = sum(
        1 for result in results
        if result["cross_regions"] == 1
    )

    destiny_fully_connected = sum(
        1 for result in results
        if result["destiny_regions"] == 1
    )

    cross_regions_removed = average_regions - average_cross_regions
    destiny_regions_removed = average_regions - average_destiny_regions

    cross_efficiency = (
        cross_regions_removed / average_cross_mutated
        if average_cross_mutated > 0
        else 0.0
    )

    destiny_efficiency = (
        destiny_regions_removed / average_destiny_mutated
        if average_destiny_mutated > 0
        else 0.0
    )

    print()
    print("===============================================")
    print("CRUDE CONNECTIVITY A/B RESULTS")
    print("===============================================")
    print(f"Seeds tested: {total:,}")
    print(f"Average baseline regions: {average_regions:.2f}")
    print()

    print("CARDINAL CROSS")
    print("--------------")
    print(f"Average regions after repair: {average_cross_regions:.2f}")
    print(f"Average regions removed: {cross_regions_removed:.2f}")
    print(f"Average stamps used: {average_cross_stamps:.2f}")
    print(f"Average cells mutated: {average_cross_mutated:.2f}")
    print(
        "Average original regions with NO local candidate: "
        f"{average_cross_without_candidate:.2f}"
    )
    print(
        f"Fully connected after repair: {cross_fully_connected:,} / "
        f"{total:,} ({cross_fully_connected / total * 100:.2f}%)"
    )
    print(
        "Regions removed per mutated cell: "
        f"{cross_efficiency:.4f}"
    )
    print()

    print("3x3 STAMP OF DESTINY")
    print("--------------------")
    print(f"Average regions after repair: {average_destiny_regions:.2f}")
    print(f"Average regions removed: {destiny_regions_removed:.2f}")
    print(f"Average stamps used: {average_destiny_stamps:.2f}")
    print(f"Average cells mutated: {average_destiny_mutated:.2f}")
    print(
        "Average original regions with NO local candidate: "
        f"{average_destiny_without_candidate:.2f}"
    )
    print(
        f"Fully connected after repair: {destiny_fully_connected:,} / "
        f"{total:,} ({destiny_fully_connected / total * 100:.2f}%)"
    )
    print(
        "Regions removed per mutated cell: "
        f"{destiny_efficiency:.4f}"
    )
    print()
    print(f"CSV written to: {RESULTS_FILE}")
    print(f"Worst maps written to: {WORST_FILE}")


# ============================================================
# GO
# ============================================================

if __name__ == "__main__":
    run_tests()