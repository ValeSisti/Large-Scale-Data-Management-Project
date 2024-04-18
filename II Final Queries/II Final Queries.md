# II Final Queries

## Query 1

- Albums of artists with more than 500k followers that contain Songs that are present in the Billboard Hot 100 Chart at least 10 years after their release
    
    
    ```sql
    SELECT DISTINCT al.name as album_name, ar.name as artist_name, s.name as song_name, 
                   al.release_date, bhs.date as billboard_date, bhs.peak_rank, bhs.rank
    FROM albums as al, artists as ar, is_album_of as iao, is_song_in_album as isia, 
         songs as s, billboard_hot100_songs as bhs
    WHERE al.id = iao.album_id AND
          ar.id = iao.artist_id AND
          al.id = isia.album_id AND
          s.id = isia.track_id AND
          s.id = bhs.track_id AND
          (DATE_PART('year', bhs.date) - DATE_PART('year', al.release_date)) >= 10 AND
          ar.followers > 500000 AND
          al.album_type = 'album'
    ORDER BY al.release_date DESC
    ```
    

## Query 2

- Acousticness, danceability, energy and loudness of Songs of Artists that do the “rock” Genre and that reached the #1 of the Billboard Hot 100 Chart
    
    ```sql
    SELECT DISTINCT s.name as song_name, ar.name as artist_name, af.acousticness, af.danceability, af.energy, af.loudness, bhs.rank, bhs.date as date
    FROM artists as ar, songs as s, is_song_of as iso, billboard_hot100_songs as bhs, does_genre as dg, audio_features as af
    WHERE ar.id = iso.artist_id AND
          s.id = iso.track_id AND
          s.id = bhs.track_id AND
          dg.artist_id = ar.id AND
          af.track_id = s.id AND
          dg.genre = 'rock' AND
          bhs.rank = 1
    ORDER BY date DESC
    ```
    

## Query 3

- Top 2 songs on Billboard in the same week of two different artists that belong to two different labels but of the same Group of labels

```sql
SELECT DISTINCT ar1.name as artist1_name, s1.name as song_name, bhs1.rank as s1_rank, ar2.name as artist2_name, s2.name as song2_name, bhs2.rank as s2_rank2, ilig1.group_name, bhs1.date as date
FROM billboard_hot100_songs as bhs1, billboard_hot100_songs as bhs2, is_song_of as iso1, is_song_of as iso2,
	 songs as s1, songs as s2, artists as ar1, artists as ar2, has_label as hl1, has_label as hl2,
	 is_label_in_group as ilig1, is_label_in_group as ilig2
WHERE bhs1.rank = 1 AND 
	  bhs2.rank = 2 AND
	  bhs1.track_id = s1.id AND
	  bhs2.track_id = s2.id AND
	  iso1.track_id = s1.id AND
	  iso2.track_id = s2.id AND
	  iso1.artist_id = ar1.id AND
	  iso2.artist_id = ar2.id AND
	  hl1.artist_id = iso1.artist_id AND
	  hl2.artist_id = iso1.artist_id AND
	  ilig1.label_name = hl1.label_name AND
	  ilig2.label_name = hl2.label_name AND
	  ilig1.group_name = ilig2.group_name AND
	  ar1.id != ar2.id AND
	  hl1.label_name != hl2.label_name AND
	  bhs1.date = bhs2.date
ORDER BY date
```

## Query 4

- Albums that contain a song that is a featuring between “Machine Gun Kelly” and another artists who belongs to his same label
    
    ```sql
    SELECT DISTINCT ar2.name as artist_name, s.name as song_name, al.name as album_name, ar3.name as album_of, al.release_date
    FROM is_song_of AS iso1, is_song_of AS iso2, artists AS ar1, artists AS ar2, has_label AS hl1, has_label AS hl2,
         songs as s, albums as al, is_song_in_album as isia, is_album_of as iao, artists as ar3
    WHERE ar1.name = 'Machine Gun Kelly' AND
          ar1.id = iso1.artist_id  AND
          iso1.artist_id != iso2.artist_id AND
          iso1.track_id = iso2.track_id AND
          iso1.track_id = s.id AND
          iso1.track_id = isia.track_id AND
          isia.album_id = al.id AND
    		  isia.album_id = iao.album_id AND
    		  iao.artist_id = ar3.id AND
          ar2.id = iso2.artist_id AND
          hl1.artist_id = iso1.artist_id AND
          hl2.artist_id = iso2.artist_id AND
          hl1.label_name = hl2.label_name
    ```
    

## Query 5

- Artists that have been influenced by “Nirvana” and that have done a featuring with each other that reached the Billboard Hot 100 Chart
    
    ```sql
    SELECT DISTINCT s.name as song_name, ar1.name as ar1_name, ar2.name as ar2_name, bhs.peak_rank
    FROM has_influenced as hi1, has_influenced as hi2, is_song_of as iso1, is_song_of as iso2, artists as ar1, artists as ar2, songs as s, artists as influencer_artist,
    billboard_hot100_songs as bhs
    WHERE influencer_artist.name = 'Nirvana' AND
    		  hi1.influencer_id = influencer_artist.id AND
    		  hi2.influencer_id = influencer_artist.id AND
    		  hi1.follower_id != hi2.follower_id AND
    		  iso1.artist_id = hi1.follower_id AND
    		  iso2.artist_id = hi2.follower_id AND
    		  iso1.track_id = iso2.track_id AND
    		  iso1.track_id = s.id AND
    		  hi1.follower_id = ar1.id AND
    		  hi2.follower_id = ar2.id AND
    		  iso1.track_id = bhs.track_id
    ```
    

## Query 6

- Lyrics of songs with popularity ≥ 80, of artists with popularity ≥ 80, that do either “alternative rock”, or “alternative metal”, or “punk” music genres
    
    ```sql
    (SELECT DISTINCT ar.name as artist_name, ar.popularity as artist_popularity, s.name as song_name, s.popularity as song_popularity, hl.lyrics
    FROM songs as s, artists as ar, is_song_of as iso, has_lyrics as hl, does_genre as dg
    WHERE ar.popularity >= 80 AND
    	  iso.artist_id = ar.id AND
    	  iso.track_id = s.id AND
    	  s.popularity >= 80 AND
    	  iso.artist_id = dg.artist_id AND
    	  dg.genre = 'alternative rock' AND
    	  hl.track_id = s.id
    ) 
    UNION
    (SELECT DISTINCT ar.name as artist_name, ar.popularity as artist_popularity, s.name as song_name, s.popularity as song_popularity, hl.lyrics
    FROM songs as s, artists as ar, is_song_of as iso, has_lyrics as hl, does_genre as dg
    WHERE ar.popularity >= 80 AND
    	  iso.artist_id = ar.id AND
    	  iso.track_id = s.id AND
    	  s.popularity >= 80 AND
    	  iso.artist_id = dg.artist_id AND
    	  dg.genre = 'alternative metal' AND
    	  hl.track_id = s.id
    )
    UNION
    (SELECT DISTINCT ar.name as artist_name, ar.popularity as artist_popularity, s.name as song_name, s.popularity as song_popularity, hl.lyrics
    FROM songs as s, artists as ar, is_song_of as iso, has_lyrics as hl, does_genre as dg
    WHERE ar.popularity >= 80 AND
    	  iso.artist_id = ar.id AND
    	  iso.track_id = s.id AND
    	  s.popularity >= 80 AND
    	  iso.artist_id = dg.artist_id AND
    	  dg.genre = 'punk' AND
    	  hl.track_id = s.id
    ) ORDER BY artist_name
    ```