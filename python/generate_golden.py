import numpy as np

image = np.load("../dataset/image_float.npy").astype(np.int32)
filter_data = np.load("../dataset/filter_int8.npy").astype(np.int32)

output = np.zeros((30, 30), dtype=np.int32)

for row in range(30):
    for col in range(30):
        for kr in range(3):
            for kc in range(3):
                for ch in range(3):
                    output[row, col] += image[row + kr, col + kc, ch] * filter_data[kr, kc, ch]

np.save("../dataset/expected_int32.npy", output)

print("Image shape:", image.shape)
print("Filter shape:", filter_data.shape)
print("Output shape:", output.shape)
print("Output range:", output.min(), "to", output.max())
print("First 5x5 output:")
print(output[:5, :5])