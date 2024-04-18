//Albums
:auto LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/albums.csv' AS line
CALL {
    WITH line
    MERGE (:Album {id: line.id, name: line.name, album_type:line.album_type, popularity: line.popularity, release_date:line.release_date})
} IN TRANSACTIONS OF 500 ROWS