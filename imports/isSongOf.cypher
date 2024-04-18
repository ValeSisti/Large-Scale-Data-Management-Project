//isSongOf
:auto LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/is_song_of.csv' AS line
CALL{
    WITH line
    MATCH (s:Song {id: line.track_id})
    MATCH (a:Artist {id:line.artist_id})
    MERGE (s)-[:IS_SONG_OF]->(a)
} IN TRANSACTIONS OF 500 ROWS
