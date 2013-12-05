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

--Составьте запросы на выборку данных с использованием следующих операторов, конструкцийи функций языка SQL:
--5. простого оператора CASE ();
--

--6. поискового оператора CASE();

--7. оператора WITH();

--8. встроенного представления();

--9. некоррелированного запроса((academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 6 Creating Subqueries).);

--10. коррелированного запроса(academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 6 Creating Subqueries).);

--11. функции NULLIF (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 2 Using Single-Row Functions);

--12. функции NVL2 (academy.oracle.com\iLearning\2013-2014 Oracle Academy Database Programming with SQL – Student\Section 2 Using Single-Row Functions);

--13. TOP-N анализа();

--14. функции ROLLUP().

--15. Составьте запрос на использование оператора MERGE языка манипулирования данными.
