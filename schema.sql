CREATE TABLE pokemon (
  id char(3) PRIMARY KEY CHECK (id NOT LIKE '% %'), -- test/check
  name varchar(100) UNIQUE NOT NULL,
  imgname varchar(100) UNIQUE NOT NULL
);

CREATE TABLE ratings (
  id serial PRIMARY KEY,
  pokemon_id char(3) NOT NULL REFERENCES pokemon (id),
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5)
);