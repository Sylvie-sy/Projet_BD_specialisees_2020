# Requêtes

*WANG Shiying, 21960641, M2 Informatique parcours DATA*  (shiyingw95@gmail.com)

*BAI Yuchen, 71418516,  M2 Informatique parcours DATA (yuchenbai@hotmail.com)*



## 1. Importer les fichiers  ```.csv``` et créer les tables

1. Pour Neo4j

   ```cypher
   DROP INDEX index_pokemon IF EXISTS
   DROP INDEX index_pokemon_bis IF EXISTS
   ```

   ```cypher
   CREATE INDEX index_pokemon IF NOT EXISTS
   FOR (p:Pokemon)
   ON (p.Id, p.Name)
   CREATE INDEX index_pokemon_bis IF NOT EXISTS
   FOR (p2:Pokemon_bis)
   ON (p2.id, p2.name) 
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
   LOAD CSV with headers FROM 'file:///pokemon_bis.csv' AS row
   CREATE (p2:Pokemon_bis{
       ag_bug: toFloat(row.against_bug),
       ag_dark: toFloat(row.against_dark),
       ag_dragon: toFloat(row.against_dragon),
       ag_electric: toFloat(row.against_electric),
       ag_fairy: toFloat(row.against_fairy),
       ag_fire: toFloat(row.against_fire),
       ag_flying: toFloat(row.against_flying),
       ag_ghost: toFloat(row.against_ghost),
       ag_grass: toFloat(row.against_grass),
       ag_ground: toFloat(row.against_ground),
       ag_ice: toFloat(row.against_ice),
       ag_normal: toFloat(row.against_normal),
       ag_poison: toFloat(row.against_poison),
       ag_psychic: toFloat(row.against_psychic),
       ag_rock: toFloat(row.against_rock),
       ag_steel: toFloat(row.against_steel),
       ag_water: toFloat(row.against_water),
       cp: toInteger(row.capture_rate),
       h: toFloat(row.height_m),
       name: row.name,
       male_percentage: row.percentage_male,
       id: toInteger(row.id),
       type1: row.type1,
       type2: row.type2,
       w: toFloat(row.weight_kg),
       g: toInteger(row.generation)
   })
   ```

   ```cypher
   :auto USING PERIODIC COMMIT 500
   LOAD CSV WITH HEADERS FROM 'file:///combats.csv' AS row
   MATCH (p1:Pokemon {id: toInteger(row.First_pokemon)}), (p2:Pokemon {id: toInteger(row.Second_pokemon)})
   MERGE (p1)-[:COMBAT {winner: toInteger(row.Winner)}]-(p2)
   ```

   ```cypher
   MATCH (p1:Pokemon),(p2:Pokemon_bis)
   WHERE p1.name = p2.name
   MERGE (p1)-[:SAME]-(p2)
   ```



2. Pour PostgreSQL 

   ```sql
   -------------------------
   -- 01 creer les tables --
   -------------------------
   DROP TABLE IF EXISTS bds.Pokemon CASCADE;
   DROP TABLE IF EXISTS bds.Combats CASCADE;
   DROP TABLE IF EXISTS bds.Pokemon_bis CASCADE;
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
   
   CREATE TABLE bds.Pokemon_bis(
       Abilities VARCHAR(100),
       against_bug FLOAT,
       against_dark FLOAT,
       against_dragon FLOAT,
       against_electric FLOAT,
       against_fairy FLOAT,
       against_fight FLOAT,
       against_fire FLOAT,
       against_flying FLOAT,
       against_ghost FLOAT,
       against_grass FLOAT,
       against_ground FLOAT,
       against_ice FLOAT,
       against_normal FLOAT,
       against_poison FLOAT,
       against_psychic FLOAT,
       against_rock FLOAT,
       against_steel FLOAT,
       against_water FLOAT,
       base_egg_steps INTEGER,
       capture_rate INTEGER CONSTRAINT capture_rate_limit CHECK(capture_rate<256),
       height_m FLOAT,
       name VARCHAR(80) UNIQUE,
       percentage_male FLOAT,
       id INTEGER UNIQUE,
       type1 VARCHAR(50),
       type2 VARCHAR(50),
       weight_kg FLOAT,
       generation INTEGER,
       is_lengendary BOOLEAN,
       PRIMARY KEY (id, name)
   );
   
   --------------------
   -- 02 Insert Data --
   --------------------
   
   -- selon pwd, on trouve le path de les fichiers
   \set pokemon_path `pwd`'/pokemon.csv'
   \set combats_path `pwd`'/combats.csv'
   \set pokemon_bis_path `pwd`'/pokemon_bis.csv'
   
   COPY bds.Pokemon FROM :'pokemon_path' WITH DELIMITER ',' CSV HEADER;
   COPY bds.Combats FROM :'combats_path' DELIMITER ',' CSV HEADER;
   COPY bds.Pokemon_bis FROM :'pokemon_bis_path' WITH DELIMITER ',' CSV HEADER;
   
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
   DROP INDEX IF EXISTS index_pokemon_bis_id;
   DROP INDEX IF EXISTS index_pokemon_bis_name;
   DROP INDEX IF EXISTS index_combats_first_id;
   
   CREATE INDEX index_pokemon_id ON Pokemon USING BTREE (Id);
   CREATE INDEX index_pokemon_name ON Pokemon USING HASH (Name);
   CREATE INDEX index_pokemon_bis_id ON Pokemon_bis USING BTREE (id);
   CREATE INDEX index_pokemon_bis_name ON Pokemon_bis USING HASH (name);
   CREATE INDEX index_combats_first_id ON Combats USING BTREE(First_pokemon);
   
   --------------------
   -- 05 search path --
   --------------------
   
   --set search_path
   SHOW search_path;
   -- ici, 'bai' est mon login, vous devez le remplacer par votre
   SET search_path TO bds,PUBLIC
   ```



