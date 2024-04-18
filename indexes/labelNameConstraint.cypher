//labelNameConstraint
CREATE CONSTRAINT labelNameConstraint FOR (l:Label) REQUIRE l.label_name IS UNIQUE