--lab0619

--1. Создайте последовательность.
CREATE SEQUENCE ID_Generator
    INCREMENT BY 1
    START WITH 1
    NOMAXVALUE
    NOCYCLE;

--2. Добавьте в схему базы данных, разработанную Вами в лабораторной работе №1, новую сущность. Создайте для этой сущности таблицу (таблицы). Причем, поле этой таблицы с ограничением первичного ключа должно заполняться с помощью последовательности. Заполните таблицу данными.
CREATE TABLE
    Prepodavatel
    (
        Prepod_ID NUMBER(10) PRIMARY KEY,
        FIO VARCHAR2(256) NOT NULL
    );

CREATE SEQUENCE Prepod_ID_Generator
    INCREMENT BY 1
    START WITH 1
    NOMAXVALUE
    NOCYCLE;

INSERT INTO Prepodavatel VALUES
    (Prepod_ID_Generator.NEXTVAL, 'Кузьмина Анна Викентьевна');

INSERT INTO Prepodavatel VALUES
    (Prepod_ID_Generator.NEXTVAL, 'Репников Василий Иванович');

CREATE TABLE
    Prepodavanie
    (
        Prepodavanie_ID NUMBER(10) PRIMARY KEY,
        Prepod_ID NUMBER(10) NOT NULL REFERENCES Prepodavatel(Prepod_ID),
        Predmet_ID NUMBER(10) NOT NULL REFERENCES Uchebnyi_Predmet(Predmet_ID),
        Lekcii_Ili_Praktika VARCHAR2(1) NOT NULL
            CHECK (Lekcii_Ili_Praktika IN('0', '1')) -- '0' - lekcii, '1' - praktika
    );

CREATE SEQUENCE Prepodavanie_ID_Generator
    INCREMENT BY 1
    START WITH 1
    NOMAXVALUE
    NOCYCLE;

--?????????????????????
INSERT INTO Prepodavanie VALUES
    (Prepodavanie_ID_Generator.NEXTVAL, Prepod_ID_Generator.CURRVAL, 1, '0');

--3. Создайте индексы для тех полей базы данных, для которых это необходимо (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 12 Working with Sequences).
CREATE INDEX ispytanie_stud_predm_ind
    ON Ispytanie(Student_ID, Predmet_ID);

CREATE INDEX ispytanie_data_ind
    ON Ispytanie(Data_Sdachi);

CREATE INDEX prepodavanie_prepod_predm_ind
    ON Prepodavanie(Prepod_ID, Predmet_ID);

--4. В одну из таблиц добавьте поле (внешний ключ), значения которого ссылаются на поле – первичный ключ этой таблицы (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 8 Working with DDL Statements). Составьте запросы на выборку данных с использованием рефлексивного соединения (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 3 Executing Database Joins\Self Joins and Hierarchical Queries).

--Составьте запросы на выборку данных с использованием следующих операторов, конструкций и функций языка SQL:
--5. простого оператора CASE ();
-- вывести список учебных предметов в формате Название предмета, Семестр преподавания, Экзамен(Нет экзамена), Зачет(Нет зачета) (словами)
SELECT Nazvanie, Predmet_Semestr,
    CASE Otchetnost_Ekzamen
        WHEN '1' THEN 'Exam'
        ELSE 'No exam'
    END
    AS Passing_An_Exam
    CASE Otchetnost_Zachet
        WHEN '1' THEN 'Test'
        ELSE 'No test'
    END
    AS Passing_A_Test
    FROM Uchebnyi_Predmet;

--6. поискового оператора CASE();
-- вывести список испытаний (экзаменов или зачетов), прошедших больше, чем год назад - ФИО сдававшего студента, название предмета, вид испытания и оценку
SELECT s.FIO, p.Nazvanie,
    CASE
        WHEN i.Ekzamen_Ili_Zachet = '0' THEN 'Test'
        ELSE 'Exam'
    END
    AS Passed_What,
    CASE
        WHEN i.Ekzamen_Ili_Zachet = '0' AND i.Ocenka=1 THEN 'Passed'
        WHEN i.Ekzamen_Ili_Zachet = '0' AND i.Ocenka=0 THEN 'Failed'
        ELSE CAST(i.Ocenka AS VARCHAR(2))
    END
    AS Ocenka
    FROM Uchebnyi_Predmet p
        NATURAL JOIN Ispytanie i
        NATURAL JOIN Student s;

--7. оператора WITH();
-- выбрать имена преподавателей практики, ведущих предметы в осенних семестрах (1,3,5,7,9)
--???????????????????????????????????
WITH Osennie AS
    (SELECT Predmet_ID
        FROM Uchebnyi_Predmet
        WHERE Predmet_Semestr IN (1,3,5,7,9))
SELECT p.FIO
    FROM Prepodavatel p NATURAL JOIN Prepodavanie pr
    WHERE pr.Predmet_ID IN Osennie
    GROUP BY p.FIO;

