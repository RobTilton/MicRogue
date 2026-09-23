
import argparse
import importlib.util
from pathlib import Path


def load_harness(path: Path):
    spec = importlib.util.spec_from_file_location("frontier_harness", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load harness: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


ANSI_RESET = "\033[0m"
ANSI_DIM = "\033[2m"
ANSI_WHITE = "\033[97m"
ANSI_GREEN = "\033[92m"
ANSI_CYAN = "\033[96m"


def color_char(ch):
    # Floor and repair mutations intentionally use the SAME color.
    if ch in (".", "+"):
        return f"{ANSI_GREEN}{ch}{ANSI_RESET}"
    if ch == "#":
        return f"{ANSI_WHITE}{ch}{ANSI_RESET}"
    if ch == "0":
        return f"{ANSI_DIM}{ANSI_CYAN}{ch}{ANSI_RESET}"
    return ch


def render_plain(field):
    lines = []
    for row in field:
        chars = []
        for cell in row:
            if cell == 0:
                chars.append("0")
            elif cell == 1:
                chars.append(".")
            elif cell == 2:
                chars.append("#")
            else:
                chars.append("?")
        lines.append("".join(chars))
    return "\n".join(lines)


def render_with_mutations(original, variant, use_color=False):
    """
    0 -> 0
    1 -> .
    2 -> #
    Any cell changed relative to original -> +

    When use_color=True:
      . and + use the SAME color
      # uses bright white
      0 is dim cyan
    """
    lines = []

    for y, row in enumerate(variant):
        chars = []

        for x, cell in enumerate(row):
            if cell != original[y][x]:
                ch = "+"
            elif cell == 0:
                ch = "0"
            elif cell == 1:
                ch = "."
            elif cell == 2:
                ch = "#"
            else:
                ch = "?"

            chars.append(color_char(ch) if use_color else ch)

        lines.append("".join(chars))

    return "\n".join(lines)


def render_colored_field(field):
    lines = []
    for line in render_plain(field).splitlines():
        lines.append("".join(color_char(ch) for ch in line))
    return "\n".join(lines)


def print_analysis(label, analysis, mutation=None):
    print(label)
    print("-" * len(label))
    print(f"Regions:                {analysis['region_count']}")
    print(f"Largest region:         {analysis['largest_region_percent']:.2f}%")
    print(f"Floor cells:             {analysis['floor_count']}")
    print(f"Wall cells:              {analysis['wall_count']}")
    print(f"Untouched cells:         {analysis['untouched_count']}")
    print(f"Isolated regions (<10):  {analysis['isolated_regions']}")

    if mutation is not None:
        print(f"Stamps:                  {mutation['stamps']}")
        print(f"Mutated cells:           {mutation['mutated_cells']}")
        print(f"Regions w/ candidate:    {mutation['regions_with_candidate']}")
        print(f"Regions w/o candidate:   {mutation['regions_without_candidate']}")

    print()


def main():
    parser = argparse.ArgumentParser(
        description="Inspect one frontier-generator seed as RAW vs CROSS vs DESTINY."
    )
    parser.add_argument(
        "seed",
        nargs="?",
        type=int,
        default=4434,
        help="Seed to inspect (default: 4434)",
    )
    parser.add_argument(
        "--harness",
        default="frontier_harness(2).py",
        help="Path to the original abuse-test harness",
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Optional plain-text file to write instead of stdout",
    )
    parser.add_argument(
        "--color",
        action="store_true",
        help="Use ANSI colors in terminal output. Floor '.' and repair '+' share one color.",
    )
    args = parser.parse_args()

    harness = load_harness(Path(args.harness))

    raw = harness.generate_dungeon(args.seed)

    cross, cross_mutation = harness.repair_with_shape(
        raw,
        harness.CROSS_SHAPE,
    )
    destiny, destiny_mutation = harness.repair_with_shape(
        raw,
        harness.DESTINY_SHAPE,
    )

    raw_analysis = harness.analyze_field(raw)
    cross_analysis = harness.analyze_field(cross)
    destiny_analysis = harness.analyze_field(destiny)

    chunks = []
    chunks.append("=" * 72)
    chunks.append(f"FRONTIER SINGLE-SEED VISUAL INSPECTION — SEED {args.seed}")
    chunks.append("=" * 72)
    chunks.append("")
    chunks.append("Legend: 0 = untouched void, # = wall, . = floor, + = repair mutation")
    chunks.append("RAW/CROSS/DESTINY all derive from the exact same generated field.")
    chunks.append("")

    def analysis_text(label, analysis, mutation=None):
        lines = [
            label,
            "-" * len(label),
            f"Regions:                {analysis['region_count']}",
            f"Largest region:         {analysis['largest_region_percent']:.2f}%",
            f"Floor cells:             {analysis['floor_count']}",
            f"Wall cells:              {analysis['wall_count']}",
            f"Untouched cells:         {analysis['untouched_count']}",
            f"Isolated regions (<10):  {analysis['isolated_regions']}",
        ]
        if mutation is not None:
            lines.extend([
                f"Stamps:                  {mutation['stamps']}",
                f"Mutated cells:           {mutation['mutated_cells']}",
                f"Regions w/ candidate:    {mutation['regions_with_candidate']}",
                f"Regions w/o candidate:   {mutation['regions_without_candidate']}",
            ])
        return "\n".join(lines)

    chunks.append(analysis_text("RAW ANALYSIS", raw_analysis))
    chunks.append("")
    chunks.append(analysis_text("CROSS ANALYSIS", cross_analysis, cross_mutation))
    chunks.append("")
    chunks.append(analysis_text("DESTINY ANALYSIS", destiny_analysis, destiny_mutation))
    chunks.append("")

    chunks.append("=" * harness.WIDTH)
    chunks.append("RAW")
    chunks.append("=" * harness.WIDTH)
    chunks.append(render_colored_field(raw) if args.color else harness.field_to_text(raw))
    chunks.append("")

    chunks.append("=" * harness.WIDTH)
    chunks.append("CROSS — changed cells marked +")
    chunks.append("=" * harness.WIDTH)
    chunks.append(render_with_mutations(raw, cross, use_color=args.color))
    chunks.append("")

    chunks.append("=" * harness.WIDTH)
    chunks.append("DESTINY — changed cells marked +")
    chunks.append("=" * harness.WIDTH)
    chunks.append(render_with_mutations(raw, destiny, use_color=args.color))
    chunks.append("")

    text = "\n".join(chunks)

    if args.output:
        Path(args.output).write_text(text, encoding="utf-8")
        print(f"Wrote: {args.output}")
        if args.color:
            print("Note: ANSI escape codes were written to the file.")
    else:
        print(text)


if __name__ == "__main__":
    main()
