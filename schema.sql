CREATE DATABASE hummer;

CREATE TABLE hums (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    text CHAR(220),
    created_at TIMESTAMPTZ

);

CREATE TABLE users (

    id SERIAL PRIMARY KEY,
    email TEXT,
    password_digest TEXT,
    username TEXT,
    display_name TEXT,
    tagline TEXT,
    photo_url TEXT,
    date_of_birth DATE,
    created_at TIMESTAMPTZ
);

ALTER TABLE users ADD photo_url TEXT, header_photo_url TEXT, date_of_birth, created_at TIMESTAMPTZ;

CREATE TABLE likes (

    id SERIAL PRIMARY KEY,
    tweet_id INTEGER,
    user_id INTEGER

);

CREATE TABLE follows (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    followed_id INTEGER

);

INSERT INTO hums (user_id,text,created_at) VALUES (1,'The first hum in the world!','2021-06-07 16:43:25-07');


INSERT INTO follows(user_id, followed_id) VALUES (1,1), (2,2), (3,3), (4,4), (5,5), (6,6), (7,7);



SELECT hums.id, hums.user_id AS author_id, text, created_at, (SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count, (SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = 2 AND hums.id = likes.hum_id) AS user_like FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id WHERE follows.user_id = 2 ORDER BY created_at DESC;



(SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = 2) AS user_like


select hums.id, hums.user_id AS author_id, count(likes.user_id) AS likes, text, created_at 

from hums 

inner join follows on hums.user_id = follows.followed_id 
inner join likes on likes.hum_id = hums.id 


where (follows.user_id = 2) group by hums.id order by created_at DESC;


ALTER TABLE users ADD photo_url TEXT, header_photo_url TEXT, date_of_birth, created_at TIMESTAMPTZ;


-- trying to add hums of those of people that were liked by the users that the logged_in_user follows.
SELECT hums.id, hums.user_id AS author_id, text, hums.created_at, (SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count, (SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = $1 AND hums.id = likes.hum_id) AS user_like, users.display_name, users.username FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id INNER JOIN users ON users.id = hums.user_id WHERE follows.user_id = $2 ORDER BY created_at DESC;



SELECT DISTINCT hums.id, hums.user_id AS author_id, text, hums.created_at, (extract(epoch from now()::timestamp - hums.created_at::timestamp)) AS hum_age, (SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count, (SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = $1 AND hums.id = likes.hum_id) AS user_like, users.display_name, users.username, users.photo_url FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id INNER JOIN users ON users.id = hums.user_id WHERE hums.user_id = $2 ORDER BY created_at DESC;


SELECT DISTINCT hums.id, hums.user_id AS author_id, text, hums.created_at, (extract(epoch from now()::timestamp - hums.created_at::timestamp)) AS hum_age, (SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count, (SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = 1 AND hums.id = likes.hum_id) AS user_like, users.display_name, users.username, users.photo_url FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id INNER JOIN users ON users.id = hums.user_id WHERE hums.user_id = 1 ORDER BY created_at DESC;




SELECT DISTINCT 
hums.id, 
hums.user_id AS author_id, 
text, hums.created_at, 
(extract(epoch from now()::timestamp - hums.created_at::timestamp)) AS hum_age, 
(SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count, 
(SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = $1 AND hums.id = likes.hum_id) AS user_like, 
users.display_name, 
users.username, 
users.photo_url 

FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id 
INNER JOIN users ON users.id = hums.user_id 
ORDER BY created_at DESC;


SELECT
    hums.id,
    hums.user_id AS author_id,
    hums.text,
    (extract(epoch from now()::timestamp - hums.created_at::timestamp)) AS age,
    (SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count,
    (SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = $1 AND hums.id = likes.hum_id) AS user_like,
    users.display_name,
    users.username,
    users.photo_url

    FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id
    INNER JOIN users ON users.id = hums.user_id
    WHERE follows.user_id = (current_user()['id'])
    ORDER BY age DESC;


SELECT DISTINCT
    hums.id,
    hums.user_id AS author_id,
    hums.text,
    (extract(epoch from now()::timestamp - hums.created_at::timestamp)) AS age,
    (SELECT count(likes.hum_id) FROM likes WHERE likes.hum_id = hums.id) AS like_count,
    (SELECT count(likes.hum_id) FROM likes WHERE likes.user_id = 1 AND hums.id = likes.hum_id) AS user_like,
    users.display_name,
    users.username,
    users.photo_url

    FROM hums INNER JOIN follows ON follows.followed_id = hums.user_id
    INNER JOIN users ON users.id = hums.user_id
    WHERE follows.user_id = 1
    ORDER BY age DESC;


UPDATE users
SET photo_url = 'images/seed/teresa.jpg'
WHERE id = 7;