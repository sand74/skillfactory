--Задание 4.1
--1:
select 
    city, 
    count(*)
from 
    dst_project.airports
group by 
    city
having
    count(*) > 1;
    
    
--Задание 4.2
--1:
select 
    count(distinct status)
from 
    dst_project.flights;
--2:
select 
    count(flight_id)
from 
    dst_project.flights
where
    status = 'Departed';
--3:
select 
    count(seat_no)
from 
    dst_project.seats
where
    aircraft_code = '773';
--4:
select 
    count(*)
from 
    dst_project.flights
where
    actual_arrival >= '2017-04-01' 
    and actual_arrival < '2017-09-01' 
    and status != 'Cancelled';


--адание 4.3
--1:
select 
    count(*)
from 
    dst_project.flights
where
    status = 'Cancelled';
--2:
with producer as (
    select 'Airbus' as producer_name, * from dst_project.aircrafts where model like ('Airbus%') 
    union
    select 'Boeing' as producer_name, * from dst_project.aircrafts where model like ('Boeing%') 
    union
    select 'Sukhoi Superjet' as producer_name, * from dst_project.aircrafts where model like ('Sukhoi Superjet%') 
)
select 
    p.producer_name, count(*)
from 
    producer p
group by p.producer_name;
--3:
select 
    substring(timezone from 0 for position('/' in timezone)) as part_of_world,
    count(airport_code)
from
    dst_project.airports
group by 1;
--4:
select 
    flight_id, 
    max(actual_arrival - scheduled_arrival) as delay
from
    dst_project.flights
group by flight_id
order by delay desc nulls last
limit 1;

--Задание 4.4
--1:
select 
    min(scheduled_departure) 
from 
    dst_project.flights;
--2:
select 
    max(extract(epoch from (scheduled_arrival - scheduled_departure))) / 60
from 
    dst_project.flights;
--3: Тут не совсем понятно - если PCS это ошибка от PKC, то ответ неоднозначен
select
       departure_airport, arrival_airport, status,
       max(scheduled_arrival - scheduled_departure) as total_time
from
    dst_project.flights
where status = 'Scheduled' and departure_airport in ('DME', 'SVO')
  and arrival_airport in ('UUS', 'AAQ', 'PCS')
group by
    departure_airport, arrival_airport, status
order by
    total_time desc
limit 1;
--4:
select 
    floor(avg(extract(epoch from (actual_arrival - actual_departure))) / 60)
from 
    dst_project.flights;
    
--Задание 4.5
--1:
select 
    fare_conditions, count(*) cnt
from 
    dst_project.seats
where
    aircraft_code = 'SU9'
group by 
    fare_conditions
order by
    cnt desc
limit 1;
--2:
select 
    min(total_amount) 
from
    dst_project.bookings;
--3:
select 
    seat_no
from 
    dst_project.tickets as t
    join dst_project.boarding_passes bp on t.ticket_no = bp.ticket_no
where
    passenger_id = '4313 788533';

--Задание 5.1
--1:
select 
    count(*) 
from 
    dst_project.airports a
    join dst_project.flights f on a.airport_code = f.arrival_airport
where 
    a.city = 'Anapa' 
    and date_part('year', actual_arrival) = 2017;
--2:
select 
    count(*) 
from 
    dst_project.airports a
    join dst_project.flights f on a.airport_code = f.departure_airport
where 
    a.city = 'Anapa' 
    and date_part('year', actual_departure) = 2017
    and date_part('month', actual_departure) in (1, 2, 12);
--3:
select 
    count(*)
from 
    dst_project.airports a
    join dst_project.flights f on a.airport_code = f.departure_airport
where 
    a.city = 'Anapa' 
    and f.status = 'Cancelled';
--4:
select 
    count(flight_id)
from 
    dst_project.flights f
    join dst_project.airports a1 on a1.airport_code = f.departure_airport
    join dst_project.airports a2 on a2.airport_code = f.arrival_airport
where 
    a1.city = 'Anapa' 
    and a2.city != 'Moscow';
--5:
with flight_seets as (
    select 
        f.flight_id, ac.model, count(*) cnt
    from 
        dst_project.flights f
        join dst_project.airports ap on ap.airport_code = f.departure_airport
        join dst_project.aircrafts ac on ac.aircraft_code = f.aircraft_code
        join dst_project.seats s on s.aircraft_code = f.aircraft_code
    where 
        ap.city = 'Anapa' 
    group by
        f.flight_id, ac.model
)
select 
    distinct model, cnt 
from 
    flight_seets
order by 
    cnt desc
limit 1;