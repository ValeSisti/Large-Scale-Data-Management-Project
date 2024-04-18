//hasInfluenced
:auto LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/has_influenced.csv' AS line
CALL{
    WITH line
    MATCH (a1:Artist {id: line.influencer_id})
    MATCH (a2:Artist {id:line.follower_id})
    MERGE (a1)-[:HAS_INFLUENCED]->(a2)
} IN TRANSACTIONS OF 500 ROWS
