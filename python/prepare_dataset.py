import pickle
import numpy as np
import matplotlib.pyplot as plt

with open("../cifar-10-batches-py/data_batch_1", "rb") as f:
    batch = pickle.load(f, encoding="bytes")

image_index = 0

image_data = batch[b"data"][image_index]
label = int(batch[b"labels"][image_index])

image = image_data.reshape(3, 32, 32)
image = np.transpose(image, (1, 2, 0))

print("Image shape:", image.shape)
print("Label:", label)

plt.imshow(image)
plt.title(f"CIFAR-10 label: {label}")
plt.axis("off")
plt.show()

np.save("../dataset/image_float.npy", image)