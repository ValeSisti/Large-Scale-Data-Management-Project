//Labels
LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/labels.csv' AS line
CREATE (:Label {label_name: line.label_name})