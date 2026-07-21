SELECT * FROM spotify.tracks;

-- checing duplicates

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY track_id, artists, album_name, track_name, popularity, duration_ms, explicit, danceability, energy, `key`, loudness, `mode`, speechiness,
acousticness, instrumentalness, liveness, valence, tempo, time_signature, track_genre) AS row_num
FROM tracks_copy)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM tracks_copy
WHERE track_id = '040CvqW0wo3b77EBRfgC14';


CREATE TABLE `tracks_copy2` (
  `track_id` varchar(500) DEFAULT NULL,
  `artists` text,
  `album_name` text,
  `track_name` text,
  `popularity` int DEFAULT NULL,
  `duration_ms` int DEFAULT NULL,
  `explicit` varchar(500) DEFAULT NULL,
  `danceability` decimal(6,5) DEFAULT NULL,
  `energy` decimal(6,5) DEFAULT NULL,
  `key` int DEFAULT NULL,
  `loudness` decimal(7,3) DEFAULT NULL,
  `mode` int DEFAULT NULL,
  `speechiness` decimal(8,6) DEFAULT NULL,
  `acousticness` decimal(8,6) DEFAULT NULL,
  `instrumentalness` decimal(12,10) DEFAULT NULL,
  `liveness` decimal(8,6) DEFAULT NULL,
  `valence` decimal(8,6) DEFAULT NULL,
  `tempo` decimal(8,3) DEFAULT NULL,
  `time_signature` int DEFAULT NULL,
  `track_genre` varchar(100) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM tracks_copy2
WHERE row_num > 1;

INSERT INTO tracks_copy2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY track_id, artists, album_name, track_name, popularity, duration_ms, explicit, danceability, energy, `key`, loudness, `mode`, speechiness,
acousticness, instrumentalness, liveness, valence, tempo, time_signature, track_genre) AS row_num
FROM tracks_copy;

DELETE
FROM tracks_copy2
WHERE row_num > 1;

SELECT COUNT(*) AS total_records
FROM tracks_copy2;

-- standardize text
SELECT artists, TRIM(artists), album_name, TRIM(album_name), track_name, TRIM(track_name), track_genre, TRIM(track_genre)
FROM tracks_copy2;

UPDATE tracks_copy2
SET artists = TRIM(artists), album_name = TRIM(album_name), track_name = TRIM(track_name), track_genre = TRIM(track_genre);

SELECT DISTINCT artists
FROM tracks_copy2
ORDER BY 1;

SELECT DISTINCT album_name
FROM tracks_copy2
ORDER BY 1;

SELECT DISTINCT track_name
FROM tracks_copy2
ORDER BY 1;

SELECT DISTINCT track_genre
FROM tracks_copy2
ORDER BY 1;

-- converting blanks to nulls
UPDATE tracks_copy2
SET
    artists = NULLIF(TRIM(artists), ''),
    album_name = NULLIF(TRIM(album_name), ''),
    track_name = NULLIF(TRIM(track_name), '');

SELECT *
FROM tracks_copy2
WHERE track_id = '1kR4gIb7nGxHPI3D2ifs59';


-- removing nulls
DELETE
FROM tracks_copy2
WHERE artists IS NULL OR album_name IS NULL OR track_name IS NULL;


SELECT *
FROM tracks_copy2;


-- checking if the data is out of range
SELECT *
FROM tracks_copy2
WHERE popularity NOT BETWEEN 0 AND 100
   OR duration_ms <= 0
   OR danceability NOT BETWEEN 0 AND 1
   OR energy NOT BETWEEN 0 AND 1
   OR speechiness NOT BETWEEN 0 AND 1
   OR acousticness NOT BETWEEN 0 AND 1
   OR instrumentalness NOT BETWEEN 0 AND 1
   OR liveness NOT BETWEEN 0 AND 1
   OR valence NOT BETWEEN 0 AND 1
   OR mode NOT IN (0,1);
   
ALTER TABLE tracks_copy2
DROP COLUMN row_num;

RENAME TABLE tracks_copy2 TO spotify_clean;

UPDATE spotify_clean
SET
	artists = REPLACE(artists, ',', '-'),
    album_name = REPLACE(album_name, ',', ' - '),
    track_name = REPLACE(track_name, ',', ' - ');


UPDATE spotify_clean
SET
	track_name = REPLACE(track_name, '"', ''),
    artists = REPLACE(artists, '"', ''),
    album_name = REPLACE(album_name, '"', ''),
    album_name = REPLACE(album_name, '+', '');
