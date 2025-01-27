/*
-- switch dialect to sqlite
-- set primary & foreign keys
-- drop meta_data
*/


ALTER TABLE planets
ADD PRIMARY KEY (planet_id);

ALTER TABLE stars
ADD PRIMARY KEY (star_id);

ALTER TABLE planets
ADD FOREIGN KEY (star_id)
REFERENCES stars (star_id);

ALTER TABLE values
ADD FOREIGN KEY (planet_id)
REFERENCES planets (planet_id);

ALTER TABLE values
ADD FOREIGN KEY (star_id)
REFERENCES stars (star_id);

DROP TABLE meta_data;