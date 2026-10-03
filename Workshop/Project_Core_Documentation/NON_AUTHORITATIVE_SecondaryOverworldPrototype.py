import numpy as np
import matplotlib.pyplot as plt
from collections import deque
from matplotlib.colors import ListedColormap, BoundaryNorm

# Rebuild exact same deterministic world/run.
rng = np.random.default_rng(131)

H = W = 40
grid = np.zeros((H, W), dtype=np.uint8)
grid[19:22, :] = 1

dirs = [
    (-1, 0), (-1, 1), (0, 1), (1, 1),
    (1, 0), (1, -1), (0, -1), (-1, -1),
]

BRANCH_CHANCE = 0.19
STEPS_PER_BRANCH = 10
MAX_BRANCHES = 30
PRE_CA_DECAY = 0.15
CA_CYCLES = 20

def paint3(cy, cx):
    for yy in range(cy - 1, cy + 2):
        for xx in range(cx - 1, cx + 2):
            if 0 <= yy < H and 0 <= xx < W:
                grid[yy, xx] = 1

def move_one(cy, cx, dy, dx):
    if dy == 0 or dx == 0:
        return cy + dy * 2, cx + dx * 2
    return cy + dy, cx + dx

branches = []
queue = deque()

for x0 in range(0, W, 3):
    if rng.random() < BRANCH_CHANCE and len(branches) < MAX_BRANCHES:
        cy = 20
        cx = min(x0 + 1, W - 2)
        dy, dx = dirs[int(rng.integers(0, len(dirs)))]
        branches.append((cy, cx, dy, dx, 0))
        queue.append((cy, cx, dy, dx, 0))

while queue and len(branches) < MAX_BRANCHES:
    cy, cx, dy, dx, depth = queue.popleft()
    for _ in range(STEPS_PER_BRANCH):
        cy, cx = move_one(cy, cx, dy, dx)
        paint3(cy, cx)
        if rng.random() < BRANCH_CHANCE and len(branches) < MAX_BRANCHES:
            ndy, ndx = dirs[int(rng.integers(0, len(dirs)))]
            branches.append((cy, cx, ndy, ndx, depth + 1))
            queue.append((cy, cx, ndy, ndx, depth + 1))

kill = (grid == 1) & (rng.random(grid.shape) < PRE_CA_DECAY)
grid[kill] = 0

def step_b3_s45678(g):
    p = np.pad(g, 1)
    neighbors = (
        p[:-2, :-2] + p[:-2, 1:-1] + p[:-2, 2:]
        + p[1:-1, :-2] + p[1:-1, 2:]
        + p[2:, :-2] + p[2:, 1:-1] + p[2:, 2:]
    )
    born = (g == 0) & (neighbors == 3)
    survive = (g == 1) & (neighbors >= 4)
    return (born | survive).astype(np.uint8)

alive_cycles = np.zeros((H, W), dtype=np.float64)
g = grid.copy()

for _ in range(CA_CYCLES):
    alive_cycles += g
    g = step_b3_s45678(g)

def smooth_history(field):
    out = np.zeros_like(field, dtype=np.float64)
    weights = [
        (-1, -1, 1), (-1,  0, 2), (-1,  1, 1),
        ( 0, -1, 2), ( 0,  0, 4), ( 0,  1, 2),
        ( 1, -1, 1), ( 1,  0, 2), ( 1,  1, 1),
    ]
    for y in range(H):
        for x in range(W):
            total = 0.0
            total_weight = 0.0
            for dy, dx, weight in weights:
                ny, nx = y + dy, x + dx
                if 0 <= ny < H and 0 <= nx < W:
                    total += field[ny, nx] * weight
                    total_weight += weight
            out[y, x] = total / total_weight
    return out

smoothed = smooth_history(alive_cycles)

# Final proposed thresholds:
# 0-1   dark blue
# 2-3   light blue
# 4-7   yellow
# 8-11  lime
# 12-16 verdant green
# 17-18 orange
# 19-20 red
bands = np.zeros((H, W), dtype=np.uint8)
bands[(smoothed >= 0)  & (smoothed < 2)]  = 0
bands[(smoothed >= 2)  & (smoothed < 4)]  = 1
bands[(smoothed >= 4)  & (smoothed < 8)]  = 2
bands[(smoothed >= 8)  & (smoothed < 12)] = 3
bands[(smoothed >= 12) & (smoothed < 17)] = 4
bands[(smoothed >= 17) & (smoothed < 19)] = 5
bands[(smoothed >= 19)] = 6

colors = [
    "#082567",
    "#65B5FF",
    "#FFD84D",
    "#9BFF3D",
    "#168A45",
    "#F28C28",
    "#D62828",
]

cmap = ListedColormap(colors)
norm = BoundaryNorm(np.arange(-0.5, 7.5, 1), cmap.N)

fig, ax = plt.subplots(figsize=(7, 7))
im = ax.imshow(bands, cmap=cmap, norm=norm, interpolation="nearest")

ax.set_title(
    "1-Pass Smoothed Terrain Map\n"
    "0–1, 2–3, 4–7, 8–11, 12–16, 17–18, 19–20"
)

ax.set_xticks(np.arange(-0.5, W, 1), minor=True)
ax.set_yticks(np.arange(-0.5, H, 1), minor=True)
ax.grid(which="minor", linewidth=0.18, alpha=0.35)
ax.set_xticks([])
ax.set_yticks([])

cbar = plt.colorbar(im, ax=ax, ticks=range(7), fraction=0.046, pad=0.04)
cbar.ax.set_yticklabels([
    "0–1",
    "2–3",
    "4–7",
    "8–11",
    "12–16",
    "17–18",
    "19–20",
])

plt.tight_layout()
plt.show()

labels = ["0–1", "2–3", "4–7", "8–11", "12–16", "17–18", "19–20"]
counts = [(bands == i).sum() for i in range(7)]

print("Terrain-band cell counts:")
for label, count in zip(labels, counts):
    print(f"{label}: {int(count)}")


#STDOUT/STDERR

#Terrain-band cell counts:
#0–1: 561
#2–3: 76
#4–7: 124
#8–11: 157
#12–16: 338
#17–18: 234
#19–20: 110