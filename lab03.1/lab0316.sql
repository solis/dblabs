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
SELECT EMPNO, EMPNAME, TO_CHAR(BIRTHDATE, 'DD-MONTH-YEAR','NLS_DATE_LANGUAGE = RUSSIAN') 
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
--   16. Выдайте сведения о карьере сотрудников с указанием их имён.
SELECT E.EMPNAME, C.STARTDATE, C.ENDDATE
    FROM EMP E
        RIGHT OUTER JOIN CAREER C
            ON (E.EMPNO = C.EMPNO)
    ORDER BY E.EMPNAME, C.STARTDATE;
