import numpy as np
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATASET = ROOT / "dataset"

image = np.load(DATASET / "image_float.npy").astype(np.int32)
filters = np.load(DATASET / "filter_int8.npy").astype(np.int32)

expected = np.zeros((30, 30, 4), dtype=np.int32)

for row in range(30):
    for col in range(30):
        for f in range(4):
            acc = np.int32(0)

            for kr in range(3):
                for kc in range(3):
                    for ch in range(3):
                        acc += image[row + kr, col + kc, ch] * filters[kr, kc, ch, f]

            expected[row, col, f] = acc

np.save(DATASET / "expected_int32.npy", expected)

with open(DATASET / "expected.hex", "w") as file:
    for row in range(30):
        for col in range(30):
            for f in range(4):
                value = int(expected[row, col, f])
                file.write(f"{value & 0xFFFFFFFF:08X}\n")

print("Image shape:", image.shape)
print("Filter shape:", filters.shape)
print("Expected shape:", expected.shape)
print("Expected outputs:", expected.size)
print("Output range:", expected.min(), "to", expected.max())
print("Generated:", DATASET / "expected_int32.npy")
print("Generated:", DATASET / "expected.hex")