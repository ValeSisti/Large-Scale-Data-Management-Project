# OrientDB vs Neo4j Queries

### 1. Find all paths with 10 relationships and do not care about the relationship direction:

- Neo4j
    
    ```cypher
    MATCH path = ()-[*10]-() RETURN nodes(path) LIMIT 200
    ```
    
- OrientDB
    
    ```sql
    SELECT FROM (TRAVERSE * FROM V WHILE $depth <=10 LIMIT 200) WHERE $depth = 10
    ```
    

### 2. Find all paths with 5 relationships or less from a Song node

- Neo4j
    
    ```cypher
    MATCH path = (:Song)-[*..5]->() RETURN nodes(path) LIMIT 200
    ```
    

### 3. Find all paths of a minimum length of 3 and a maximum of 5 from a Song node

- Neo4j
    
    ```cypher
    MATCH path = (:Song)-[*3..5]->() RETURN nodes(path) LIMIT 200
    ```
    

### 4. Find the songs that are sung by all the artists in a specific list

- Neo4j
    
    ```cypher
    WITH ['Machine Gun Kelly', 'Halsey'] as names
    MATCH (a:Artist)
    WHERE a.name in names
    WITH collect(a) as artists
    MATCH (s:Song)
    WHERE ALL(a in artists WHERE (a)-[:IS_SONG_OF]-(s))
    RETURN s
    ```
    

### 5. Find all featuring of ‘Machine Gun Kelly’

- Neo4j
    
    ```cypher
    MATCH (a:Artist)-[:IS_SONG_OF]-(s:Song)-[r:IS_SONG_OF]-(a1:Artist)
    WHERE a.name = 'Machine Gun Kelly' and  a.id <> a1.id 
    RETURN s.name,a.name,a1.name, count(r) as cnt ORDER BY cnt DESC
    ```
    

### 6. Match on Edge property: Find all the songs that hit the #1 of the Billboard chart and in which week

- Neo4j
    
    ```cypher
    MATCH (s:Song)-[r:isSongInBillboardWeek {rank:1}]->(bw:BillboardWeek) RETURN DISTINCT s.name, bw.week_of_date, r.weeks_on_chart ORDER BY bw.week_of_date DESC
    ```
    
- OrientDB
    
    ```sql
    MATCH {class:Song, as:s}.outE('isSongInBillboardWeek'){as:r, where:(rank=1)}.inV('BillboardWeek'){as:bw} RETURN DISTINCT s.name, bw.week_of_date, r.weeks_on_chart order by bw.week_of_date desc
    ```
    

## 7. Neo4j allows to express cycles of any length in the following way

- Neo4j:
    
    ```cypher
    MATCH p=(n)-[*]->(n) RETURN nodes(p)
    ```
    
- In OrientDB → only fixed length paths:
    
    ```sql
    MATCH
         {class: Artist, as: artist}
         .out().out().out() {as: artist} 
    RETURN $pathElements
    ```
    

## 8. Neo4j allows to express Negative paths in the following way

Find artists of the label “Capitol Records US” that do not make the “pop” genre

- Neo4j:
    
    ```cypher
    MATCH (g:Genre) WHERE g.genre_name = "pop"
    WITH g 
    MATCH (a:Artist)-[:HAS_LABEL]-(l:Label) WHERE l.label_name = "Capitol Records US" AND NOT EXISTS ((a)-[:DOES_GENRE]-(g)) RETURN a
    ```
    

- OrientDB:
    
    ```sql
    //La stessa query dovrebbe essere così ma non funziona come previsto
    MATCH
      {class:Artist, as:a}-hasLabel-{class:Label, as:l, where:(label_name = "Capitol Records US")},
      NOT {as:a}-doesGenre-{class:Genre, where:(genre_name="pop")}
    RETURN a.name
    
    //Se facciamo un analisi più profonda infatti, possiamo vedere che è totalmente buggato
    //supponiamo di voler ritornare il numero di artisti che fanno/non fanno il genere 'electropop'
    //se faccio così mi ritorna che circa 300 artisti fanno il genere electropop
    MATCH
      {class:Artist, as:a},
      {class:Genre, as:g, where:(genre_name='electropop')},
      {as:a}-doesGenre-{as:g}  
    RETURN count(a)
    //result: 376 (OK)
    
    //su neo4j:
    MATCH (g:Genre) WHERE g.genre_name = 'electropop'
    MATCH (a:Artist) WHERE  (a)-[:DOES_GENRE]-(g) RETURN count(a)
    //result: 376 (OK)
    
    //se metto il NOT
    MATCH
      {class:Artist, as:a},
      {class:Genre, as:g, where:(genre_name='electropop')},
      NOT {as:a}-doesGenre-{as:g}  
    RETURN count(a)
    //result: 36 (senza alcun senso)
    
    //su neo4j:
    MATCH (g:Genre) WHERE g.genre_name = 'electropop'
    MATCH (a:Artist) WHERE NOT (a)-[:DOES_GENRE]-(g) RETURN count(a)
    //result: 19926 (come è giusto che sia)
    ```
    
    Nella documentazione c’è scritto che è una funzione sperimentale:
    
    ![Untitled](OrientDB%20vs%20Neo4j%20Queries%202c8cea0922e1421fa296c17507c86f5b/Untitled.png)
    
    ## 9. Neo4j allows to express regular path queries in the following way
    
    ```sql
    MATCH (n)-[:IS_SONG_OF|IS_ALBUM_OF]->(a:Artist)
    WHERE n.name = 'Home'
    RETURN a,n
    ```
    

## 10. WITH

- In OrientDB we don’t have anything as the WITH clause that we have in Neo4j. The WITH is basically used in queries like:
    
    ```cypher
    MATCH (a:Artist)<-[:isSongOf]-(s)
    WITH count(*) AS numberOfSongs, a
    WHERE numberOfSongs > 100
    ORDER BY numberOfSongs DESC
    LIMIT 5
    ```
    
    That in OrientDB can be performed in this way:
    
    ```sql
    SELECT * FROM (
    		MATCH {class:Artist, as:a}<-isSongOf-{as:s}
    		RETURN count(*) AS numberOfSongs, a
    ) WHERE numberOfSongs > 100
    ORDER BY numberOfSongs DESC 
    LIMIT 5
    ```
    

## 11. FOREACH

- In OrientDB we don’t have the FOREACH. So a query like the following cannot be done in OrientDB:
    
    ```cypher
    MATCH p =(begin)-[*]->(end)
    WHERE begin.name='A' AND end.name='D'
    FOREACH (n IN nodes(p) | SET n.marked = TRUE )
    ```
