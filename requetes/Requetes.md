### Requetes

-----------

Shiying WANG

Yuchen BAI



-------------


1. Load ```.csv``` files and create table

   ```cypher
   DROP INDEX index_pokemon [IF EXISTS]
   ```

   ```cypher
   CREATE INDEX index_pokemon [IF NOT EXISTS]
   FOR (n:Pokemon)
   ON (n.Id,
   	n.Name)
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
   
   CREATE CONSTRAINT ON (n:Pokemon) ASSERT n.name IS UNIQUE;
   CREATE CONSTRAINT ON (n:Pokemon) ASSERT n.id IS UNIQUE;
   
   :auto USING PERIODIC COMMIT 500
   LOAD CSV WITH HEADERS FROM 'file:///combats.csv' AS row
   MATCH (p1:Pokemon {id: toInteger(row.First_pokemon)}), (p2:Pokemon {id: toInteger(row.Second_pokemon)})
   MERGE (p1)-[:COMBAT {winner: toInteger(row.Winner)}]-(p2)
   ```

   

2. Requêtres intéressant

   * 

   ```cypher
   MATCH (p1:Pokemon)-[c:COMBAT]-(p2:Pokemon) WHERE p1.name='Pikachu' AND c.winner=p2.id RETURN p2.id, p2.name ORDER BY p2.id
   ```

   

   

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

   

   