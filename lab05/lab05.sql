--5

--1. Создайте представление, содержащее данные о сотрудниках пенсионного возраста.
CREATE VIEW PENSIONER AS
    SELECT * FROM EMP
    WHERE MONTHS_BETWEEN(SYSDATE, BIRTHDATE)/12 >= 60

--2. Создайте представление, содержащее данные об уволенных сотрудниках: имя сотрудника, дата увольнения, отдел, должность.
CREATE VIEW DISMISSED (EMPNAME, ENDDATE, DEPTNAME, JOBNAME) AS
    SELECT E.EMPNAME, C.ENDDATE, D.DEPTNAME, J.JOBNAME
    FROM EMP E NATURAL JOIN CAREER C NATURAL JOIN DEPT D NATURAL JOIN JOB J
    WHERE C.ENDDATE IS NOT NULL

--3. Создайте представление, содержащее имя сотрудника, должность, занимаемую сотрудником в данный момент, суммарную заработную плату сотрудника за третий квартал 2010 года. Первый столбец назвать Sotrudnik, второй – Dolzhnost, третий – Itogo_3_kv.
CREATE VIEW KVARTAL (SOTRUDNIK, DOLZHNOST, ITOGO_3_KV) AS SELECT E.EMPNAME, J.JOBNAME, SUM(S.SALVALUE) FROM JOB J NATURAL JOIN CAREER NATURAL JOIN EMP E NATURAL JOIN SALARY S WHERE S.YEAR = 2010 AND S.MONTH BETWEEN 7 AND 9


--4. На основе представления из задания 2 и таблицы SALARY создайте представление, содержащее данные об уволенных сотрудниках, которым зарплата начислялась более 2 раз. В созданном представлении месяц начисления зарплаты и сумма зарплаты вывести в одном столбце, в качестве разделителя использовать запятую.
CREATE VIEW DISMISSED2SALARY (EMPNAME, ENDDATE, DEPTNAME, JOBNAME, MONTH_AND_SUM) AS
    SELECT D.EMPNAME, D.ENDDATE, D.DEPTNAME, D.JOBNAME, S.MONTH || ', ' || S.SALVALUE AS MONTH_AND_SUM
    FROM DISMISSED D NATURAL JOIN SALARY S
    WHERE S.EMPNO IN (SELECT EMPNO
                        FROM DISMISSED NATURAL JOIN SALARY
                        GROUP BY EMPNO
                        HAVING COUNT(SALVALUE)>2)
