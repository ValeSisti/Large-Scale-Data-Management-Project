//genreNameConstraint
CREATE CONSTRAINT genreNameConstraint FOR (g:Genre) REQUIRE g.genre_name IS UNIQUE