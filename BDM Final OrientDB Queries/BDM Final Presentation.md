# BDM Final Presentation (EXPANDED)

# Basic Queries

### Basic SQL query

- Ok we said that OrientDB uses an extension of SQL, so the first basic query that we may want to execute could be something like this:
    
    ```cypher
    SELECT * FROM Song WHERE name = 'Blinding Lights'
    ```
    

### Equivalent query with MATCH

- But we also said that OrientDB also introduces the MATCH clause, so an equivalent way for asking this query is this one:
    
    ```cypher
    MATCH 
    	{class: Song, as:s, where:(name = 'Blinding Lights')} 
    RETURN s
    ```
    
    - in which we specify the class, which is Song in this case, then we have the as keyword for defining an alias and then the ‘where’ for specifying some filtering conditions,
    
    However, if we use the MATCH, what is returned is simply the record id of these songs.
    
    If we want to obtain the exact same result as the select, we need to use the expand() function, that basically, if used on a record id, like in this case, it allows to expand the document pointed by that record id, so allowing us to retrieve all the information as before:
    
    ```cypher
    SELECT expand(s) FROM(
    		MATCH 
    			{class: Song, as:s, where:(name = 'Blinding Lights')} 
    		RETURN s
    )
    ```
    

### MATCH query with relationships both with arrows and functions notation

This was a very basic query, but now we may be interested for instance in retrieving 

- All Songs of ‘Avril Lavigne’
    
    We can do this actually in two ways with the MATCH, and this is because OrientDB defines two different ways in which we can specify an edge with a particular direction:
    
    - One way is this one, so with an arrow notation
        
        ```cypher
        MATCH 
        	{class: Artist, as:a, where:(name='Avril Lavigne')}<-isSongOf-{class:Song, as:s}
        RETURN s.name ORDER BY s.popularity DESC
        ```
        
    - The other euqivalent way is through the dot notation, in which we specify the function name, in this case in(), and also the specific edge class, that in this case is ‘isSongOf’
        
        ```cypher
        MATCH 
        	{class: Artist, as:a, where:(name='Avril Lavigne')}.in('isSongOf'){class:Song, as:s}
        RETURN s.name ORDER BY s.popularity DESC
        ```
        
        - the in() of course is for specifying an ingoing edge, but there are also the functions out() and both() to specify an edge in the outgoing direction or in both directions respectively
    - Actually, we can use the in(), out() and both() functions basically everywhere, so we can perform the exact same query also with the SELECT, by exploiting these functions, so another equivalent way to do this is the following:
        
        ```cypher
        SELECT name FROM Song WHERE out('isSongOf').name = 'Avril Lavigne'
        ```
        
        and as we can notice we can apply the dot notation also to these functions, for instance here where we have .name, to retrieve the name attribute of the Artist node whose edge is going towards the Song node
        

# $pathElements

But of course we can define also a longer paths, so not only with one single relationships as we have done until now. For instance we want to:

- Find all songs contained in the Album ‘Meteora’ by Linkin Park, by showing also the record labels of Linkin Park.
    
    ```cypher
    MATCH 
    	{class:Song, as:s}-isSongInAlbum->{class:Album, as:al, where:(name='Meteora')}-isAlbumOf->{class:Artist, as:lp, where:(name = 'Linkin Park')}-hasLabel->{class:Label, as:l}-isLabelInGroup->{class:Group, as:gr}
    RETURN $pathElements
    ```
    
    Moreover, until now we have seen queries results in a tabular form. However, we can always see our results also in their native graph format, and in order to do this we simply need to write, in the RETURN statement, this special variable $pathElements that is defined by OrientDB.
    
    and we can show the results in the graph.
    
    and in the graph by default it is shown the record id for each of the vertices, but we can change what we want to visualize, for instance we can choose the name.
    

# Comma “operator”

Ok but in this last query we simply defined a single path, so basically following the path Song→Album→Artist→Label→Group.

But actually, OrientDB also allows to specify not only a single path, but really a subgraph. For instance, let’s suppose now that, with respect to the previous query, we also want to retrieve for instance also the artists that has been influenced by Linkin Park and the genres that Linkin Park do.

```cypher
MATCH 
	{class:Song, as:s}-isSongInAlbum->{class:Album, as:al, where:(name='Meteora')}-isAlbumOf->{class:Artist, as:lp, where:(name = 'Linkin Park')}-hasLabel->{class:Label, as:l}-isLabelInGroup->{class:Group, as:gr},
	{as:lp}-doesGenre->{class:Genre, as:gn},
	{as:lp}-hasInfluenced->{class:Artist, as:ar}
RETURN $pathElements
```

