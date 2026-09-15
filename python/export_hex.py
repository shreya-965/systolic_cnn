import numpy as np

image = np.load("../dataset/image_float.npy")
filter_data = np.load("../dataset/filter_int8.npy")
expected = np.load("../dataset/expected_int32.npy")

def write_hex(filename, data, width):
    with open(filename, "w") as f:
        for value in data.reshape(-1):
            f.write(f"{int(value) & ((1 << width) - 1):0{width // 4}X}\n")

write_hex("../dataset/image.hex", image, 8)
write_hex("../dataset/filter.hex", filter_data, 8)
write_hex("../dataset/expected.hex", expected, 32)

print("Files regenerated")