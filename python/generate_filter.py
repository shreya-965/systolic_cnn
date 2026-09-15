import numpy as np

np.random.seed(42)

filter_data = np.random.randint(-3, 4, size=(3, 3, 3), dtype=np.int8)

print("Filter shape:", filter_data.shape)
print(filter_data)

np.save("../dataset/filter_int8.npy", filter_data)