Then order to do this, OrientDB provide this comma operator, so by putting a comma in our previous query, we can specify these further paths, let’s say, in our previous query, so “as:lp, which is the alias we have given to the Artist vertex matched as Linkin Park” we can say that we want also the genres and the influenced artists:

So in this way we can really write a query in which we really specify a subgraph and not only one single path I would say.

# Queries with aggregation functions

### Count

- Between all the artists that do the ‘pop punk’ genre, find the top 20 that have the highest number of unique songs that appeared in the BillboardChart
    
    ```cypher
    SELECT artist_name, count(*) as num_hits
    FROM (
        MATCH 
            {class:Artist, as:a}-doesGenre->{class:Genre, as:g, where:(genre_name = 'pop punk')},
            {as:a}<-isSongOf-{class:Song, as:s}-isSongInBillboardWeek->{class:BillboardWeek}
        RETURN DISTINCT a.name as artist_name, s.name as song_name
    ) GROUP BY artist_name 
    ORDER BY num_hits DESC LIMIT 20
    ```
    

### Max

- Albums with popularity > 90 in which the song that has the highest duration has a duration greater than 4 minutes
    
    ```cypher
    SELECT album_name, artist_name, max_duration FROM (
    	SELECT a.id as album_id, a.name as album_name, max(s.duration) as max_duration, ar.name as artist_name FROM (
    		MATCH 
          		{class:Album, as:a, where:(popularity > 90 and album_type = 'album')}-isSongInAlbum-{class:Song, as:s},
          		{as:a}-isAlbumOf->{as:ar}
          	RETURN a,s,ar
    	) GROUP BY album_name
    ) WHERE max_duration.asDateTime() > "00:04:00".asDateTime()
    ORDER BY max_duration DESC
    ```
    
    → Siccome nel SQL dialect di OrientDB non abbiamo la clausola HAVING che abbiamo in SQL, per fare una query del genere non possiamo scrivere GROUP BY … HAVING … ma dobbiamo usare una nested query con la WHERE clause che ha la condizione che avremmo messo nella HAVING clause
    

# size() + Set operators (IN)

Let’s suppose now that we want to find:

- Artists that do at least 20 genres
    
    OrientDB provides a function that is called size(), that allows to get the number of edges of a certain class from a particular vertex and in a particular direction. And we can do this in this way.
    
    ```cypher
    
    /*with MATCH (we need to use expand()):*/
    SELECT name, out("doesGenre").genre_name FROM (   
      SELECT expand(a) FROM (
          MATCH
              {class:Artist, as:a, where:(out("doesGenre").size() > 20)}
          RETURN a
      )
    )
    ```
    
    However, maybe this query is a bit more confusing, because if we use the Match basically we need to have two SELECTs basically. So another equivalent way to achieve this is this one, so by using one single SELECT, which is more compact and allows us to obtain the exact same result.
    
    ```cypher
    SELECT name, out("doesGenre").genre_name as genres_list
    FROM Artist 
    WHERE out("doesGenre").size() > 20
    ORDER BY name
    ```
    
    So as we can see in OrientDB we can achieve the same results in different ways, and in some cases is better to use the MATCH, while in some others is better to use the SELECT
    
    And now that we have the list of genres for each of these artists we can also set a condition over the genres_list, for instance that the list should contain two particular genres as "alternative rock" and "punk", in both the two ways:
    
    ```cypher
    
    /*with MATCH:*/
    SELECT name, out("doesGenre").genre_name as genres_list FROM (   
      SELECT expand(a) FROM (
          MATCH
              {class:Artist, as:a, where:(out("doesGenre").size() > 20)}
          RETURN a
      )
    ) WHERE "alternative rock" IN out("doesGenre").genre_name AND "punk" IN out("doesGenre").genre_name
    ORDER BY name
    
    /*with SELECT (more compact):*/
    SELECT name, out("doesGenre").genre_name as genres_list 
    FROM Artist 
    WHERE out("doesGenre").size() > 20 
    AND "alternative rock" IN out("doesGenre").genre_name
    AND "punk" IN out("doesGenre").genre_name
    ORDER BY name
    
    ```
    

# Context Variables

### $match & $currentMatch

