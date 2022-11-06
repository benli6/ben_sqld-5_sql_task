SET search_path TO music_task;

-- создание базы
create table genre(
	genre_id serial primary key,
	genre_name varchar(25) not null
);

create table musician (
	musician_id serial primary key,
	musician_name varchar(50) not null
);

create table genre_musician(
	genre_id integer not null references genre(genre_id),
	musician_id integer not null references musician(musician_id),
	constraint pk_g_m primary key(genre_id, musician_id)
);

create table album(
	album_id serial primary key,
	album_name varchar(50) not null,
	album_date date 
);

create table album_musician(
	album_id integer not null references album(album_id),
	musician_id integer not null references musician(musician_id),
	constraint pk_a_m primary key(album_id, musician_id)
);

create table track(
	track_id serial primary key,
	track_name varchar(50) not null,
	duration integer not null,
	album_id integer not null references album(album_id)
);

create table collection(
	collection_id serial primary key,
	collection_name varchar(50) not null
);

create table track_collection(
	collection_id integer not null references collection(collection_id),
	track_id integer not null references track(track_id),
	constraint pk_t_c primary key(collection_id, track_id)
);


-- исправление ошибки в базе
alter table collection 
add collection_date date not null;


-- наполнение базы
insert into genre(genre_name)
select *
from unnest(
	array['Rock', 'Pop', 'Indie', 'Rap', 'Electronic']);
	
insert into musician(musician_name)
select *
from unnest(
	array['Rock-star', 'Pop-idol', 'Alt-j', 'RapIst', 'Sonic-Electronic', 'Rock-queen', 'Hip-Hop baby', 'Donut']
	);
	
insert into genre_musician(genre_id, musician_id)
select *
from unnest(
	array[1, 2, 3, 4, 5, 1, 4, 3, 2, 2, 3],
	array[1, 2, 3, 4, 5, 6, 7, 8, 8, 7, 1]
	);

insert into album(album_name, album_date)
select *
from unnest(
	array['Rock-album', 'Love Pop-idol', 'Breezeblocks', 'Best rap album', 'Sonic', 'Rock-n-roll on Mars', 'Hip-Hop bip-bop', 'Bubl ik'],
	array[DATE '2009-01-01', DATE '2008-10-13', DATE '2003-03-15', DATE '2014-04-08', DATE '2015-06-09', DATE '2018-06-22', DATE '2017-11-10', DATE '2018-12-31']
	);

insert into album_musician(album_id, musician_id)
select *
from unnest(
	array[1, 2, 3, 4, 5, 6, 7, 8, 1, 4, 7],
	array[1, 2, 3, 4, 5, 6, 7, 8, 6, 7, 2]
	);

insert into track(track_name, duration, album_id)
select *
from unnest(
	array['My rock song', 'My Love', 'Breezeblocks', 'Best rap song', 'Sony', 'On Mars', 'bip-bop', 'Bubble', 'Rock song 2', 'Hip-hop battle',
			'My heart', 'This is my rap', 'Electro hit', 'The longest rap', 'Oh my donut'],
	array[112, 222, 272, 204, 252, 261, 187, 138, 148, 157, 201, 234, 324, 458, 238],
	array[1, 2, 3, 4, 5, 6, 7, 8, 1, 4, 2, 4, 5, 4, 8]
	);

insert into collection(collection_name, collection_date)
select *
from unnest(
	array['Rock collection', 'Pop collection', 'Indie collection', 'Rap collection', 'Electro collection', 'Rock-n-roll collection', 'Hip-Hop collection', 'Bubble collection'],
	array[DATE '2019-05-05', DATE '2020-11-30', DATE '2013-03-25', DATE '2018-06-08', DATE '2015-06-19', DATE '2018-06-22', DATE '2021-11-10', DATE '2020-12-31']
	);

insert into track_collection(collection_id, track_id)
select *
from unnest(
	array[1, 1, 2, 2, 3, 4, 4, 5, 5, 6, 7, 8, 7],
	array[1, 9, 2, 11, 3, 4, 10, 5, 3, 6, 7, 8, 10]
	);


insert into album(album_name, album_date)
values ('Album #3', DATE '2020-06-06');

insert into album_musician(album_id, musician_id)
values (9, 8);

insert into track(track_name, duration, album_id)
values ('indie in the heart', 183, 9), ('Home', 167, 9), ('Lines', 211, 9);

insert into track_collection(collection_id, track_id)
select *
from unnest(
	array[3, 3, 3],
	array[16, 17, 18]
	);


-- SELECT-запросы
-- 1. название и год выхода альбомов, вышедших в 2018 году
select a.album_name, a.album_date 
from album a
where date_part('year', a.album_date) = 2018

-- 2. название и продолжительность самого длительного трека
select t.track_name, t.duration 
from track t 
where t.duration = (
	select max(duration) 
	from track
	);

-- 3. название треков, продолжительность которых не менее 3,5 минуты
select t.track_name
from track t 
where round(t.duration / 60, 2) >= 3.5

-- 4. названия сборников, вышедших в период с 2018 по 2020 год включительно
select c.collection_name
from collection c 
where date_part('year', c.collection_date) in (2018, 2019, 2020)

-- 5. исполнители, чье имя состоит из 1 слова
select m.musician_name 
from musician m 
where m.musician_name not like '% %' and m.musician_name not like '%-%'

-- 6. название треков, которые содержат слово "мой"/"my"
select t.track_name 
from track t 
where t.track_name like '%My%' or t.track_name like '%my%'



-- дополнительные select-запросы для оценки наполнения базы
select musician_name 
from musician m 
join genre_musician gm using(musician_id)
join genre g using(genre_id)
where genre_name = 'Rock';

select musician_name, album_name
from musician m 
join album_musician gm using(musician_id)
join album a using(album_id)
order by musician_name

select a.album_name, a.album_date, t.track_name 
from album a 
join track t using(album_id)
join track_collection tc using(track_id)
join collection c using(collection_id)
where c.collection_name = 'Rap collection'