//Artists
LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/artists.csv' AS line
CREATE (:Artist {id: line.id, name: line.name, popularity:line.popularity, followers: line.followers})