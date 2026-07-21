SELECT *
FROM spotify_clean;

-- Dataset Overview
-- total unique artists
select count(distinct artists) as total_artists, count(distinct album_name) as total_albums, count(distinct track_genre) as total_genres
from spotify_clean;

-- popularity statistics
select min(popularity) as least_popular, 
max(popularity) as most_popular,
round(avg (popularity), 2) as avg_popularity
from spotify_clean;

-- song durn statistics
select round(min(duration_ms) / 60000, 2) as shortest_song_min,
round(max(duration_ms) / 60000, 2) as longest_song_min,
round(avg(duration_ms) / 60000, 2) as avg_length_min
from spotify_clean;

-- explicit vs non-explicit songs
select 
	explicit,
    count(*) as total_tracks,
    round(count(*) * 100 / (select count(*) from spotify_clean), 2) as percentage
from spotify_clean
group by explicit;

-- top 10 most popular songs
with ranked_songs as(
select *,
	row_number() over(partition by track_id order by popularity desc) as row_num
from spotify_clean
)
select artists, album_name, track_name
from ranked_songs
where row_num = 1
order by popularity desc
limit 10;



-- Genre Analysis

-- highest avg popularity
select track_genre, count(*) as total_tracks,
round(avg (popularity), 2) as avg_popularity
from spotify_clean
group by track_genre
order by avg_popularity desc
limit 10;

-- genre with highest listner engagement
select track_genre, 
round(avg(danceability), 2) as dance,
round(avg(energy), 2) as avg_energy,
round(avg(valence), 2) as avg_valence
from spotify_clean
group by track_genre
order by avg_energy desc;

-- genres that have greatest diversity of artists
select track_genre, count(distinct artists) as unique_artists
from spotify_clean
group by track_genre
order by unique_artists desc;

-- genres that have highest explicit percentage
with genre_explicit as(
select track_genre, 
	count(*) as total_tracks,
    sum(explicit = 'TRUE') as explicit_tracks
from spotify_clean
group by track_genre
)
select track_genre, total_tracks, explicit_tracks, 
    round(explicit_tracks * 100.0 / total_tracks, 2) as explicit_percentage
from genre_explicit
group by track_genre
order by explicit_percentage desc;


-- Artist Analysis

-- artists mainting high popularity across multiple releases
with artist_stats as (
	select artists,
		count(distinct track_id) as total_tracks,
        round(avg(popularity), 2) as avg_popularity,
        max(popularity) as highest_popularity,
        min(popularity) as lowest_popularity
	from spotify_clean
    group by artists
)
select dense_rank() over(order by avg_popularity desc) as artist_rank, 
	artists, total_tracks, avg_popularity, highest_popularity, lowest_popularity
from artist_stats
where total_tracks >= 5
limit 20;

-- artists who released highest number of unique ranks
select artists, count(distinct track_id) as unique_tracks
from spotify_clean
group by artists
order by unique_tracks desc
limit 50;

-- artists with greatest diversity across genres
select artists, count(distinct track_genre) as total_genre
from spotify_clean
group by artists
order by total_genre desc;


-- artists with highest popularity within each genre
with artist_genre_stats as (
	select track_genre, artists,
		round(avg(popularity), 2) as avg_popularity,
        row_number() over(
						partition by track_genre 
                        order by avg(popularity) desc) as row_num
	from spotify_clean
    group by track_genre, artists
)
select *
from artist_genre_stats
where row_num = 1
order by avg_popularity desc
limit 10;

-- Track Analysis

select *
from spotify_clean;

-- albums with multiple hit songs
with album_hits as (
select track_id, album_name, artists, popularity
from spotify_clean
where popularity >= 80
)
select album_name, artists,
	count(track_id) as hit_tracks, round(avg(popularity), 2) as avg_popularity
from album_hits
group by album_name, artists
having count(track_id) >= 2
order by hit_tracks desc, avg_popularity desc;

-- influence of explicity on popularity
select explicit, 
	count(*) as total_tracks,
    round(avg(popularity), 2) as avg_popularity,
    max(popularity) as highest_popularity
from spotify_clean
group by explicit;

-- album having highest hit songs
select album_name, artists,
	count(distinct track_id) as total_hits
from spotify_clean
where popularity >= 80
group by album_name, artists
having count(distinct track_id) > 2
order by total_hits desc;

-- song distribution across popularity
select
	case
		when popularity >= 80 then 'Hit'
        when popularity >= 60 then 'Popular'
        when popularity >= 40 then 'Moderate'
        else 'Flop'
	end as popularity_category,
    count(*) as total_tracks,
    round(avg(danceability), 2) as avg_danceability,
    round(avg(energy), 2) as avg_energy
from spotify_clean
group by popularity_category
order by total_tracks desc;

