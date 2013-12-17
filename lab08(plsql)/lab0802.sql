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
    FOR R IN (SELECT * FROM SALARY)
    LOOP
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

        IF SUMSAL < 20000 THEN
            UPDATE SALARY SET TAX = R.SALVALUE * 0.09
                WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
        ELSIF SUMSAL < 30000 THEN
            UPDATE SALARY SET TAX = R.SALVALUE * 0.12
                WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
        ELSE
            UPDATE SALARY SET TAX = R.SALVALUE * 0.15
                WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
        END IF;
    END LOOP;
    COMMIT;
END

CREATE OR REPLACE PROCEDURE TAX_CUR_LOOP_CASE AS
    SUMSAL NUMBER(16);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX FROM SALARY FOR UPDATE OF TAX;
    R CUR%ROWTYPE
BEGIN
    OPEN CUR;
    LOOP
        FETCH CUR INTO R;
        EXIT WHEN CUR%NOTFOUND;
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

        IF SUMSAL < 20000 THEN
            UPDATE SALARY SET TAX = R.SALVALUE * 0.09
                WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
        ELSIF SUMSAL < 30000 THEN
            UPDATE SALARY SET TAX = R.SALVALUE * 0.12
                WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
        ELSE
            UPDATE SALARY SET TAX = R.SALVALUE * 0.15
                WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
        END IF;
    END LOOP;
    CLOSE CUR;
    COMMIT;
END TAX_CUR_LOOP_CASE;

-- b) с помощью простого цикла (loop) с курсором и оператора case;
CREATE OR REPLACE PROCEDURE TAX__LOOP_CUR_CASE AS
    SUMSAL NUMBER(16);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
    R CUR%ROWTYPE;
BEGIN
    OPEN CUR;
    LOOP
        FETCH CUR INTO R;
        EXIT WHEN CUR%NOTFOUND;
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

        UPDATE SALARY SET TAX =
            CASE
                WHEN SUMSAL < 20000 THEN R.SALVALUE * 0.09
                WHEN SUMSAL < 30000 THEN R.SALVALUE * 0.12
                ELSE R.SALVALUE * 0.15
            END

            WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
    END LOOP;
    CLOSE CUR;
    COMMIT;
END TAX_LOOP_CUR_CASE;


-- c) с помощью курсорного цикла FOR;
CREATE OR REPLACE PROCEDURE TAX_CUR_LOOP_CASE AS
    SUMSAL NUMBER(16);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
BEGIN
    LOOP R IN CUR
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

        UPDATE SALARY SET TAX =
            CASE
                WHEN SUMSAL < 20000 THEN R.SALVALUE * 0.09
                WHEN SUMSAL < 30000 THEN R.SALVALUE * 0.12
                ELSE R.SALVALUE * 0.15
            END

            WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
    END LOOP;
    COMMIT;
END TAX_CUR_LOOP_CASE;

-- d) с помощью курсора с параметром, передавая номер сотрудника, для которого необходимо посчитать
--    налог.
CREATE  OR  REPLACE  PROCEDURE  TAX_PARAM (EMPID  NUMBER)  AS
DECLARE
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
    SUMSAL NUMBER(16);
BEGIN
    LOOP R IN CUR
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

        UPDATE SALARY SET TAX =
            CASE
                WHEN SUMSAL < 20000 THEN R.SALVALUE * 0.09
                WHEN SUMSAL < 30000 THEN R.SALVALUE * 0.12
                ELSE R.SALVALUE * 0.15
            END

            WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
    END LOOP;
    COMMIT;
END  TAX_PARAM;

-- 04. Создайте процедуру, вычисляющую налог на зарплату за всё время начислений для конкретного
--     сотрудника. В качестве параметров передать процент налога (до 20000, до 30000, выше 30000,
--     номер сотрудника).
CREATE  OR  REPLACE  PROCEDURE  TAX_PARAM_LESS (
    UNDER_20k NUMBER,
    OVER_20k NUMBER,
    OVER_30k NUMBER,
    EMPID  NUMBER)  AS
DECLARE
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID;
    SUMSAL NUMBER(16);
BEGIN
    LOOP R IN CUR
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

        UPDATE SALARY SET TAX =
            CASE
                WHEN SUMSAL < 20000 THEN R.SALVALUE * UNDER_20k
                WHEN SUMSAL < 30000 THEN R.SALVALUE * OVER_20k
                ELSE R.SALVALUE * OVER_30k
            END

            WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
    END LOOP;
    COMMIT;
END  TAX_PARAM_LESS;

-- 05.  Создайте функцию, вычисляющую суммарный налог на зарплату сотрудника за всё время начислений.
--      В качестве параметров передать процент налога (до 20000, до 30000, выше 30000, номер
--      сотрудника). Возвращаемое значение – суммарный налог.
CREATE  OR  REPLACE  FUNCTION  FTAX_PARAM_LESS (
    UNDER_20k NUMBER,
    OVER_20k NUMBER,
    OVER_30k NUMBER,
    EMPID  NUMBER) RETURN NUMBER(16)  AS

DECLARE
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID;
    SUMSAL NUMBER(16);
    RESULT NUMBER(16);
