//hasLabel
:auto LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/has_label.csv' AS line
CALL{
    WITH line
    MATCH (l:Label {label_name: line.label})
    MATCH (a:Artist {id:line.artist_id})
    MERGE (a)-[:HAS_LABEL]->(l)
} IN TRANSACTIONS OF 500 ROWS
