set search_path to music_task;


-- 1. количество исполнителей в каждом жанре
select g.genre_name, count(gm.musician_id) as "Musicians"
from genre g 
join genre_musician gm  using (genre_id)
group by 1
order by 2 desc, 1;


-- 2. количество треков, вошедших в альбомы 2019-2020 годов)
select count(track_id) as "Tracks in 2019-2020"
from album a 
join track t using (album_id)
where date_part('year', a.album_date) between 2019 and 2020;


-- 3. средняя продолжительность треков по каждому альбому
-- сложные маневры по переводу секунд в формат mm:ss. более простого способа придумать не удалось
select a.album_name, cast(floor(avg(t.duration) / 60) as text) || ':' || 
	right('00' || cast(floor(avg(t.duration)) % 60 as text), 2) as "Avg duration"
from album a 
join track t using (album_id)
group by 1
order by 2 desc;

-- просто вывод среднего в секундах
select a.album_name, avg(t.duration) as "Avg duration"
from album a 
join track t using (album_id)
group by 1
order by 2 desc;


-- 4. все исполнители, которые не выпустили альбомы в 2020 году);
select distinct(m.musician_name) 
from musician m 
join album_musician am using(musician_id)
join album a using(album_id)
where m.musician_name not in (
	select distinct(m.musician_name) 
	from musician m 
	join album_musician am using(musician_id)
	join album a using(album_id)
	where date_part('year', a.album_date) = 2020
)
order by 1;


-- 5. названия сборников, в которых присутствует конкретный исполнитель (выберите сами)
select distinct(c.collection_name) 
from collection c 
join track_collection tc using(collection_id)
join track t using(track_id)
join album a using(album_id)
join album_musician am using(album_id)
join musician m using(musician_id)
where m.musician_name = 'RapIst'
order by 1;


-- 6. название альбомов, в которых присутствуют исполнители более 1 жанра
select a.album_name
from album a 
join album_musician am using(album_id)
where am.musician_id in (
	select musician_id
	from genre_musician gm 
	group by musician_id
	having count(musician_id) > 1	
)
order by 1;


-- 7. наименование треков, которые не входят в сборники
select t.track_name
from track t 
left join track_collection tc using(track_id)
where tc.collection_id is null 


-- 8. исполнителя(-ей), написавшего самый короткий по продолжительности трек (теоретически таких треков может быть несколько)
select m.musician_name
from musician m 
join album_musician am using(musician_id)
join track t using(album_id)
where t.duration = (
	select min(duration) 
	from track
);


-- 9. название альбомов, содержащих наименьшее количество треков
select a.album_name 
from album a 
where album_id in (
	select album_id 
	from track t 
	group by album_id
	having count(track_id) = (
		select count(track_id) 
		from track 
		group by album_id
		order by 1
		limit 1)
);
	