Let’s suppose we want to find 

- All the artists that have done a featuring with ‘Alan Walker’ and in which song
    
    ```cypher
    MATCH
         {class: Artist, as: artist, where: (name = 'Alan Walker')}
         .in('isSongOf'){as:s}.out('isSongOf') {as: featured_artist} 
    RETURN featured_artist.name, s.name ORDER BY featured_artist.name
    ```
    
    If we look at the results, we can see that we obtain also Alan Walker as if he has done a featuring with himself.
    

- All the artists that have done a featuring with ‘Alan Walker’ and in which song, excluding the current artist
    
    ```cypher
    MATCH
         {class: Artist, as: artist, where: (name = 'Alan Walker')}
         .both('isSongOf'){as:s}.both('isSongOf'){as: featured_artist,
         where: ($matched.artist != $currentMatch)} 
    RETURN featured_artist.name, s.name ORDER BY featured_artist.name
    ```
    
    So, in order to exclude Alan Walker himself from the results, we need to exploit some context variables that OrientDB defines. These context variables are $matched and $currentMatch, and we can use them in this way. So basically we need to specify the $matched context variable and then by writing .artist we are basically saying that the matched node, to which we have given the alias named artist needs to be different from $currentMatch so from the Artist that we are matching right now. And so if we now execute this query we will obtain the expected result.
    

But we can use these context variables to perform also more complex filters, let’s say, so for instance, let’s suppose that we want to find:

- Albums that contain songs of artists that have done a featuring with Machine Gun Kelly and that belong to (have published a song under) its same label
    
    ```cypher
    /*Browse*/
    
    MATCH 
    	{class:Artist, as:mgk, where:(name = 'Machine Gun Kelly')}<-isSongOf-{class:Song, as:s}-isSongOf->{class:Artist, as:a, where:($matched.mgk != $currentMatch)},
        {as:s}-isSongInAlbum->{class:Album, as:al}-isAlbumOf->{class:Artist, as:album_owner},
        {as:a}-hasLabel->{class:Label, as:l, where:($currentMatch.label_name IN $matched.mgk.out('hasLabel').label_name)}
    RETURN DISTINCT a.name as featured_artist, s.name as song, al.name as album, album_owner.name as album_owner
    ```
    
    ```cypher
    /*Graph*/
    
    MATCH 
    	{class:Artist, as:mgk, where:(name = 'Machine Gun Kelly')}<-isSongOf-{class:Song, as:s}-isSongOf->{class:Artist, as:a, where:($matched.mgk != $currentMatch)},
        {as:s}-isSongInAlbum->{class:Album, as:al}-isAlbumOf->{class:Artist, as:album_owner},
        {as:a}-hasLabel->{class:Label, as:l, where:($currentMatch.label_name IN $matched.mgk.out('hasLabel').label_name)}
    RETURN $pathElements
    ```
    
    in which we first the first part of the query is similar as the query that we have done before for the featurings of Alan Walker, but then, by using the comma, we also need to match the album in which this song is contained, together with the album owner and finally we do also the check that the label of the featured artist that we are matching needs to appear in the list of labels under which Machine Gun Kelly has published a song, and to do this we can use the context variables in this way, in particular we can use this IN operator because as we have seen when we do out(’something’) and then dot the name of an attribute, this is returned in the form of a list. And if we execute the query these are the results.
    

# Match based on Edge Properties

Then, until now we have performed in which we were filtering the results only based on vertices properties. However, of course, we can perform queries also based on edge properties. 

Since in our graph database we have edge properties just on the edge of class ‘isSongInBillboardWeek’, let’s suppose we want to 

- Find, for each week of the 2018, the song that has been in the #1 position in the Billboard Chart.
    
    ```cypher
    MATCH 
    		{class:BillboardWeek, as:bw, where:(week_of_date.format('yyyy') = 2018)}.inE('isSongInBillboardWeek'){as:r, where:(rank=1)}.outV('Song'){as:s}-isSongOf->{class:Artist, as:a}
    RETURN DISTINCT s.name as song_name, bw.week_of_date.format("dd/MM/yyyy") as week_of_date, a.name as artist_name ORDER BY bw.week_of_date
    ```
    
    The way to do this is OrientDB is this one. The first thing to notice is that this is not possible to be done with the arrow notation. Then, instead of using simply in() and out() functions as we have seen until now, we need to use, in this case inE, that allows to specify the adjacent ingoing edge with respect to this BillboardWeek vertex, and so it is here that we can put our condition over the rank, and then to specify the Song vertex we need to specify it through the outV() function that allows to retrieve the outgoing vertex with respect to the isSongInBillboardWeek edge.
    

