Requetes

-----------

Shiying WANG

Yuchen BAI



-------------

<<<<<<< Updated upstream
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

   
=======
1. Load ```.csv``` files

   * ```LOAD CSV FROM 'file:///combats.csv' AS row RETURN count(row)```

     

   * ```LOAD CSV FROM 'file:///pokemon.csv' AS row RETURN count(row)```
   
   - ```
     LOAD CSV FROM 'file:///pokemon.csv' AS row
     CREATE (p:Pokemon{
         id: toInteger(row[0]),
         name: row[1],
         type1: row[2],
         type2: row[3],
         hp: toInteger(row[4]),
         attack: toInteger(row[5]),
         defense:toInteger(row[6]),
         sp_atk: toInteger(row[7]),
         sp_def: toInteger(row[8]),
         speed: toInteger(row[9]),
         generation: toInteger(row[10]),
         legendary: toBoolean(row[11])
     })
     ```
   
     
>>>>>>> Stashed changes
