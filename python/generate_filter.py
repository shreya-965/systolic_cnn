import numpy as np
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATASET = ROOT / "dataset"

np.random.seed(42)

filters = np.random.randint(-3, 4, size=(3, 3, 3, 4), dtype=np.int8)

np.save(DATASET / "filter_int8.npy", filters)

with open(DATASET / "filter.hex", "w") as f:
    for filter_idx in range(4):
        for kr in range(3):
            for kc in range(3):
                for ch in range(3):
                    value = int(filters[kr, kc, ch, filter_idx])
                    f.write(f"{value & 0xFF:02X}\n")

print("Filter shape:", filters.shape)
print("Total weights:", filters.size)
print("Generated:", DATASET / "filter_int8.npy")
print("Generated:", DATASET / "filter.hex")