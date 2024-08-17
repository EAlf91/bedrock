
create extension vector schema pg_catalog;
create schema bedrock_integration;
CREATE TABLE bedrock_integration.bedrock_kb (id uuid PRIMARY KEY, embedding vector(1024), chunks text, metadata json);
CREATE INDEX ON bedrock_integration.bedrock_kb USING hnsw (embedding vector_cosine_ops);
CREATE INDEX ON bedrock_integration.bedrock_kb USING hnsw (embedding vector_cosine_ops) WITH (ef_construction=256);


