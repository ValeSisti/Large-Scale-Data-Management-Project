//songIdConstraint
CREATE CONSTRAINT songIdConstraint FOR (s:Song) REQUIRE s.id IS UNIQUE