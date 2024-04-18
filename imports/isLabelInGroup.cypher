//isLabelInGroup
LOAD CSV WITH HEADERS FROM 'file:///E:/OrientDBProject/music_data/is_label_in_group.csv' AS line
MATCH (l:Label {label_name: line.label})
MATCH (g:LabelGroup {group_name:line.group})
MERGE (l)-[:IS_LABEL_IN_GROUP]->(g)

