--lab0619

--1. Создайте последовательность.
CREATE SEQUENCE ID_Generator
    INCREMENT BY 1
    START WITH 1
    NOMAXVALUE
    NOCYCLE;

--2. Добавьте в схему базы данных, разработанную Вами в лабораторной работе №1, новую сущность. Создайте для этой сущности таблицу (таблицы). Причем, поле этой таблицы с ограничением первичного ключа должно заполняться с помощью последовательности. Заполните таблицу данными.
CREATE TABLE
    RaceAreas
    (
        RaceArea_ID NUMBER(10) PRIMARY KEY,
        RaceArea_Address VARCHAR2(300) NOT NULL,
        RaceArea_MaxNumOfGuests NUMBER(10) NOT NULL
            CHECK (RaceArea_MaxNumOfGuests > 0),
        RaceArea_Square NUMBER(10) --in hectares
            CHECK (RaceArea_Square > 0)
    );

CREATE SEQUENCE RaceArea_ID_Generator
    INCREMENT BY 1
    START WITH 1
    NOMAXVALUE
    NOCYCLE;

INSERT INTO RaceAreas VALUES
    (RaceArea_ID_Generator.NEXTVAL, 'Knighton, Powys LD7 1DL, United Kingdom', 1500, 3000);

INSERT INTO RaceAreas VALUES
    (RaceArea_ID_Generator.NEXTVAL, 'Ketley Bank, Telford, Telford and Wrekin TF2 0EB, United Kingdom', 10000, 10000);

CREATE TABLE
    Events
    (
        Event_ID NUMBER(10) PRIMARY KEY,
        Competition_ID NUMBER(10) NOT NULL REFERENCES Competitions(Competition_ID),
        RaceArea_ID NUMBER(10) NOT NULL REFERENCES RaceAreas(RaceArea_ID),
        Event_NumOfGuests NUMBER(10)
    );

CREATE SEQUENCE Event_ID_Generator
    INCREMENT BY 1
    START WITH 1
    NOMAXVALUE
    NOCYCLE;

INSERT INTO Events VALUES
    (Event_ID_Generator.NEXTVAL, 1, 1, 1000);

ALTER TABLE Competitions
    DELETE (Competition_Area);

--3. Создайте индексы для тех полей базы данных, для которых это необходимо (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 12 Working with Sequences).
CREATE INDEX jockey_name_ind
    ON Jockey(Jockey_Name);

CREATE INDEX horses_jockey_owner_ind
    ON Horses(Jockey_ID, Owner_ID);

CREATE INDEX owner_name_ind
    ON Owners(Owner_Name);

CREATE INDEX results_horse_race_ind
    ON Results(Horse_ID, Race_ID);

CREATE INDEX competition_name_ind
    ON Competitions(Competition_Name);

CREATE INDEX events_competition_racearea_ind
    ON Events(Competition_ID, RaceArea_ID);

CREATE INDEX racearea_guests_ind
    ON RaceAreas(RaceArea_MaxNumOfGuests);

--4. В одну из таблиц добавьте поле (внешний ключ), значения которого ссылаются на поле – первичный ключ этой таблицы (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 8 Working with DDL Statements). Составьте запросы на выборку данных с использованием рефлексивного соединения (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 3 Executing Database Joins\Self Joins and Hierarchical Queries).
ALTER TABLE Events
    ADD (Competition_ID NUMBER(10));

ALTER TABLE Events
    ADD (Competition_ID NUMBER(10) NOT NULL REFERENCES Competitions(Competition_ID));

-- добавим в таблицу Resuts иерархию - какая лошадь после какой финишировала
ALTER TABLE Results
    ADD (Results_HorseIDBefore NUMBER(10));

-- выберем лошадь, которая финишировала перед заданной
SELECT horsePrev.Horse_ID
    FROM Results horsePrev INNER JOIN Results horsePast
    ON horsePrev.Horse_ID = horsePast.Results_HorseIDBefore;

--Составьте запросы на выборку данных с использованием следующих операторов, конструкций и функций языка SQL:
--5. простого оператора CASE ();
-- сгруппировать жокеев по росту (группы до 150, 151-160, 161-170, 171-180, выше 181)
SELECT Jockey_Name, Jockey_Weight,
    CASE Jockey_Height
        WHEN <=150
            THEN 'Up to 150'
        WHEN BETWEEN 151 AND 160
            THEN '151-160'
        WHEN BETWEEN 161 AND 170
            THEN '161-170'
        WHEN BETWEEN 171 AND 180
            THEN '171-180'
        ELSE '181 or higher'
    END
    AS Jockey_Height_Group
    FROM Jockeys;

--6. поискового оператора CASE();
-- вывести список лошадей, отсортированных по полу (его обозначить Male, Female)
SELECT Horse_ID, Horse_Name, Horse_DateOfBirthe,
    CASE
        WHEN Horse_Gender = 'M' THEN 'Male'
        ELSE 'Female'
    END
    AS Horse_Gender_Full,
    FROM Horses
    ORDER BY Horse_Gender_Full;

--7. оператора WITH();
-- выбрать лошадей-победителей маленьких соревнований (состоящих из одного заезда)
WITH LittleCompetitions AS
    (SELECT Competition_ID
        FROM Competitions
        WHERE Competition_NumberOfRaces = 1)
