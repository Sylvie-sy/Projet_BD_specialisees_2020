# Requêtes

*WANG Shiying, 21960641, M2 Informatique parcours DATA*  (shiyingw95@gmail.com)

*BAI Yuchen, 71418516,  M2 Informatique parcours DATA (yuchenbai@hotmail.com)*



## Importer les fichiers  ```.csv``` et créer les tables

* Pour Neo4j

  ```cypher
  DROP INDEX index_pokemon [IF EXISTS]
  ```

  ```cypher
  CREATE INDEX index_pokemon [IF NOT EXISTS]
  FOR (n:Pokemon)
  ON (n.Id, n.Name)
  ```

  ```cypher
  LOAD CSV with headers FROM 'file:///pokemon.csv' AS row
  CREATE (p:Pokemon{
      id: toInteger(row.Id),
      name: row.Name,
      type1: row.Type_1,
      type2: row.Type_2,
      hp: toInteger(row.Hp),
      attack: toInteger(row.Attack),
      defense:toInteger(row.Defense),
      sp_atk: toInteger(row.Sp_Atk),
      sp_def: toInteger(row.Sp_Def),
      speed: toInteger(row.Speed),
      generation: toInteger(row.Generation),
      legendary: toBoolean(row.Lengendary)
  })
  ```

  ```cypher
  CREATE CONSTRAINT ON (n:Pokemon) ASSERT n.name IS UNIQUE
  ```

  ```cypher
  CREATE CONSTRAINT ON (n:Pokemon) ASSERT n.id IS UNIQUE
  ```

  ```cypher
  :auto USING PERIODIC COMMIT 500
  LOAD CSV WITH HEADERS FROM 'file:///combats.csv' AS row
  MATCH (p1:Pokemon {id: toInteger(row.First_pokemon)}), (p2:Pokemon {id: toInteger(row.Second_pokemon)})
  MERGE (p1)-[:COMBAT {winner: toInteger(row.Winner)}]-(p2)
  ```

* Pour PostgreSQL

  ```sql
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
  ```

  

## Liste de Requêtes

- On va trouver tous les pokémons qui a gagné le match avec Pikachu, retourne **id** et **name** de pokémon
  - Neo4j

    ```cypher
    MATCH (p1:Pokemon)-[c:COMBAT]-(p2:Pokemon) WHERE p1.name='Pikachu' AND c.winner=p2.id RETURN p2.id, p2.name ORDER BY p2.id
    ```

  - Sql

    ```sql
    SELECT P.id, P.name 
    FROM pokemon P
    WHERE P.name <> 'Pikachu' 
    AND P.id IN (
    	SELECT C.winner
    	FROM combats C JOIN pokemon P
    	ON (P.id = C.first_pokemon OR P.ID = C.second_pokemon)
    	WHERE P.name = 'Pikachu'
    );
    ```

- On va trouver les **winrates** pour tous les pokémons

  - Neo4j

    ```
    
    ```

  - Sql

    ```sql
    SELECT DISTINCT first_pokemon, ROUND(CAST(win_nb as numeric)/CAST(total as numeric),2) AS Winrate
    FROM (
    SELECT first_pokemon,
    COUNT(*) total,
        SUM(case when first_pokemon=winner then 1 else 0 end) AS win_nb
        FROM combats
        GROUP BY first_pokemon
    ) x;
    ```
