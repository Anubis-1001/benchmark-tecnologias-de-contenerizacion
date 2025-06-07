import numpy as np

for _ in range(100000):
    a = np.random.rand(1000, 1000)
    b = np.dot(a, a)