SELECT res.Horse_ID
    FROM Results res NATURAL JOIN Races r
    WHERE r.Competition_ID IN
        (SELECT *
        FROM LittleCompetitions) AND
        res.Race_HorsePlace = 1;

--8. встроенного представления();
-- выбрать результаты лошадей, на которых ездят очень низкие жокеи (<=150) и очень высокие (>=190)
SELECT h.Horse_Name, nonStandartJoe.Height, r.Race_HorsePlace
    FROM Results r
    NATURAL JOIN Horses h
    NATURAL JOIN (SELECT Jockey_ID, Jockey_Height FROM Jockeys WHERE Jockey_Height <=150 OR Jockey_Height >=190) nonStandartJoe
    GROUP BY nonStandartJoe.Height, r.Race_HorsePlace, h.Horse_Name;

--9. некоррелированного запроса((academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 6 Creating Subqueries).);
-- выбрать лошадей, которые когда-либо участвовали в соревнованиях
SELECT *
    FROM Horses
    WHERE Horse_ID IN
        (SELECT Horse_ID
            FROM Results
            GROUP BY Horse_ID)
    ORDER BY Horse_Name;

--10. коррелированного запроса(academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 6 Creating Subqueries).);
-- найти соревнования, на которых присутствовало число гостей, равное максимально возможному для арены соревнований
SELECT c.Competition_Name
    FROM Competitions c
    NATURAL JOIN Events e
    WHERE e.RaceArea_ID IN
        (SELECT RaceArea_ID
            FROM RaceAreas
            WHERE RaceArea_MaxNumOfGuests = e.Event_NumOfGuests)l

--11. функции NULLIF (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 2 Using Single-Row Functions);
-- вывести список всех лошадей, скрыв пол у женских особей
SELECT Horse_ID, Horse_Name, NULLIF(Horse_Gender, 'F') AS Gender, Horse_DateOfBirth
    FROM Horses;

--12. функции NVL2 (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 2 Using Single-Row Functions);
-- вывести соревнования с количество гостей, если количество гостей недоступно, вывести максимально возможное количество гостей на арене соревнований
SELECT c.Competition_Name, NVL2(e.Event_NumberOfGuests, e.Event_NumberOfGuests, r.RaceArea_MaxNumOfGuests) AS Guest_Num
    FROM Events e
    NATURAL JOIN RaceAreas r
    NATURAL JOIN Competitions c;

--13. TOP-N анализа();
-- вывести последних 5 соревнований
SELECT *
    FROM (SELECT *
        FROM Competitions
        ORDER BY Competition_Date DESC)
    WHERE ROWNUM <= 5;

--14. функции ROLLUP().
-- подсчитать, каких мест сколько было занято лошадьми за время всех заездов
SELECT Race_HorsePlace, COUNT(Race_HorsePlace) AS How_much
    FROM Results
    GROUP BY ROLLUP(Race_HorsePlace)
    ORDER BY Race_HorsePlace;

--15. Составьте запрос на использование оператора MERGE языка манипулирования данными.
-- для новых мест проведения соревнований (данных в таблице NEW_RaceAreas), выяснить, действительно ли это новые места, или открываются дополнительные тррибуны для зрителей. Если места новые(совпадают RaceArea_Address), то добавить их в базу, если старые, то обновить в существующей записи максимально воможное уоличество гостей и площадь участка

CREATE TABLE
    NEW_RaceAreas
    (
        RaceArea_ID NUMBER(10) PRIMARY KEY,
        RaceArea_Address VARCHAR2(300) NOT NULL,
        RaceArea_MaxNumOfGuests NUMBER(10) NOT NULL
            CHECK (RaceArea_MaxNumOfGuests > 0),
        RaceArea_Square NUMBER(10) --in hectares
            CHECK (RaceArea_Square > 0)
    );

INSERT INTO NEW_RaceAreas VALUES
    (1, 'Knighton, Powys LD7 1DL, United Kingdom', 3000, 5000);

INSERT INTO NEW_RaceAreas VALUES
    (2, 'Ketley Bank, Telford, Telford and Wrekin TF2 0EB, United Kingdom', 12000, 11000);

INSERT INTO NEW_RaceAreas VALUES
    (3, '85 Llanelian Rd, Old Colwyn, Colwyn Bay, Conwy LL29 8UN, Great Bitain', 3000, 4000);

MERGE INTO RaceAreas ra
    USING (SELECT *
        FROM NEW_RaceAreas) newra
        ON (ra.RaceArea_Address = newra.RaceArea_Address)
    WHEN MATCHED THEN
        UPDATE SET ra.RaceArea_MaxNumOfGuests = newra.RaceArea_MaxNumOfGuests
        AND ra.RaceArea_Square = newra.RaceArea_Square
    WHEN NOT MATCHED THEN
        INSERT (ra.RaceArea_ID, ra.RaceArea_Address, ra.RaceArea_MaxNumOfGuests, ra.RaceArea_Square)
        VALUES (RaceArea_ID_Generator.NEXTVAL, newra.RaceArea_Address, newra.RaceArea_MaxNumOfGuests, newra.RaceArea_Square);
         
SELECT * FROM RaceAreas;
