-- Найти имена сотрудников, получивших за годы начисления зарплаты минимальную зарплату.
SELECT EMP.EMPNAME FROM (SALARY INNER JOIN EMP ON SALARY.EMPNO = EMP.EMPNO)
    WHERE SALARY.SALVALUE = (SELECT MIN(SALVALUE) FROM SALARY)

-- Найти имена сотрудников, работавших или работающих в тех же отделах, в которых работал или
-- работает сотрудник с именем RICHARD MARTIN.
SELECT EMPNAME FROM EMP
    WHERE EMPNO IN (SELECT DISTINCT EMPNO FROM CAREER
        WHERE DEPTNO IN (SELECT DEPTNO FROM CAREER
            WHERE EMPNO = (SELECT EMPNO FROM EMP
                WHERE EMPNAME = 'RICHARD MARTIN')))
    AND NOT EMPNAME = 'RICHARD MARTIN'

-- Найти имена сотрудников, работавших или работающих в тех же отделах и должностях, что и сотрудник
-- 'RICHARD MARTIN'.
SELECT EMPNAME FROM EMP
    WHERE EMPNO IN (SELECT DISTINCT EMPNO FROM CAREER
        WHERE DEPTNO IN (SELECT DEPTNO FROM CAREER
            WHERE EMPNO = (SELECT EMPNO FROM EMP
                WHERE EMPNAME = 'RICHARD MARTIN'))
        AND JOBNO IN (SELECT JOBNO FROM CAREER
            WHERE EMPNO = (SELECT EMPNO FROM EMP
                WHERE EMPNAME = 'RICHARD MARTIN')))
    AND NOT EMPNAME = 'RICHARD MARTIN'

-- Найти сведения о номерах сотрудников, получивших за какой-либо месяц зарплату большую чем средняя
-- зарплата   за 2000 г. или большую чем средняя зарплата за 2001г.
SELECT EMPNO FROM SALARY
    WHERE SALVALUE > ANY(SELECT AVG(SALVALUE) FROM SALARY WHERE YEAR BETWEEN 2007, 2009))

-- Найти сведения о номерах сотрудников, получивших зарплату за какой-либо месяц большую чем среднии зарплаты за все
-- годы начислений.
SELECT EMPNO FROM SALARY
    WHERE (SELECT AVG(SALVALUE) FROM SALARY) < ANY(SALVALUE)

-- Определить годы, в которые начисленная средняя зарплата была больше средней зарплаты за все годы начислений.
SELECT YEAR FROM SALARY
    GROUP BY YEAR
    HAVING AVG(SALVALUE) > (SELECT AVG(SALVALUE) FROM SALARY);


-- Определить номера отделов, в которых работали или работают сотрудники, имеющие начисления зарплаты.
SELECT DISTINCT DEPTNO
    FROM DEPT
    WHERE DEPTNO IN (
    SELECT DEPTNO
        FROM CAREER  NATURAL JOIN EMP NATURAL JOIN SALARY S
        WHERE S.SALVALUE IS NOT NULL)
    ORDER BY DEPTNO;

-- Определить номера отделов, в которых работали или работают сотрудники, имеющие начисления зарплаты.
SELECT DEPTNO
    FROM DEPT D
    WHERE EXISTS (
    SELECT SALVALUE
        FROM CAREER C NATURAL JOIN EMP NATURAL JOIN SALARY
        WHERE D.DEPTNO = C.DEPTNO)
    ORDER BY DEPTNO;

-- Определить номера отделов, в которых работали или работают сотрудники, не имеющие начисления зарплаты
SELECT DEPTNO
    FROM DEPT D
    WHERE NOT EXISTS (
    SELECT SALVALUE
        FROM CAREER C NATURAL JOIN EMP NATURAL JOIN SALARY
        WHERE D.DEPTNO = C.DEPTNO)
    ORDER BY DEPTNO;

-- Вывести сведения о карьере сотрудников с указанием названий и адресов отделов вместо номеров отделов.
SELECT E.EMPNAME, D.DEPTNAME, D.DEPTADDR
    FROM EMP E NATURAL JOIN CAREER C NATURAL JOIN DEPT D
    ORDER BY E.EMPNAME, C.STARTDATE;

-- Определить целую часть средних зарплат,  по годам начисления.
SELECT YEAR, CAST(AVG(SALVALUE) AS NUMBER(10)) AS TRUNCAVG
    FROM SALARY
    GROUP BY YEAR
    ORDER BY YEAR;

-- Разделите сотрудников на возрастные группы: A) возраст 20-30 лет; B) 31-40 лет; C) 41-50; D) 51-60 или возраст не
-- определён.
SELECT EMPNO, EMPNAME,
    CASE
        WHEN MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 BETWEEN 20 AND 30
            THEN 'A'
        WHEN MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 BETWEEN 31 AND 40
            THEN 'B'
        WHEN MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 BETWEEN 41 AND 50
            THEN 'C'
        WHEN MONTHS_BETWEEN (SYSDATE, BIRTHDATE) / 12 BETWEEN 51 AND 60
            THEN 'D'
        ELSE NULL
    END
    AS AGE_GROUP
    FROM EMP;

-- Перекодируйте номера отделов, добавив перед номером отдела буквы BI для номеров <=20, буквы LN для номеров >=30.
SELECT D.DEPTNO,
    CASE
        WHEN D.DEPTNO <= 20 THEN CONCAT('BI', CAST (D.DEPTNO AS VARCHAR(10)))
        WHEN D.DEPTNO >= 30 THEN CONCAT('LN', CAST (D.DEPTNO AS VARCHAR(10)))
    END
    AS NEWDEPTNO, D.DEPTNAME, D.DEPTADDR
    FROM DEPT D

-- Выдать информацию о сотрудниках из таблицы EMP, заменив отсутствие данного о дате рождения датой '01-01-1000'.
SELECT EMPNO, EMPNAME,
    COALESCE(BIRTHDATE, to_date('01-01-1000', 'dd-mm-yyyy')) AS BIRTHDATE
    FROM EMP

