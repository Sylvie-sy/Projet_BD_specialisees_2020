Requetes

-----------

Shiying WANG

Yuchen BAI



-------------

1. Load ```.csv``` files and create table

   ```
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
   MERGE (p1)-[:COMBAT {winner: row.Winner}]-(p2)
   ```

   