# Custom Functions

- Albums of artists of more than 6M followers that contain songs that appeared in the Billboard Hot 100 at least 10 years after their release
    
    ```cypher
    SELECT DISTINCT * FROM (
        MATCH 
            {class:Album, as:al}-isAlbumOf->{class:Artist, as:a, where:(followers >= 500000)},
            {as:al}<-isSongInAlbum-{class:Song, as:s}.outE('isSongInBillboardWeek'){as:r}
            .inV('BillboardWeek'){as:bw, where:(subtract(week_of_date.format('yyyy'), $matched.al.release_date.format('yyyy')) > 10  )}
        RETURN al.name as album_name, a.name as artist_name, s.name as song_name, al.release_date.format('yyyy-MM-dd') as release_date, bw.week_of_date.format('yyyy-MM-dd') as billboard_week
        ORDER BY release_date DESC
    )
    
    /*IMPORTANTE: ho dovuto definire la custom function 'subtract' per fare la differenza
    tra due integers, visto che facendo .format('yyyy') su una data ritornava una stringa*/
    ```
    

- Average duration of Billboard hits by year from 1990
    
    ```cypher
    SELECT year, toHHmmss(avg(toSeconds(duration))) AS avg_duration FROM (
    	MATCH 
    			{class: BillboardWeek, as:bw, where:(week_of_date.format("yyyy")>1990)}-isSongInBillboardWeek-{class:Song, as:s} 
    			RETURN bw.week_of_date.format("yyyy") as year, s.duration as duration
    ) GROUP BY year
    ORDER BY year DESC
    ```
    
    **Insight** → as we can notice, the average duration of songs that enters in the Billboard chart is decreasing every year. According to a famous UK record label (Ostereo), this is because streaming platform algorithms are influencing song length and encouraging artists to record shorter songs, because the more the song has a high length, the more is the probability for the song to be skipped, and streaming algorithms may see this as a signal of dissatisfaction, and therefore it will be less likely that streaming algorithms will recommend a longer song that has been skipped to other users, which means that the song is less likely to become popular.
    

# Assign Paths to Variables

OrientDB also allows to assign results of queries to variables. This can be useful in different situations. For instance:

### Union All

Since in OrientDB there is no OR option, if we want to perform a query like:

- “Find the Artists that do the ‘alternative rock’ genre or that has a featuring with an artist that does the ‘alternative rock’ genre
    
    ```cypher
    SELECT expand($c)
    LET 
      $a = (MATCH {class: Artist, as:a}-doesGenre->{class:Genre, where:(genre_name = 'alternative rock')} RETURN a.name),
      $b = (MATCH {class:Genre, where:(genre_name = 'alternative rock')}<-doesGenre-{class:Artist, as:feat}<-isSongOf-{class:Song}-isSongOf->{class:Artist, as:a, where:($matched.feat != $currentMatch)} RETURN a.name),
      $c = unionAll($a,$b)
    
    ```
    

the only way we can do this in OrientDB is by defining two different queries, and then use unionAll to unite the results. And the best way to write this is of course by assigning the results of these two queries to 2 variables $a and $b and then perform the unionAll over these two variables:

### Shortest Path

Another situation in which could be useful to use variables is this one, in which we want to apply the shortestPath function, offered by OrientDB, in order to:

- Find the shortest path between ‘Dua Lipa’ and ‘Boy In Space’, following just edges whose class is ‘isSongOf’, ‘isAlbumOf’ or ‘isSongInAlbum’
    
    ```cypher
    SELECT expand(path) FROM (
      SELECT shortestPath($from, $to, 'BOTH', ['isSongOf', 'isAlbumOf', 'isSongInAlbum']) AS path 
      LET 
        $from = (SELECT FROM Artist WHERE name='Dua Lipa'), 
        $to = (SELECT FROM Artist WHERE name='Boy In Space') 
      UNWIND path
    )
    ```
    

# Traverse

