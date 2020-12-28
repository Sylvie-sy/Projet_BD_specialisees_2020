-------------------------
-- 01 creer les tables --
-------------------------
DROP TABLE IF EXISTS bds.Pokemon CASCADE;
DROP TABLE IF EXISTS bds.Combats CASCADE;
DROP SCHEMA IF EXISTS bds CASCADE;

CREATE SCHEMA bds;

CREATE TABLE bds.Pokemon(
    Id INTEGER UNIQUE,
    Name VARCHAR(80) UNIQUE,
    Type_1 VARCHAR(50),
    Type_2 VARCHAR(50),
    HP INTEGER CONSTRAINT hp_positif CHECK(HP>0),
    Attack INTEGER,
    Defense INTEGER,
    Sp_Atk INTEGER,
    Sp_Def INTEGER,
    Speed INTEGER,
    Generation INTEGER,
    Legendary BOOLEAN NOT NULL,
    PRIMARY KEY (Id, Name)
);

CREATE TABLE bds.Combats(
    First_pokemon INTEGER,
    Second_pokemon INTEGER,
    Winner INTEGER,
    FOREIGN KEY (First_pokemon) REFERENCES bds.Pokemon(Id) ON DELETE CASCADE,
    FOREIGN KEY (Second_pokemon) REFERENCES bds.Pokemon(Id) ON DELETE CASCADE,
    FOREIGN KEY (Winner) REFERENCES bds.Pokemon(Id) ON DELETE CASCADE
);

--------------------
-- 02 Insert Data --
--------------------

-- selon pwd, on trouve le path de les fichiers
\set pokemon_path `pwd`'/pokemon.csv'
\set combats_path `pwd`'/combats.csv'

COPY bds.Pokemon FROM :'pokemon_path' WITH DELIMITER ',' CSV HEADER;
COPY bds.Combats FROM :'combats_path' DELIMITER ',' CSV HEADER;

--------------------------
-- 03 Grant les droites --
--------------------------

GRANT USAGE ON SCHEMA bds to PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA bds to PUBLIC;
GRANT INSERT ON ALL TABLES IN SCHEMA bds to PUBLIC;

---------------------
-- 04 create index --
---------------------

DROP INDEX IF EXISTS index_pokemon_id;
DROP INDEX IF EXISTS index_pokemon_name;
DROP INDEX IF EXISTS index_combats_first_id;

CREATE INDEX index_pokemon_id ON Pokemon USING BTREE (Id);
CREATE INDEX index_pokemon_name ON Pokemon USING HASH (Name);
CREATE INDEX index_combats_first_id ON Combats USING BTREE(First_pokemon);

--------------------
-- 05 search path --
--------------------

--set search_path
SHOW search_path;
-- ici, 'bai' est mon login, vous devez le remplacer par votre
SET search_path TO bds,PUBLIC
