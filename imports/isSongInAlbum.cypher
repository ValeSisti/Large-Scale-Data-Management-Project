//isSongInAlbum
:auto LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/is_song_in_album.csv' AS line
CALL{
    WITH line
    MATCH (s:Song {id: line.track_id})
    MATCH (a:Album {id:line.album_id})
    MERGE (s)-[:IS_SONG_IN_ALBUM]->(a)
} IN TRANSACTIONS OF 500 ROWS
