//BillboardWeeks
LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/billboard_weeks.csv' AS line
CREATE (:BillboardWeek {week_of_date: line.week_of_date})