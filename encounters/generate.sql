CREATE EXTENSION IF NOT EXISTS jsquery;
DROP TABLE IF EXISTS encounters;
CREATE TABLE encounters (
  id SERIAL primary key,
  doc jsonb);

COPY encounters (doc) FROM STDIN;