--8. встроенного представления();
-- выбрать имена преподавателей практики, ведущих предметы в осенних семестрах (1,3,5,7,9), и названия этих предметов
SELECT p.FIO, o.Nazvanie
    FROM Prepodavatel p
    NATURAL JOIN Prepodavanie
    NATURAL JOIN (SELECT Predmet_ID, Nazvanie FROM Uchebnyi_Predmet WHERE Predmet_Semestr IN (1,3,5,7,9)) o
    GROUP BY p.FIO, o.Nazvanie;

--9. некоррелированного запроса((academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 6 Creating Subqueries).);
-- выбрать студентов, которые когда-либо сдавали экзамен
SELECT *
    FROM STUDENT
    WHERE Student_ID IN
        (SELECT Student_ID
            FROM Ispytanie
            WHERE Ekzamen_Ili_Zachet = '1')
    ORDER BY FIO;

--10. коррелированного запроса(academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 6 Creating Subqueries).);
-- найти предметы, которые изучаются студентами
SELECT p.Nazvanie
    FROM Uchebnyi_Predmet p
    WHERE p.Predmet_ID IN
        (SELECT Predmet_ID
            FROM Uchebnyi_Predmet
            NATURAL JOIN Ispytanie
            NATURAL JOIN Student
            WHERE Semestr_Seichas = p.Predmet_Semestr);

--11. функции NULLIF (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 2 Using Single-Row Functions);
-- вывести список всех студентов, убрав 5 семестр из процесса обучения
SELECT Student_ID, Nomer_Zach_kn, FIO, NULLIF(Semestr_Seichas, 5) AS Semester(Not_5)
    FROM Student;

--12. функции NVL2 (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 2 Using Single-Row Functions);
-- попытаться идентифицировать студента хоть каким-то образом (если известен номер зачетной книжки - вывести его, иначе - вывести ФИО)
SELECT Student_ID, NVL2(Nomer_zach_kn, Nomer_zach_kn, FIO) AS Best_Data_Available
    FROM Student;

--13. TOP-N анализа();
-- вывести последних 25 студентов по номеру зачетной книжки
SELECT *
    FROM (SELECT *
        FROM Student
        ORDER BY Nomer_zach_kn DESC)
    WHERE ROWNUM <= 25;

--14. функции ROLLUP().
-- подсчитать, каких оценок сколько было получено студентами
SELECT Ocenka, COUNT(Ocenka) AS How_much
    FROM Ispytanie
    GROUP BY ROLLUP(Ocenka)
    ORDER BY Ocenka;

--15. Составьте запрос на использование оператора MERGE языка манипулирования данными.
-- ввести 3 новых предмета, при этом если данные новых предметов совпадают со старыми, увеличить количество часов

CREATE TABLE
    Novyi_Predmet
    (
        Predmet_ID NUMBER(10) PRIMARY KEY,
        Nazvanie VARCHAR2(50) NOT NULL,
        Predmet_Semestr NUMBER(10) NOT NULL
            CHECK (Predmet_Semestr > 0 AND Predmet_Semestr < 11),
        Kolvo_Chasov NUMBER(10) NOT NULL,
        Otchetnost_Ekzamen VARCHAR2(1) NOT NULL
            CHECK (Otchetnost_Ekzamen IN('0', '1')), -- '0' - no exam, '1' - exam
        Otchetnost_Zachet VARCHAR2(1) NOT NULL
            CHECK (Otchetnost_Zachet IN('0', '1')) -- '0' - no test, '1' - test
    );

INSERT INTO Novyi_Predmet VALUES
    (1, 'Математический анализ', 1, 22, 1, 1);

INSERT INTO Novyi_Predmet VALUES
    (2, 'Политология', 5, 10, 0, 1);

INSERT INTO Novyi_Predmet VALUES
    (3, 'Физкультура', 1, 68, 1, 1);

INSERT INTO Novyi_Predmet VALUES
    (4, 'Матричный анализ', 5, 34, 0, 1);

MERGE INTO Uchebnyi_Predmet up
    USING (SELECT *
        FROM Novyi_Predmet) o
        ON (up.Predmet_ID = o.Predmet_ID)
    WHEN MATCHED THEN
        UPDATE SET up.Kolvo_Chasov = up.Kolvo_Chasov + o.Kolvo_Chasov
    WHEN NOT MATCHED THEN
        INSERT (up.Predmet_ID, up.Nazvanie, up.Predmet_Semestr, up.Kolvo_Chasov, up.Otchetnost_Ekzamen, up.Otchetnost_Zachet)
        VALUES (o.Predmet_ID, o.Nazvanie, o.Predmet_Semestr, o.Kolvo_Chasov, o.Otchetnost_Ekzamen, o.Otchetnost_Zachet);
         
SELECT * FROM Uchebnyi_Predmet;