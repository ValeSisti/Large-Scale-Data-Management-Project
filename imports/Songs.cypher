//Songs
:auto LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/songs.csv' AS line
CALL {
    WITH line
    MERGE (:Song {id: line.id, name: line.name, popularity:line.popularity, track_number: line.track_number, duration: line.duration, explicit: line.explicit, preview_url:line.preview_url})
} IN TRANSACTIONS OF 500 ROWS