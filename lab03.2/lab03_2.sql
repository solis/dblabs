--3.2

--  ВЛОЖЕННЫЕ ПОДЗАПРОСЫ:
--  ПОДЗАПРОСЫ, ВЫБИРАЮЩИЕ ОДНУ СТРОКУ
--   1. Найти имена сотрудников, получивших за годы начисления зарплаты минимальную зарплату.
SELECT E.EMPNAME 
    FROM EMP E
    WHERE (
    SELECT MIN(S.SALVALUE) 
        FROM SALARY S 
        WHERE S.EMPNO = E.EMPNO) 
    IN (
    SELECT J.MINSALARY 
        FROM JOB J NATURAL JOIN CAREER C 
        WHERE E.EMPNO = C.EMPNO);

--  ПОДЗАПРОСЫ, ВОЗВРАЩАЮЩИЕ БОЛЕЕ ОДНОЙ СТРОКИ
--   2. Найти имена сотрудников, работавших или работающих в тех же отделах, в которых работал или работает сотрудник с именем RICHARD MARTIN.
SELECT E.EMPNAME
    FROM EMP E NATURAL JOIN CAREER C
    WHERE C.DEPTNO IN (
    SELECT C.DEPTNO
        FROM CAREER C NATURAL JOIN EMP E
        WHERE E.EMPNAME='RICHARD MARTIN');

--  СРАВНЕНИЕ БОЛЕЕ ЧЕМ ПО ОДНОМУ ЗНАЧЕНИЮ
--   3. Найти имена сотрудников, работавших или работающих в тех же отделах и должностях, что и сотрудник 'RICHARD MARTIN'.
SELECT E.EMPNAME
    FROM EMP E NATURAL JOIN CAREER C
    WHERE C.DEPTNO IN (
    SELECT C.DEPTNO
        FROM CAREER C NATURAL JOIN EMP E
        WHERE E.EMPNAME='RICHARD MARTIN')
    AND C.JOBNO IN (
    SELECT C.JOBNO
        FROM CAREER C NATURAL JOIN EMP E
        WHERE E.EMPNAME='RICHARD MARTIN');

--  ОПЕРАТОРЫ ANY/ALL
--   4. Найти сведения о номерах сотрудников, получивших за какой-либо месяц зарплату большую чем средняя зарплата за 2000 г. или большую чем средняя зарплата за 2001г.
SELECT EMPNO
    FROM SALARY
    WHERE (
    SELECT AVG(SALVALUE)
        FROM SALARY
        WHERE YEAR = 2000) < ANY(SALVALUE)
    OR (
    SELECT AVG(SALVALUE)
        FROM SALARY
        WHERE YEAR = 2001) < ANY(SALVALUE);

--   5. Найти сведения о номерах сотрудников, получивших зарплату за какой-либо месяц большую чем среднии зарплаты за все годы начислений.
SELECT EMPNO
    FROM SALARY
    WHERE (
    SELECT AVG(SALVALUE)
        FROM SALARY) < ANY(SALVALUE);

--  ИСПОЛЬЗОВАНИЕ HAVING С ВЛОЖЕННЫМИ ПОДЗАПРОСАМИ
--   6. Определить годы, в которые начисленная средняя зарплата была больше средней зарплаты за все годы начислений.
SELECT YEAR
    FROM SALARY
    GROUP BY YEAR
    HAVING AVG(SALVALUE) > (
    SELECT AVG(SALVALUE)
        FROM SALARY);

--  КОРРЕЛИРУЮЩИЕ ПОДЗАПРОСЫ
--   7. Определить номера отделов, в которых работали или работают сотрудники, имеющие начисления зарплаты.
SELECT DEPTNO
    FROM DEPT D
    WHERE DEPTNO IN (
    SELECT DEPTNO
        FROM CAREER C NATURAL JOIN EMP E NATURAL JOIN SALARY S
        WHERE S.SALVALUE IS NOT NULL)
    GROUP BY DEPTNO
    ORDER BY DEPTNO;

--  ОПЕРАТОР EXISTS
--   8. Определить номера отделов, в которых работали или работают сотрудники, имеющие начисления зарплаты.
SELECT DEPTNO
    FROM DEPT D
    WHERE EXISTS (
    SELECT SALVALUE
        FROM CAREER C NATURAL JOIN EMP E NATURAL JOIN SALARY S
        WHERE D.DEPTNO = C.DEPTNO)
    ORDER BY DEPTNO;

--  ОПЕРАТОР NOT EXISTS
--   9. Определить номера отделов, для сотрудников которых не начислялась зарплата.
SELECT DEPTNO
    FROM DEPT D
    WHERE NOT EXISTS (
    SELECT SALVALUE
        FROM CAREER C NATURAL JOIN EMP E NATURAL JOIN SALARY S
        WHERE D.DEPTNO = C.DEPTNO)
    ORDER BY DEPTNO;

--  СОСТАВНЫЕ ЗАПРОСЫ
--   10. Вывести сведения о карьере сотрудников с указанием названий и адресов отделов вместо номеров отделов.
SELECT E.EMPNAME, D.DEPTNAME, D.DEPTADDR
    FROM EMP E NATURAL JOIN CAREER C NATURAL JOIN DEPT D
    ORDER BY E.EMPNAME, C.STARTDATE;

--  ОПЕРАТОР CAST
--   11. Определить целую часть средних зарплат, по годам начисления.
SELECT YEAR, CAST(AVG(SALVALUE) AS NUMBER(10)) AS INTSALVALUE
    FROM SALARY
    GROUP BY YEAR
    ORDER BY YEAR;

--  ОПЕРАТОР CASE
--   12. Разделите сотрудников на возрастные группы: A) возраст 20-30 лет; B) 31-40 лет; C) 41-50; D) 51-60 или возраст не определён.
SELECT EMPNO, EMPNAME,
    CASE
        WHEN MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 >= 20 AND MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 <= 30
            THEN 'A'
        WHEN MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 >= 31 AND MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 <= 40
            THEN 'B'
        WHEN MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 >= 41 AND MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 <= 50
            THEN 'C'
        WHEN MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 >= 51 AND MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 <= 60
            THEN 'D'
        ELSE NULL
    END
    AS AGE_GROUP
    FROM EMP;

--   13. Перекодируйте номера отделов, добавив перед номером отдела буквы BI для номеров <=20,  буквы  LN для номеров >=30.
SELECT D.DEPTNO,
    CASE
        WHEN D.DEPTNO <= 20  THEN CONCAT('BI', CAST (D.DEPTNO AS VARCHAR(10)))
        WHEN D.DEPTNO >= 30  THEN CONCAT('LN', CAST (D.DEPTNO AS VARCHAR(10)))
    END
    AS NEWDEPTNO, D.DEPTNAME, D.DEPTADDR
    FROM DEPT D

--  ОПЕРАТОР COALESCE (объединяться)
--   14. Выдать информацию о сотрудниках из таблицы EMP, заменив отсутствие данного о дате рождения датой '01-01-1000'.
SELECT EMPNO, EMPNAME,
    COALESCE(BIRTHDATE, to_date('01-01-1000', 'dd-mm-yyyy')) AS BIRTHDATE
    FROM EMP
