--3.1

-- ПРОСТЕЙШИЕ ЗАПРОСЫ:
-- 1. Выдать информацию о местоположении отдела продаж (SALES) компании.
SELECT DEPTADDR 
    FROM DEPT 
    WHERE DEPTNAME = 'SALES';

-- 2. Выдать информацию обо отделах, расположенных в Чикаго и Нью-Йорке. (in)-    
SELECT * 
    FROM DEPT 
    WHERE DEPTADDR IN ('NEW YORK', 'CHICAGO');
    
-- ФУНКЦИИ:
--  3. Найти минимальную заработную плату, начисленную в 2007 году
SELECT MIN(SALVALUE) AS MINSALARY2007 
    FROM SALARY 
    WHERE YEAR = 2007;
    
--  4. Выдать информацию обо всех работниках, родившихся не позднее 1 января 1960 года.
SELECT *
    FROM EMP 
    WHERE BIRTHDATE <= to_date('01-01-1960','dd-mm-yyyy');
    
--  5. Подсчитать число работников, сведения о которых имеются в базе данных .
SELECT COUNT(*) 
    FROM EMP;
    
--  6. Найти работников, чьё имя состоит из одного слова. Имена выдать на нижнем регистре, с удалением стоящей справа буквы t.
SELECT RTRIM(LOWER(EMPNAME), 't') AS NEWEMPNAME 
    FROM EMP 
    WHERE EMPNAME NOT LIKE('% %');
    
--  7. Выдать информацию о работниках, указав дату рождения в формате день(число), месяц(название), год(название).
SELECT EMPNO, EMPNAME, TO_CHAR(BIRTHDATE, 'DD-MONTH-YYYY','NLS_DATE_LANGUAGE = AMERICAN') 
    FROM EMP
--  То же, но год числом.
SELECT EMPNO, EMPNAME, TO_CHAR(BIRTHDATE, 'DD-MONTH-YEAR','NLS_DATE_LANGUAGE = AMERICAN') 
    FROM EMP
 
--  8. Выдать информацию о должностях, изменив названия должности “CLERK” и “DRIVER” на “WORKER”.   
SELECT DECODE(JOBNAME, 'DRIVER', 'WORKER', 'CLERK', 'WORKER', JOBNAME) AS NEWJOB 
    FROM JOB;
    
-- HAVING:
--  9. Определите среднюю зарплату за годы, в которые были начисления не менее чем за три месяцев.
SELECT YEAR, AVG(SALVALUE) 
    FROM SALARY 
    GROUP BY YEAR 
    HAVING COUNT(MONTH) >= 3;

-- СОЕДИНЕНИЕ ПО РАВЕНСТВУ:
--  10. Выведете ведомость получения зарплаты с указанием имен служащих.
SELECT EMP.EMPNAME, SALARY.MONTH,  SALARY.SALVALUE 
    FROM EMP, SALARY 
    WHERE EMP.EMPNO = SALARY.EMPNO;

-- СОЕДИНЕНИЕ НЕ ПО РАВЕНСТВУ:
--  11. Укажите  сведения о начислении сотрудникам зарплаты, попадающей в вилку: минимальный оклад по должности - минимальный оклад по должности плюс пятьсот. Укажите соответствующую вилке  должность.
SELECT EMP.EMPNAME, JOB.JOBNAME, SALARY.SALVALUE, JOB.MINSALARY
    FROM SALARY 
        INNER JOIN EMP 
            ON SALARY.EMPNO = EMP.EMPNO 
        INNER JOIN CAREER 
            ON CAREER.EMPNO = EMP.EMPNO 
        INNER JOIN JOB 
            ON JOB.JOBNO = CAREER.JOBNO
    WHERE SALARY.SALVALUE > JOB.MINSALARY 
        AND SALARY.SALVALUE < JOB.MINSALARY + 500;
        
