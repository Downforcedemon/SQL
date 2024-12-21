-- Table: signup_events
CREATE TABLE signup_events (
    RIDER_ID VARCHAR2(50),
    CITY_ID VARCHAR2(50),
    EVENT_NAME VARCHAR2(50),
    TIMESTAMP TIMESTAMP
);

-- Insert sample data
INSERT INTO signup_events VALUES ('r1', 'c1', 'su_success', TO_TIMESTAMP('2022-01-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO signup_events VALUES ('r2', 'c1', 'su_success', TO_TIMESTAMP('2022-01-02 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Table: trip_details
CREATE TABLE trip_details (
    ID VARCHAR2(50),
    CLIENT_ID VARCHAR2(50),
    CITY_ID VARCHAR2(50),
    STATUS VARCHAR2(50),
    REQUEST_AT TIMESTAMP
);

-- Insert sample data
INSERT INTO trip_details VALUES ('t1', 'r1', 'c1', 'completed', TO_TIMESTAMP('2022-01-05 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO trip_details VALUES ('t2', 'r2', 'c1', 'completed', TO_TIMESTAMP('2022-01-10 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));

COMMIT;


--filter signups in first 7 days of 2022
SELECT RIDER_ID, CITY_ID, CAST(TIMESTAMP AS DATE) AS SIGNUP_DATE
FROM signup_events
WHERE EVENT_NAME = 'su_success'
  AND TIMESTAMP >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
  AND TIMESTAMP < TO_DATE('2022-01-08', 'YYYY-MM-DD');

--find trips completed between 168 hours
SELECT t.CLIENT_ID,t.CITY_ID,t.STATUS,t.REQUEST_AT
from TRIP_DETAILS t 
where t.STATUS = 'completed';

---- client id matches with rider_id
---- calcualte if trip_details request_at is within 168 hours of sign_date

WITH SuccessfulSignups AS (
    SELECT RIDER_ID, CITY_ID, CAST(TIMESTAMP AS DATE) AS SIGNUP_DATE
    FROM signup_events
    WHERE EVENT_NAME = 'su_success'
      AND TIMESTAMP >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
      AND TIMESTAMP < TO_DATE('2022-01-08', 'YYYY-MM-DD')
),
TripsWithin168Hours AS (
    SELECT t.CLIENT_ID, t.CITY_ID, t.REQUEST_AT
    FROM trip_details t
    WHERE t.STATUS = 'completed'
),
SignupWithTrips AS (
    SELECT s.CITY_ID, s.SIGNUP_DATE, COUNT(t.CLIENT_ID) AS CompletedTrips, COUNT(s.RIDER_ID) AS TotalSignups
    FROM SuccessfulSignups s
    LEFT JOIN TripsWithin168Hours t
    ON s.RIDER_ID = t.CLIENT_ID
       AND t.REQUEST_AT BETWEEN s.SIGNUP_DATE AND s.SIGNUP_DATE + INTERVAL '7' DAY
    GROUP BY s.CITY_ID, s.SIGNUP_DATE
)
SELECT CITY_ID, SIGNUP_DATE, 
       (CompletedTrips * 100.0 / TotalSignups) AS SUCCESS_PERCENTAGE
FROM SignupWithTrips;

-- psuedocode
SuccessfulSignups CTE:

    Filters signup_events to get only successful signups (su_success) that occurred in the first 7 days of 2022.

TripsWithin168Hours CTE:

    Filters trip_details to get only completed trips (status = 'completed').

SignupWithTrips CTE:

    Joins SuccessfulSignups with TripsWithin168Hours to find trips completed within 7 days (168 hours) of a signup.
    Groups the data by city and signup date to count both completed trips and total signups.

Final Query:

    Uses SignupWithTrips to calculate the success percentage of signups that completed trips within 7 days.
