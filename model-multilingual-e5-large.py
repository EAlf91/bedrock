from typing import List
import time
import json
import csv
import uuid
import numpy as np
import sys
import pandas as pd

from fastembed import TextEmbedding
hp_data = None
with open("./hp_all.json") as f:
    hp_data = json.load(f)

print(hp_data[0])
supported_models = (
    pd.DataFrame(TextEmbedding.list_supported_models())
    .sort_values("size_in_GB")
    .drop(columns=["sources", "model_file", "additional_files"])
    .reset_index(drop=True)
)
supported_models
print(supported_models)
embedding_model_cpu = TextEmbedding(
    model_name="intfloat/multilingual-e5-large", providers=["CPUExecutionProvider"]
)

embedding_model_gpu = TextEmbedding(
    model_name="intfloat/multilingual-e5-large", providers=["CUDAExecutionProvider"]
)
print(embedding_model_gpu.model.model.get_providers())



def embed_cpu(documents):
    i = 0
    for e in embedding_model_cpu.embed(documents):
        print("finished: {}".format(i))
        i = i + 1
        yield e

def chunk_text(text, chunk_size):
    return [text[i:i + chunk_size] for i in range(0, len(text), chunk_size)]

def divide_chunks(l, n):    
    # looping till length l
    for i in range(0, len(l), n): 
        yield l[i:i + n]

#chunk
chunks = []
print(len(chunks))
for text in hp_data:
    chunks = chunks + (chunk_text(text['body_text'],1024))

data = [
    ["id","embedding", "chunks", "metadata"]
]
start = int(sys.argv[1])
end = int(sys.argv[2])
print(len(chunks))#14971
c_small = chunks[start:end]#for testing chunks[1:10]

embeddings_generator = embedding_model_gpu.embed(c_small)
i = 0
for doc, vector in zip(c_small, embeddings_generator):
    print("finished: {}".format(i))
    data.append([uuid.uuid4(),json.dumps(vector.tolist()), c_small[i], json.dumps({"sourceUrl": "s3://bedrock-data-source-761018867105/hp_short_en_202408132150{}.md".format(start)})])
    i = i + 1

with open('output{}.csv'.format(start), mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(data)


