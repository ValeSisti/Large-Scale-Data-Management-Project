//labelGroupNameConstraint
CREATE CONSTRAINT labelGroupNameConstraint FOR (lg:LabelGroup) REQUIRE lg.group_name IS UNIQUE