BEGIN
    LOOP R IN CUR
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

        RESULT := RESULT +
            CASE
                WHEN SUMSAL < 20000 THEN R.SALVALUE * UNDER_20k
                WHEN SUMSAL < 30000 THEN R.SALVALUE * OVER_20k
                ELSE R.SALVALUE * OVER_30k
            END

    END LOOP;

END  FTAX_PARAM_LESS;


-- 06.  Создайте пакет, включающий в свой состав процедуру вычисления налога для всех сотрудников,
--      процедуру вычисления налогов для отдельного сотрудника, идентифицируемого своим номером,
--      функцию вычисления суммарного налога на зарплату сотрудника за всё время начислений.
CREATE OR REPLACE PACKAGE TAX_EVAL AS
    PROCEDURE TAX_SIMPLE_LOOP_IF();
    PROCEDURE  TAX_PARAM (EMPID  NUMBER);
    PROCEDURE  TAX_PARAM_LESS (
    UNDER_20k NUMBER,
    OVER_20k NUMBER,
    OVER_30k NUMBER,
    EMPID  NUMBER);


END TAX_EVAL;

CREATE OR REPLACE PACKAGE BODY TAX_EVAL AS
    CREATE OR REPLACE PROCEDURE TAX_SIMPLE_LOOP_IF AS
        SUMSAL NUMBER(16);
    BEGIN
        FOR R IN (SELECT * FROM SALARY)
        LOOP
            SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
                WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

            IF SUMSAL < 20000 THEN
                UPDATE SALARY SET TAX = R.SALVALUE * 0.09
                    WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
            ELSIF SUMSAL < 30000 THEN
                UPDATE SALARY SET TAX = R.SALVALUE * 0.12
                    WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
            ELSE
                UPDATE SALARY SET TAX = R.SALVALUE * 0.15
                    WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
            END IF;
        END LOOP;
        COMMIT;
    END;

    CREATE  OR  REPLACE  PROCEDURE  TAX_PARAM (EMPID  NUMBER)  AS
    DECLARE
        CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
            WHERE EMPNO = EMPID
            FOR UPDATE OF TAX;
        SUMSAL NUMBER(16);
    BEGIN
        LOOP R IN CUR
            SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
                WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

            UPDATE SALARY SET TAX =
                CASE
                    WHEN SUMSAL < 20000 THEN R.SALVALUE * 0.09
                    WHEN SUMSAL < 30000 THEN R.SALVALUE * 0.12
                    ELSE R.SALVALUE * 0.15
                END

                WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
        END LOOP;
        COMMIT;
    END  TAX_PARAM;

    CREATE  OR  REPLACE  PROCEDURE  TAX_PARAM_LESS (
    UNDER_20k NUMBER,
    OVER_20k NUMBER,
    OVER_30k NUMBER,
    EMPID  NUMBER)  AS
    DECLARE
        CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
            WHERE EMPNO = EMPID;
        SUMSAL NUMBER(16);
    BEGIN
        LOOP R IN CUR
            SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
                WHERE S.EMPNO = R.EMPNO AND S.MONTH > R.MONTH AND S.YEAR = R.YEAR;

            UPDATE SALARY SET TAX =
                CASE
                    WHEN SUMSAL < 20000 THEN R.SALVALUE * UNDER_20k
                    WHEN SUMSAL < 30000 THEN R.SALVALUE * OVER_20k
                    ELSE R.SALVALUE * OVER_30k
                END

                WHERE EMPNO = R.EMPNO AND MONTH = R.MONTH AND YEAR = R.YEAR;
        END LOOP;
        COMMIT;
    END  TAX_PARAM_LESS;
END TAX_EVAL;

-- 07.  Создайте триггер, действующий при обновлении данных в таблице SALARY. А именно, если
--      происходит обновление поля SALVALUE, то при назначении новой зарплаты, меньшей чем
--      должностной оклад (таблица JOB, поле MINSALARY), изменение не вносится  и сохраняется старое
--      значение, если новое значение зарплаты больше должностного оклада, то изменение вносится.

-- 08. Создайте триггер, действующий при удалении записи из таблицы CAREER. Если в удаляемой строке
--     поле ENDDATE содержит NULL, то запись не удаляется, в противном случае удаляется.

-- 09. Создайте триггер, действующий на добавление или изменение данных в таблице EMP.
--     Если во вставляемой или изменяемой строке поле BIRTHDATE содержит NULL, то после вставки или
--     изменения должно быть выдано сообщение ‘BERTHDATE is NULL’. Если во вставляемой или изменяемой
--     строке поле BIRTHDATE содержит дату ранее ‘01-01-1940’, то должно быть выдано сообщение
--     ‘PENTIONA’. Во вновь вставляемой строке имя служащего должно быть приведено к заглавным букваь.

--10.  Создайте программу изменения типа заданной переменной из символьного типа (VARCHAR2) в
--     числовой тип (NUMBER).
--     Программа должна содержать раздел обработки исключений. Обработка должна заключаться в выдаче
--     сообщения ‘ERROR: argument is not a number’ .  Исключительная ситуация возникает при задании
--     строки в виде числа с запятой, разделяющей дробную и целую части.