//LabelGroups
LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/label_groups.csv' AS line
CREATE (:LabelGroup {group_name: line.group_name})