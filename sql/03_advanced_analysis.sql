select *
from spotify_clean;

-- Audio Feature Analysis

-- audio feature common in top 10% songs
with popularity_percentile as (
select *, 
	ntile(10) over(order by popularity desc) as popularity_decile
from spotify_clean
)
select
	round(avg(danceability), 2) as avg_danceability,
    round(avg(energy), 2) as avg_energy,
    round(avg(loudness), 2) as avg_loudness,
    round(avg(acousticness), 2) as avg_acousticness,
    round(avg(instrumentalness), 2) as avg_instrumentalness,
    round(avg(liveness), 2) as avg_liveness,
    round(avg(valence), 2) as avg_valence
from popularity_percentile
where popularity_decile = 1;
    

-- songs that are outliers in duration
select track_name, artists, album_name,
	round(duration_ms / 60000, 2) as duration_min
from spotify_clean
where duration_ms > (
		select avg(duration_ms) + 2 * stddev(duration_ms)
        from spotify_clean
)
order by duration_ms desc;

-- songs with high danceability but low popularity
select track_name, artists, popularity, danceability
from spotify_clean
where danceability >= 0.80 and popularity <= 40
order by danceability desc, popularity;


-- popularity decile with highest avg duration
with popularity_grp as (
select *, 
	ntile(10) over(order by popularity desc) as popularity_decile
from spotify_clean
)
select track_name, 
	round(avg(duration_ms) / 60000, 2) as avg_duration_min,
    round(avg(popularity), 2) as avg_popularity
from popularity_grp
group by track_name
order by avg_duration_min desc;



-- top 3 artists within each genre

with artist_ranks as (
select track_genre, artists,
	round(avg(popularity), 2) as avg_popularity,
	dense_rank() over(
    partition by track_genre
    order by avg(popularity) desc
    ) as artist_rank
    from spotify_clean
    group by track_genre, artists
)
select *
from artist_ranks
where artist_rank <= 3
order by track_genre, artist_rank;


-- ranking songs within each album based on popularity
with track_ranks as (
	select album_name, artists, track_name, popularity,
		row_number() over(
			partition by album_name
            order by popularity desc
        ) as track_rank
        from spotify_clean
)
select *
from track_ranks
where track_rank = 1
order by popularity desc;

-- compare each song's popularity with the previous song
select track_name, artists, popularity,
	lag(popularity) over(
    order by popularity desc
    ) as prev_popularity
from spotify_clean;

-- compare each song's popularity with the next song
select track_name, artists, popularity,
	lead(popularity) over(
    order by popularity desc
    ) as nxt_popularity
from spotify_clean;


-- creating reusable view for highly popular songs
create view top_hits as 
select track_id, track_name, artists, album_name, track_genre, popularity
from spotify_clean
where popularity >= 80;

select *
from top_hits
order by popularity desc;


-- genres which have most hidden gems
select track_genre,
count(*) as hidden_gems
from spotify_clean
where danceability >= 0.8 and popularity <= 40
group by track_genre
order by hidden_gems desc
limit 10;