## 2. Liste de Requêtes

### 2.1 Requêtes de Neo4j

1. Trouver le pokémon **'Pikachu'**

   ```cypher
   MATCH (p1:Pokemon)
   WHERE p1.name = "Pikachu"
   RETURN p1.id, p1.name, p1.type1, p1.generation
   ```

2. Trouver tous les pokémon qui ne sont pas le rival de **'Pikachu'**.

   ```cypher
   MATCH (p1:Pokemon{name:'Pikachu'}), (p2:Pokemon)
   WHERE NOT (p1)-[:COMBAT]-(p2)
   RETURN p2.id, p2.name
   ```

3. Trouver tous les pokémon a combattu **'Bulbasaur'** et qui ont l'attribut **'Grass'**.

   ```cypher
   MATCH (p1:Pokemon{name:'Bulbasaur'}), (p2:Pokemon)
   WHERE (p1)-[:COMBAT]-(p2) AND (p2.type1='Grass' OR p2.type2='Grass')
   RETURN p2.id, p2.name 
   ```

4. Calculer le nombre total de pokémon des attributs du **'Grass'**.

   ```cypher
   MATCH (p:Pokemon)
   WHERE p.type1='Grass' OR p.type2='Grass'
   RETURN count(p)
   ```

5. Trouver des Pokémons avec une attack supérieure à sp_atk et un taux de capture supérieur à 100.

   ```cypher
   MATCH (p1:Pokemon),(p2:Pokemon_bis)
   WHERE (p1)-[:SAME]-(p2) AND p2.cp>100 AND p1.attack>p1.sp_atk
   RETURN p1.id, p1.name
   ```

6. Calculer le taux de réussite de la capture de **'Pikachu'** et de **'Psyduck'**. 
   (Équation du taux de réussite de la capture = capture_rate/255+generation*10)

   ```cypher
   MATCH (p1:Pokemon),(p2:Pokemon_bis)
   WHERE (p1) -[:SAME]- (p2) AND (p1.name='Pikachu' OR p1.name='Psyduck')                      
   WITH p1, toFloat(p2.cp/255 + p1.generation*10) AS Taux
   RETURN p1.id, p1.name, ROUND(Taux,2) AS Taux_reus_capture
   ORDER BY Taux_reus_capture DESC
   ```

7. Trouver tous les combats de pokémon **d'eau** et **de feu**, et **leur côté gagnant**.

   ```cypher
   MATCH (p1:Pokemon)-[c:COMBAT]-(p2:Pokemon)
   WHERE (p1.type1='Water' OR p1.type2='Water') AND (p2.type1='Fire' OR p2.type2='Fire')
   RETURN p1.id AS Water_id,p1.name AS Water_name,c.winner, p2.id AS Fire_id ,p2.name AS Fire_name
   ```

8. Touver les points d'attacks de **"Pikachu"** aux ses rivaux

   ```cypher
   MATCH (p1:Pokemon {name:"Pikachu"})-[:COMBATS]-(p2:Pokemon), (p2)-[:SAME]-(p3:Pokemon_bis)
   RETURN p1.name AS attack_from, p2.id, p2.name, (p1.attck * p3.ag_electric) AS hp_loss, (p2.hp - (p1.attck * p3.ag_electric)) AS hp_rest
   ```

   

### 2.2 Requêtes de "Neo4j vs Postgresql"

1. On va trouver tous les pokémons qui a gagné le match avec Pikachu, retourne **id** et **name** de pokémon

   - Neo4j

     ```cypher
     MATCH (p1:Pokemon)-[c:COMBAT]-(p2:Pokemon) WHERE p1.name='Pikachu' AND c.winner=p2.id RETURN p2.id, p2.name ORDER BY p2.id
     ```

   - PostgreSQL

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

2. On va trouver les **winrates** pour tous les pokémons

   - Neo4j

     ```cypher
     MATCH (p1:Pokemon)-[c:COMBAT]-(p2:Pokemon) 
     WHERE p1.id = c.winner
     WITH p1, toFloat(COUNT(c))/size((p1)-[:COMBAT]-(:Pokemon)) AS number
     RETURN p1.name, ROUND(number, 2) AS winrate
     ORDER BY winrate DESC
     ```

   - PostgreSQL

     ```sql
     SELECT DISTINCT first_pokemon, ROUND(CAST(win_nb as numeric)/CAST(total as numeric),2) AS Winrate
     FROM (
     SELECT first_pokemon,
     COUNT(*) total,
         SUM(case when first_pokemon=winner then 1 else 0 end) AS win_nb
         FROM combats
         GROUP BY first_pokemon
     ) x
     ORDER BY Winrate;
     ```

