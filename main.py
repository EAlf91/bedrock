from typing import List
import time

import numpy as np

from fastembed import TextEmbedding

embedding_model_cpu = TextEmbedding(
    model_name="BAAI/bge-small-en-v1.5", providers=["CPUExecutionProvider"]
)

embedding_model_gpu = TextEmbedding(
    model_name="BAAI/bge-small-en-v1.5", providers=["CUDAExecutionProvider"]
)
print(embedding_model_gpu.model.model.get_providers())
documents: List[str] = list(np.repeat("Demonstrating GPU acceleration in fastembed", 500))

def embed_gpu():
    for e in embedding_model_gpu.embed(documents):
        yield e
def embed_cpu():
    for e in embedding_model_cpu.embed(documents):
        yield e
start = time.time()
print(len(list(embed_gpu())))
end = time.time()
print(end - start)

start = time.time()
print(len(list(embed_cpu())))
end = time.time()
print(end - start)