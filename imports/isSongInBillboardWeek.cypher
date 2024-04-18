//isSongInBillboardWeek
:auto LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/billboard_hot100_songs.csv' AS line
CALL{
    WITH line
    MATCH (s:Song {id: line.track_id})
    MATCH (bw:BillboardWeek {week_of_date:line.date})
    MERGE (s)-[:IS_SONG_IN_BILLBOARD_WEEK {rank:line.rank, weeks_on_chart:line.weeks_on_chart, peak_rank:line.peak_rank}]->(bw)
} IN TRANSACTIONS OF 500 ROWS