3. On va trouver le taux de capture de pokemen avec le plus grand winrate.

   - Neo4j

     ```cypher
     CALL{
     MATCH (p1:Pokemon)-[c:COMBAT]-(p2:Pokemon) 
     WHERE p1.id = c.winner
     WITH p1, toFloat(COUNT(c))/size((p1)-[:COMBAT]-(:Pokemon)) AS number
     RETURN p1.id AS id_max, p1.name AS name_max, MAX(ROUND(number, 2)) AS winrate_max
     }
     MATCH(p3:Pokemon_bis) -[s:SAME]- (p1:Pokemon)
     WHERE p3.name = name_max                                  
     RETURN id_max,name_max,winrate_max,p3.cp ORDER BY winrate_max DESC LIMIT 3
     ```

   - PostgreSQL

     ```sql
     WITH Max_winrate(first_pokemon, Winrate) AS (
     SELECT DISTINCT first_pokemon, ROUND(CAST(win_nb as numeric)/CAST(total as numeric),2) AS Winrate
     FROM (
     SELECT first_pokemon,
     COUNT(*) total,
         SUM(case when first_pokemon=winner then 1 else 0 end) AS win_nb
         FROM combats
         GROUP BY first_pokemon
     ) x
     )
     SELECT Pokemon.name,Max_winrate.Winrate,Pokemon_bis.capture_rate
     FROM Pokemon,Max_winrate,Pokemon_bis
     WHERE Pokemon.id = Max_winrate.first_pokemon AND Pokemon_bis.name = Pokemon.name
     ORDER BY Max_winrate.Winrate DESC LIMIT 3;
     ```

4. On va trouver une chaine de Pokémon qui ont la table **Combat** :

   - Neo4j

     ```cypher
     MATCH (p1:Pokemon)-[:COMBAT*1..2]-(p2:Pokemon)
     WHERE p1.name = 'Pikachu'
     RETURN p2
     ```

   - PostgreSQL

     ```sql
     WITH RECURSIVE cte AS (
     	SELECT P.id, P.name, C.second_pokemon, 0 AS depth 
         FROM pokemon P 
         JOIN combats C
     	ON P.id = C.first_pokemon
         WHERE P.name = 'Pikachu'
         UNION ALL
         SELECT P2.id, P2.name, C.second_pokemon,cte.depth+1
         FROM pokemon P2 
         JOIN combats C
     	ON P2.id = C.first_pokemon
         JOIN cte ON P2.id = cte.second_pokemon
         WHERE (cte.depth<3 AND P2.name <> 'Pikachu')
     )
     SELECT DISTINCT C.id, C.name, C.depth
     FROM cte C;
     ```



## 3. Graph Data Science Library

* Shortest path - graphe anonyme

  ```cypher
  MATCH (p1:Pokemon {name:"Pikachu"}), (p2:Pokemon {name:"Bulbasaur"})
  CALL gds.alpha.shortestPath.stream({
      startNode: p1,
      endNode: p2,
      nodeProjection: "*",
      relationshipProjection:{
      all:{
          type: "*",
          orientation: "UNDIRECTED"
  		}
  	}
  })
  YIELD nodeId
  RETURN gds.util.asNode(nodeId).name AS pp; 
  ```

* pagerank - graphe nommé

  ```cypher
  CALL gds.graph.create.cypher(
      'graphe_pokemon',
      'MATCH (p:Pokemon) RETURN p.id AS id',
      'MATCH (p1)-[:COMBAT]-(p2) RETURN p1.id AS source, p2.id AS target'
  )
  ```

  ```cypher
  CALL gds.pageRank.stream('graphe_pokemon')
  YIELD nodeId, score
  RETURN gds.util.asNode(nodeId).name AS name, score
  ```

  ```cypher
  CALL gds.pageRank.write('graphe_pokemon', {writeProperty:'pageRank'})
  YIELD nodePropertiesWritten, ranIterations
  ```

* degree

  ```cypher
  CALL gds.alpha.degree.stream('graphe_pokemon')
  YIELD nodeId, score
  RETURN gds.util.asNode(nodeId).name AS name, score
  ORDER BY score DESC LIMIT 10
  ```

* louvain

  ```cypher
  CALL gds.louvain.stream('graphe_pokemon')
  YIELD nodeId, communityId
  RETURN gds.util.asNode(nodeId).name AS name, communityId
  ```

  ```cypher
  CALL gds.louvain.stats('graphe_pokemon')
  YIELD communityCount
  ```

  ```cypher
  CALL gds.louvain.mutate('graphe_pokemon', { mutateProperty: 'communityId' })
  YIELD communityCount, modularity, modularities
  ```

  ```cypher
  CALL gds.alpha.degree.write('graphe_pokemon', {writeProperty:'weightedFollowers'})
  YIELD nodes, writeProperty
  ```
  

