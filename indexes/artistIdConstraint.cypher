//artistIdConstraint
CREATE CONSTRAINT artistIdConstraint FOR (a:Artist) REQUIRE a.id IS UNIQUE