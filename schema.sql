CREATE TABLE lists (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE todos (
  id serial PRIMARY KEY,
  list_id integer REFERENCES lists (id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  completed boolean DEFAULT false NOT NULL
);

