//isAlbumOf
:auto LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/is_album_of.csv' AS line
CALL{
    WITH line
    MATCH (al:Album {id: line.album_id})
    MATCH (a:Artist {id:line.artist_id})
    MERGE (al)-[:IS_ALBUM_OF]->(a)
} IN TRANSACTIONS OF 500 ROWS