- Artists that have been influenced by ‘The Beatles’ up to the 8th degree of separation (8th level of depth)
    
    In order to this OrientDB provides the TRAVERSE function, which allows as the name suggests to traverse our graph database, and in doing this we can specify the type of relationship, together with the direction, and also the level of depth. So the query will look like this:
    
    ```cypher
    
    TRAVERSE out("hasInfluenced") FROM (
    		MATCH {class:Artist, as:a, where:(name='The Beatles')} RETURN a
    ) MAXDEPTH 8
    ```
    
    as we can see from this query, OrientDB just allows us to specify the MAXDEPTH directly from the TRAVERSE. If we want a specific depth, then we need to do like this: we can do the TRAVERSE with MAXDEPTH 8, so what we matched now are also path with depth less than 8. So if we just want those paths with depth equal to 8, this has to be done with a SELECT over the previous query in which we specify that $depth needs to be exactly 8.
    
    ```cypher
    SELECT name FROM (
    		TRAVERSE out("hasInfluenced") FROM (
    				MATCH {class:Artist, as:a, where:(name='The Beatles')} RETURN a
    		) MAXDEPTH 8
    ) WHERE $depth = 8 ORDER BY popularity DESC
    ```
    

# Advanced Path Matching (Variable-lenght pattern matching)

![[https://neo4j.com/docs/cypher-manual/current/syntax/patterns/](https://neo4j.com/docs/cypher-manual/current/syntax/patterns/)](BDM%20Final%20Presentation%20(EXPANDED)%20c9426ab82f1547dfbfe78018fd9c50c5/Untitled.png)

[https://neo4j.com/docs/cypher-manual/current/syntax/patterns/](https://neo4j.com/docs/cypher-manual/current/syntax/patterns/)

Variable length pattern matching is not very efficient in OrientDB, as we need to use Traverse and then filter the different paths based on the $depth context variable, but this would result in very slow queries, as we will get also paths of all the other lengths, even if we are not interested in them.

# Regular Expressions

- Top 10 most popular songs that contain the word ‘cold’, that are of an artist whose name starts with ‘B’
    
    ```cypher
    MATCH 
    	{class: Song, as:s, where:(name.toLowerCase() MATCHES '^.*cold.*$')}-isSongOf->{class:Artist, as:a, where:(name MATCHES '^B.*')}
    RETURN s.name as song_name, a.name as artist_name, s.popularity as song_popularity, a.popularity as artist_popularity
    ORDER BY s.popularity DESC LIMIT 10
    ```
    

- Labels who belongs to a LabelGroup that contains the first word of their name
    
    ```cypher
    MATCH 
    	{class:Label, as:l}-isLabelInGroup->{as:g, where:(group_name MATCHES '^'.append(getFirstWord($matched.l.label_name)).append('.*') AND group_name != $matched.l.label_name)}
    RETURN l.label_name as label_name, g.group_name as group_name
    ORDER BY group_name
    ```
    

### While

- Match all the artist whose name starts with the letter ‘M’ whose that has been influenced by artists whose name starts with the letter ‘M’

```cypher
MATCH 
	{class: Artist, as:a}.out('hasInfluenced'){while: (name MATCHES '^M.*'), where: (name MATCHES  '^M.*' AND $depth > 2) }
RETURN $pathElements
```

Notice that the meaning of the while here is a little bit misleading, because the while refers to the vertex on the left, so if we want that also this vertex on the right matches the condition of the first letter that should be an M, we also need to write the where condition for this vertex like this.

# Regular Path Queries

We can apply regular expressions also to obtain some regular path queries.

For instance, let’s suppose we want to:

- Find either the Songs or Albums whose name contains the words ‘best of’ of artists that has popularity greater or equal than 80:

```cypher
MATCH 
	{as:n, where:(name.toLowerCase() MATCHES '^.*best of.*$')}.outE(){as:r, where:(@class MATCHES "isSongOf|isAlbumOf")}.inV(){class:Artist, as:a, where:(popularity >= 80)}
RETURN DISTINCT a.name as artist_name, n.name as song_or_album_name, n.@class as class, a.popularity as artist_popularity ORDER BY artist_popularity DESC
```

This was a simple OR, but we could have write also a more complex regular expression, for instance this one:

```cypher
MATCH 
	{as:n, where:(name.toLowerCase() MATCHES '^.*best of.*$')}.outE(){as:r, where:(@class MATCHES "^is.*.Of$")}.inV(){class:Artist, as:a, where:(popularity >= 80)}
RETURN DISTINCT a.name as artist_name, n.name as song_or_album_name, n.@class as node_class, a.popularity as artist_popularity ORDER BY artist_popularity DESC
```