-- ОБЪЕДИНЕНИЕ ТАБЛИЦ:
--  ВНУТРЕННЕЕ:
--   12.  Укажите сведения о заработной плате, совпадающей с минимальными окладами по должностям (с указанием этих должностей).
SELECT E.EMPNAME, S.SALVALUE, J.MINSALARY, J.JOBNAME 
    FROM SALARY S 
        INNER JOIN EMP E 
            ON (S.EMPNO = E.EMPNO) 
        INNER JOIN CAREER C 
            ON (E.EMPNO = C.EMPNO) 
        INNER JOIN JOB J 
            ON (C.JOBNO = J.JOBNO) 
    WHERE S.SALVALUE = J.MINSALARY;
    
--  ЕСТЕСТВЕННОЕ:    
--   13. Найдите  сведения о карьере сотрудников с указанием вместо номера сотрудника его имени.
SELECT E.EMPNAME, C.STARTDATE, C.ENDDATE 
    FROM EMP E
        NATURAL JOIN CAREER C;
        
--  ПРОСТОЕ ВНУТРЕННЕЕ СОЕДИНЕНИЕ:
--   14. Найдите  сведения о карьере сотрудников с указанием вместо номера сотрудника его имени.
SELECT E.EMPNAME, C.STARTDATE, C.ENDDATE
    FROM EMP E 
        INNER JOIN CAREER C 
            ON (E.EMPNO = C.EMPNO);
            
--  ОБЪЕДИНЕНИЕ ТРЁХ И БОЛЬШЕГО ЧИСЛА ТАБЛИЦ:
--   15. Выдайте сведения о карьере сотрудников с указанием их имён, наименования должности, и названия отдела.
SELECT E.EMPNAME, D.DEPTNAME, J.JOBNAME, C.STARTDATE, C.ENDDATE
    FROM EMP E
        NATURAL JOIN CAREER C 
        NATURAL JOIN DEPT D 
        NATURAL JOIN JOB J 
    ORDER BY E.EMPNAME, C.STARTDATE;
    
--  ВНЕШНЕЕ ОБЪЕДИНЕНИЕ:
--   16. Выдайте сведения о карьере сотрудников с указанием их имён. (Oracle syntax)
SELECT EMPNAME, STARTDATE, ENDDATE
    FROM EMP, CAREER
    WHERE EMP.EMPNO = CAREER.EMPNO (+)
    ORDER BY EMP.EMPNAME, CAREER.STARTDATE;


--3.2

--  ВЛОЖЕННЫЕ ПОДЗАПРОСЫ:
--  ПОДЗАПРОСЫ, ВЫБИРАЮЩИЕ ОДНУ СТРОКУ
--   1. Найти имена сотрудников, получивших за годы начисления зарплаты минимальную зарплату.

--  ПОДЗАПРОСЫ, ВОЗВРАЩАЮЩИЕ БОЛЕЕ ОДНОЙ СТРОКИ
--   2. Найти имена сотрудников, работавших или работающих в тех же отделах, в которых работал или работает сотрудник с именем RICHARD MARTIN.
SELECT E.EMPNAME FROM EMP E NATURAL JOIN CAREER C WHERE C.DEPTNO IN (SELECT C.DEPTNO FROM CAREER C NATURAL JOIN EMP E WHERE E.EMPNAME='RICHARD MARTIN');

--  СРАВНЕНИЕ БОЛЕЕ ЧЕМ ПО ОДНОМУ ЗНАЧЕНИЮ
--   3. Найти имена сотрудников, работавших или работающих в тех же отделах и должностях, что и сотрудник 'RICHARD MARTIN'.
SELECT E.EMPNAME FROM EMP E NATURAL JOIN CAREER C WHERE C.DEPTNO IN (SELECT C.DEPTNO FROM CAREER C NATURAL JOIN EMP E WHERE E.EMPNAME='RICHARD MARTIN') AND C.JOBNO IN (SELECT C.JOBNO FROM CAREER C NATURAL JOIN EMP E WHERE E.EMPNAME='RICHARD MARTIN');

