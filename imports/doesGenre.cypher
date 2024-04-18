//doesGenre
LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/does_genre.csv' AS line
MATCH (g:Genre {genre_name: line.genre})
MATCH (a:Artist {id:line.artist})
MERGE (a)-[:DOES_GENRE]->(g)