DROP TABLE IF EXISTS observations;
CREATE TABLE observations (
  id SERIAL primary key,
  doc jsonb
);

COPY observations (doc) FROM STDIN;
