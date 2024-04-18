//Genres
LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/genres.csv' AS line
CREATE (:Genre {genre_name: line.genre_name})