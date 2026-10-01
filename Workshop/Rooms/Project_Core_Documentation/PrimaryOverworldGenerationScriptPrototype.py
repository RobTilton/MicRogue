import numpy as np
import matplotlib.pyplot as plt
from collections import deque

rng = np.random.default_rng(131)

H = W = 40
grid = np.zeros((H, W), dtype=np.uint8)

# Main trunk
grid[19:22, :] = 1

dirs = [
    (-1, 0),   # N
    (-1, 1),   # NE
    (0, 1),    # E
    (1, 1),    # SE
    (1, 0),    # S
    (1, -1),   # SW
    (0, -1),   # W
    (-1, -1),  # NW
]

dir_names = {
    (-1, 0): "N",
    (-1, 1): "NE",
    (0, 1): "E",
    (1, 1): "SE",
    (1, 0): "S",
    (1, -1): "SW",
    (0, -1): "W",
    (-1, -1): "NW",
}

BRANCH_CHANCE = 0.19
STEPS_PER_BRANCH = 10

# Safety cap for recursive branch explosion on this small test board.
MAX_BRANCHES = 30


def paint3(cy, cx):
    """
    Paint a 3x3 block centered on (cy, cx).
    Existing live cells are simply painted alive again.
    """
    for yy in range(cy - 1, cy + 2):
        for xx in range(cx - 1, cx + 2):
            if 0 <= yy < H and 0 <= xx < W:
                grid[yy, xx] = 1


def move_one(cy, cx, dy, dx):
    """
    Cardinal:
        Skip every other cell.
        Move 2 cells per logical branch step.

    Diagonal:
        Move corner-to-corner.
        Move 1 cell per logical branch step.
    """
    if dy == 0 or dx == 0:
        return cy + dy * 2, cx + dx * 2

    return cy + dy, cx + dx


branches = []
queue = deque()

# ---------------------------------------------------------
# INITIAL BRANCHES
# ---------------------------------------------------------
#
# Walk across the horizontal seed in logical 3x3 sections.
# Each section has a 19% chance to spawn a branch.
#

for x0 in range(0, W, 3):

    if (
        rng.random() < BRANCH_CHANCE
        and len(branches) < MAX_BRANCHES
    ):
        origin = (
            20,
            min(x0 + 1, W - 2),
        )

        dy, dx = dirs[
            int(rng.integers(0, len(dirs)))
        ]

        queue.append(
            (
                origin[0],
                origin[1],
                dy,
                dx,
                0,
            )
        )

        branches.append(
            (
                origin[0],
                origin[1],
                dy,
                dx,
                0,
            )
        )


# ---------------------------------------------------------
# RECURSIVE BRANCH WALK
# ---------------------------------------------------------
#
# Every branch:
#
# - gets 10 movement steps
# - paints a 3x3 at every landed location
# - may create child branches
# - ignores collisions
# - continues even when painting already-live cells
#

while queue and len(branches) < MAX_BRANCHES:

    cy, cx, dy, dx, depth = queue.popleft()

    for step in range(STEPS_PER_BRANCH):

        cy, cx = move_one(
            cy,
            cx,
            dy,
            dx,
        )

        paint3(cy, cx)

        # This branch step may spawn another branch.
        if (
            rng.random() < BRANCH_CHANCE
            and len(branches) < MAX_BRANCHES
        ):
            ndy, ndx = dirs[
                int(rng.integers(0, len(dirs)))
            ]

            branches.append(
                (
                    cy,
                    cx,
                    ndy,
                    ndx,
                    depth + 1,
                )
            )

            queue.append(
                (
                    cy,
                    cx,
                    ndy,
                    ndx,
                    depth + 1,
                )
            )


# Preserve raw structural seed for visualization.
seed_before_cull = grid.copy()


# ---------------------------------------------------------
# PRE-CA DECAY
# ---------------------------------------------------------

PRE_CA_DECAY = 0.15

kill = (
    (grid == 1)
    & (rng.random(grid.shape) < PRE_CA_DECAY)
)

grid[kill] = 0


# ---------------------------------------------------------
# CELLULAR AUTOMATA
#
# Rule:
#
# B3 / S45678
#
# Birth:
#     Dead cell becomes alive with exactly 3 neighbors.
#
# Survival:
#     Live cell survives with 4-8 neighbors.
# ---------------------------------------------------------

def step_b3_s45678(g):

    p = np.pad(g, 1)

    neighbors = (
        p[:-2, :-2]
        + p[:-2, 1:-1]
        + p[:-2, 2:]
        + p[1:-1, :-2]
        + p[1:-1, 2:]
        + p[2:, :-2]
        + p[2:, 1:-1]
        + p[2:, 2:]
    )

    born = (
        (g == 0)
        & (neighbors == 3)
    )

    survive = (
        (g == 1)
        & (neighbors >= 4)
    )

    return (
        born | survive
    ).astype(np.uint8)


# ---------------------------------------------------------
# RUN CA
# ---------------------------------------------------------

CA_CYCLES = 6

generations = [grid.copy()]

g = grid.copy()

for _ in range(CA_CYCLES):

    g = step_b3_s45678(g)

    generations.append(
        g.copy()
    )


# ---------------------------------------------------------
# RAW SEED VISUALIZATION
# ---------------------------------------------------------

fig, ax = plt.subplots(
    figsize=(6, 6)
)

ax.imshow(
    seed_before_cull,
    interpolation="nearest",
)

ax.set_title(
    f"Recursive seed — {BRANCH_CHANCE:.0%} branch chance\n"
    f"Branches spawned: {len(branches)}"
)

ax.set_xticks(
    np.arange(-0.5, W, 1),
    minor=True,
)

ax.set_yticks(
    np.arange(-0.5, H, 1),
    minor=True,
)

ax.grid(
    which="minor",
    linewidth=0.25,
)

ax.set_xticks([])
ax.set_yticks([])

plt.tight_layout()
plt.show()


# ---------------------------------------------------------
# CA EVOLUTION VISUALIZATION
# ---------------------------------------------------------

show_generations = [
    0,
    1,
    2,
    3,
    4,
    6,
]

for idx in show_generations:

    fig, ax = plt.subplots(
        figsize=(6, 6)
    )

    ax.imshow(
        generations[idx],
        interpolation="nearest",
    )

    ax.set_title(
        f"{BRANCH_CHANCE:.0%} recursive branches "
        f"+ {PRE_CA_DECAY:.0%} cull "
        f"— Gen {idx}"
    )

    ax.set_xticks(
        np.arange(-0.5, W, 1),
        minor=True,
    )

    ax.set_yticks(
        np.arange(-0.5, H, 1),
        minor=True,
    )

    ax.grid(
        which="minor",
        linewidth=0.25,
    )

    ax.set_xticks([])
    ax.set_yticks([])

    plt.tight_layout()
    plt.show()


# ---------------------------------------------------------
# DEBUG / TEST DATA
# ---------------------------------------------------------

print(
    "Branches spawned:",
    len(branches),
)

print("By depth:")

depths = {}

for _, _, dy, dx, depth in branches:

    depths[depth] = (
        depths.get(depth, 0) + 1
    )

print(depths)


print("First branches:")

for branch in branches[:12]:

    cy, cx, dy, dx, depth = branch

    print(
        f" depth={depth}"
        f" origin=({cy},{cx})"
        f" dir={dir_names[(dy, dx)]}"
    )


print(
    "Live cells:",
    [
        int(x.sum())
        for x in generations
    ],
)