--  ОПЕРАТОРЫ ANY/ALL
--   4. Найти сведения о номерах сотрудников, получивших за какой-либо месяц зарплату большую чем средняя зарплата за 2000 г. или большую чем средняя зарплата за 2001г.
--SELECT EMPNO FROM SALARY WHERE SALVALUE > ANY(SELECT AVG(SALVALUE) FROM SALARY WHERE YEAR IN (2000,2001));

--   5. Найти сведения о номерах сотрудников, получивших зарплату за какой-либо месяц большую чем среднии зарплаты за все годы начислений.

--  ИСПОЛЬЗОВАНИЕ HAVING С ВЛОЖЕННЫМИ ПОДЗАПРОСАМИ
--   6. Определить годы, в которые начисленная средняя зарплата была больше средней зарплаты за все годы начислений.
SELECT YEAR FROM SALARY GROUP BY YEAR HAVING AVG(SALVALUE) > (SELECT AVG(SALVALUE) FROM SALARY);

--  КОРРЕЛИРУЮЩИЕ ПОДЗАПРОСЫ
--   7. Определить номера отделов, в которых работали или работают сотрудники, имеющие начисления зарплаты.

--  ОПЕРАТОР EXISTS
--   8. Определить номера отделов, в которых работали или работают сотрудники, имеющие начисления зарплаты.

--  ОПЕРАТОР NOT EXISTS
--   9. Определить номера отделов, для сотрудников которых не начислялась зарплата.

--  СЛОЖНЫЕ ЗАПРОСЫ
--  УРОВНИ ВЛОЖЕННОСТИ ЗАПРОСОВ
--  Примеры 1-3.

--  СОСТАВНЫЕ ЗАПРОСЫ
--   10. Вывести сведения о карьере сотрудников с указанием названий и адресов отделов вместо номеров отделов.

--  ОПЕРАТОР CAST
--   11. Определить целую часть средних зарплат, по годам начисления.

--  ОПЕРАТОР CASE
--   12. Разделите сотрудников на возрастные группы: A) возраст 20-30 лет; B) 31-40 лет; C) 41-50; D) 51-60 или возраст не определён.
--SELECT EMPNO, EMPNAME,
--CASE BIRTHDATE
--WHEN SELECT DATEDIFF(year, BIRTHDATE, GETDATE()) >= 20 AND DATEDIFF(year, BIRTHDATE, GETDATE()) <= 30  THEN 'A'
--WHEN DATEDIFF(year, BIRTHDATE, GETDATE()) >= 31 AND DATEDIFF(year, BIRTHDATE, GETDATE()) <= 40 THEN 'B'
--WHEN DATEDIFF(year, BIRTHDATE, GETDATE()) >= 41 AND DATEDIFF(year, BIRTHDATE, GETDATE()) <= 50 THEN 'C'
--WHEN DATEDIFF(year, BIRTHDATE, GETDATE()) >= 51 AND DATEDIFF(year, BIRTHDATE, GETDATE()) <= 60 THEN 'D'
--ELSE NULL
--END
--AS AGE_GROUP
--FROM EMP

--   13. Перекодируйте номера отделов, добавив перед номером отдела буквы BI для номеров <=20,  буквы  LN для номеров >=30.
SELECT D.DEPTNO,
CASE
WHEN D.DEPTNO <= 20  THEN CONCAT('BI', CAST (D.DEPTNO AS VARCHAR(10)))
WHEN D.DEPTNO >= 30  THEN CONCAT('LN', CAST (D.DEPTNO AS VARCHAR(10)))
END
AS NEWDEPTNO,
D.DEPTNAME,
D.DEPTADDR
FROM DEPT D

--  ОПЕРАТОР COALESCE (объединяться)
--   14. Выдать информацию о сотрудниках из таблицы EMP, заменив отсутствие данного о дате рождения датой '01-01-1000'.
SELECT EMPNO, EMPNAME, COALESCE(BIRTHDATE, to_date('01-01-1000', 'dd-mm-yyyy')) AS BIRTHDATE FROM EMP

