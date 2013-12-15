-- 01. Добавьте в таблицу SALARY столбец TAX (налог) для вычисления ежемесячного подоходного
--     налога на зарплату по прогрессивной шкале. Налог вычисляется по следующему правилу:
--     * налог равен 9% от начисленной  в месяце зарплаты, если суммарная зарплата с начала года до
--       конца рассматриваемого месяца не превышает 20 000;
--     * налог равен 12% от начисленной  в месяце зарплаты, если суммарная зарплата с начала года
--       до конца рассматриваемого месяца больше 20 000, но не превышает 30 000;
--     * налог равен 15% от начисленной  в месяце зарплаты, если суммарная зарплата с начала года
--       до конца рассматриваемого месяца  больше 30 000.

ALTER TABLE SALARY ADD (TAX NUMBER(15))

-- 02. 2. Составьте программу вычисления налога и вставки её в таблицу SALARY:
-- a) с помощью простого цикла (loop) с курсором и оператора if;
CREATE OR REPLACE PROCEDURE TAX_SIMPLE_LOOP_IF AS
    SUMSAL NUMBER(16);
BEGIN
    FOR R IN SELECT * FROM SALARY
    LOOP
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY WHERE R.EMPNO = EMPID AND R.YEAR = YEAR(SYSDATE));
        IF SUMSAL < 20000 THEN
            R.TAX = R.SALVALUE * 0.09;
        ELSIF SUMSAL < 30000 THEN
            R.TAX = R.SALVALUE * 0.12;
        ELSE
            R.TAX = R.SALVALUE * 0.15;
        END;
    END LOOP;
    COMMIT;
END

-- b) с помощью простого цикла (loop) с курсором и оператора case;
CREATE OR REPLACE PROCEDURE TAX_CUR_LOOP_CASE AS
    SUMSAL NUMBER(16);
BEGIN
    FOR R IN SELECT * FROM SALARY
    LOOP
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY WHERE R.EMPNO = EMPID AND R.YEAR = YEAR(SYSDATE));
        CASE
            WHEN SUMSAL < 20000 THEN
                R.TAX = R.SALVALUE * 0.09;
            WHEN SUMSAL < 30000 THEN
                R.TAX = R.SALVALUE * 0.12;
            ELSE
                R.TAX = R.SALVALUE * 0.15;
        END;
    END LOOP;
    COMMIT;
END TAX_CUR_LOOP_CASE;


-- c) с помощью курсорного цикла FOR;
CREATE OR REPLACE PROCEDURE TAX_CUR_LOOP_CASE AS
    SUMSAL NUMBER(16);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
    R CUR%ROWTYPE
BEGIN
    OPEN CUR;
    LOOP
        FETCH CUR INTO R;
        EXIT WHEN CUR%NOTFOUND;
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY WHERE R.EMPNO = EMPID AND R.YEAR = YEAR(SYSDATE));
        CASE
            WHEN SUMSAL < 20000 THEN
                R.TAX = R.SALVALUE * 0.09;
            WHEN SUMSAL < 30000 THEN
                R.TAX = R.SALVALUE * 0.12;
            ELSE
                R.TAX = R.SALVALUE * 0.15;
        END;
    END LOOP;
    CLOSE CUR;
    COMMIT;
END TAX_CUR_LOOP_CASE;

-- d) с помощью курсора с параметром, передавая номер сотрудника, для которого необходимо посчитать
--    налог.
CREATE  OR  REPLACE  PROCEDURE  TAX_PARAM (EMPID  NUMBER)  AS
DECLARE
    SUMSAL NUMBER(16);
BEGIN
    SELECT SUM(SALVALUE) FROM SALARY WHERE EMPNO = EMPID AND YEAR = YEAR(SYSDATE)
    UPDATE  SALARY S SET  TAX =
        CASE
            WHEN SUMSAL < 20000 THEN S.SALVALUE * 0.09
            WHEN SUMSAL < 30000 THEN S.SALVALUE * 0.12
            ELSE S.SALVALUE * 0.15
        END
        WHERE  KNIGA.КОД_КНИГИ = UVEL.КОД_КНИГИ;
            IF  SQL%NOTFOUND  THEN
               INSERT  INTO  KNIGA (КОД_КНИГИ)  VALUES
                (UVEL.КОД_КНИГИ);
        END  IF;
    COMMIT;
END  TAX_PARAM;

-- 04. Создайте процедуру, вычисляющую налог на зарплату за всё время начислений для конкретного
--     сотрудника. В качестве параметров передать процент налога (до 20000, до 30000, выше 30000,
--     номер сотрудника).
CREATE  OR  REPLACE  PROCEDURE  TAX_PARAM_LESS
    (UNDER_20k NUMBER, OVER_20k NUMBER, OVER_30k NUMBER, EMPID  NUMBER)  AS
    SUMSAL NUMBER(16);
BEGIN
    SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY WHERE EMPNO = EMPID AND YEAR = YEAR(SYSDATE);
    UPDATE  SALARY  SET  TAX =
        CASE
            WHEN SUMSAL < 20000 THEN SALVALUE * UNDER_20k
            WHEN SUMSAL < 30000 THEN SALVALUE * OVER_20k
            ELSE SALVALUE * OVER_30k
        END
    WHERE  SALARY.EMPNO = EMPID
    COMMIT;
END  TAX_PARAM_LESS;

-- 05.  Создайте функцию, вычисляющую суммарный налог на зарплату сотрудника за всё время начислений.
--      В качестве параметров передать процент налога (до 20000, до 30000, выше 30000, номер
--      сотрудника). Возвращаемое значение – суммарный налог.
