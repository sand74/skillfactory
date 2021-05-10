SELECT DISTINCT f.flight_id,
                f.scheduled_departure,
                f.departure_airport,
                f.arrival_airport,
                f.aircraft_code,
                extract(epoch FROM age(f.actual_arrival::TIMESTAMP, f.actual_departure::TIMESTAMP)) / 60 AS flight_duration_minutes,
                (SELECT count(*)
                 FROM dst_project.seats s
                 WHERE s.aircraft_code = f.aircraft_code) AS total_seats,
                (SELECT count(*)
                 FROM dst_project.seats s
                 WHERE s.aircraft_code = f.aircraft_code
                   AND s.fare_conditions = 'Economy') AS economy_seats_cnt,
                (SELECT count(*)
                 FROM dst_project.seats s
                 WHERE s.aircraft_code = f.aircraft_code
                   AND s.fare_conditions = 'Business') AS business_seats_cnt,
                coalesce(count(tf.ticket_no) OVER (PARTITION BY f.flight_id), 0) AS total_tickets,
                sum(CASE
                        WHEN tf.fare_conditions = 'Economy' THEN 1
                        ELSE 0
                    END) OVER (PARTITION BY f.flight_id) AS economy_tickets_cnt,
                sum(CASE
                        WHEN tf.fare_conditions = 'Business' THEN 1
                        ELSE 0
                    END) OVER (PARTITION BY f.flight_id) AS business_tickets_cnt,
                coalesce(sum(tf.amount) OVER (PARTITION BY f.flight_id), 0) AS total_amount,
                sum(CASE
                        WHEN tf.fare_conditions = 'Economy' THEN tf.amount
                        ELSE 0
                    END) OVER (PARTITION BY f.flight_id) AS economy_tickets_amount,
                sum(CASE
                        WHEN tf.fare_conditions = 'Business' THEN tf.amount
                        ELSE 0
                    END) OVER (PARTITION BY f.flight_id) AS business_tickets_amount
FROM dst_project.flights AS f
         LEFT OUTER JOIN dst_project.ticket_flights tf ON f.flight_id = tf.flight_id
         JOIN dst_project.aircrafts a ON a.aircraft_code = f.aircraft_code
WHERE f.departure_airport = 'AAQ'
  AND (date_trunc('month', f.scheduled_departure) in ('2017-01-01',
                                                      '2017-02-01',
                                                      '2017-12-01'))
  AND f.status not in ('Cancelled')