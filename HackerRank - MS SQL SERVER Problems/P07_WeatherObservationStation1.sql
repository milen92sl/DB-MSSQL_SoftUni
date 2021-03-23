CREATE TABLE Station
(
    ID     INT IDENTITY PRIMARY KEY,
    CITY   VARCHAR(21) NOT NULL,
    STATE  VARCHAR(2)  NOT NULL,
    LAT_N  INT         NOT NULL,
    LONG_W INT         NOT NULL
)

SELECT CITY, STATE
    FROM Station