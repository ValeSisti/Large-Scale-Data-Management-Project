//albumIdConstraint
CREATE CONSTRAINT albumIdConstraint FOR (a:Album) REQUIRE a.id IS UNIQUE