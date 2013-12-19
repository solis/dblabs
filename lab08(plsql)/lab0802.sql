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
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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
CREATE OR REPLACE PROCEDURE TAX_LOOP_CUR_CASE AS
    SUMSAL NUMBER(16);
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
    R CUR%ROWTYPE;
BEGIN
    OPEN CUR;
    LOOP
        FETCH CUR INTO R;
        EXIT WHEN CUR%NOTFOUND;
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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
    SUMSAL NUMBER;
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY FOR UPDATE OF TAX;
BEGIN
   FOR R IN CUR LOOP
         SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
    SUMSAL NUMBER(16);
BEGIN
    FOR R IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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
CREATE  OR  REPLACE  PROCEDURE  TAX_PARAM_LESS (EMPID  NUMBER, UNDER_20k NUMBER,
    OVER_20k NUMBER,
    OVER_30k NUMBER)  AS
    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID
        FOR UPDATE OF TAX;
    SUMSAL NUMBER(16);
BEGIN
    FOR R IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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
    EMPID  NUMBER,
    UNDER_20k NUMBER,
    OVER_20k NUMBER,
    OVER_30k NUMBER) RETURN NUMBER  AS

    CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
        WHERE EMPNO = EMPID;
    SUMSAL NUMBER(16);
    RESULT NUMBER(16);
BEGIN
    RESULT := 0;
    FOR R IN CUR LOOP
        SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
            WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

        RESULT := RESULT +
            CASE
                WHEN SUMSAL < 20000 THEN R.SALVALUE * UNDER_20k
                WHEN SUMSAL < 30000 THEN R.SALVALUE * OVER_20k
                ELSE R.SALVALUE * OVER_30k
            END;

    END LOOP;
    RETURN RESULT;
END  FTAX_PARAM_LESS;

-- Вызов
SELECT FTAX_PARAM_LESS(EMPNO, 1, 2, 3) FROM SALARY

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
    PROCEDURE TAX_SIMPLE_LOOP_IF AS
        SUMSAL NUMBER(16);
    BEGIN
        FOR R IN (SELECT * FROM SALARY)
        LOOP
            SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
                WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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

    PROCEDURE  TAX_PARAM (EMPID  NUMBER)  AS
    DECLARE
        CURSOR CUR IS SELECT EMPNO, SALVALUE, TAX, YEAR, MONTH FROM SALARY
            WHERE EMPNO = EMPID
            FOR UPDATE OF TAX;
        SUMSAL NUMBER(16);
    BEGIN
        LOOP R IN CUR
            SELECT SUM(SALVALUE) INTO SUMSAL FROM SALARY S
                WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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

    PROCEDURE  TAX_PARAM_LESS (
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
                WHERE S.EMPNO = R.EMPNO AND S.MONTH < R.MONTH AND S.YEAR = R.YEAR;

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
CREATE OR REPLACE TRIGGER CHECK_SALARY
    BEFORE UPDATE OF SALVALUE ON SALARY FOR EACH ROW
DECLARE
    CUR(EMPID CAREER.EMPNO%TYPE) IS
        SELECT MINSALARY FROM JOB
            WHERE JOBNO = (SELECT JOBNO FROM CAREER WHERE EMPID = EMPNO AND ENDDATE IS NULL);
    R JOB.MINSALARY%TYPE;

BEGIN
    OPEN CUR(:NEW.EMPNO);
    FETCH CUR INTO R;
    IF :NEW.SALVALUE < R THEN
        :NEW.SALVALUE := :OLD.SALVALUE;
    END IF;
    CLOSE CUR;
END CHECK_SALARY;


-- 08. Создайте триггер, действующий при удалении записи из таблицы CAREER. Если в удаляемой строке
--     поле ENDDATE содержит NULL, то запись не удаляется, в противном случае удаляется.

CREATE OR REPLACE  TRIGGER CHECK_NOT_NULL
    BEFORE DELETE ON CAREER
    FOR EACH ROW
BEGIN
    IF OLD.ENDDATE IS NULL
        INSERT INTO CAREER VALUES (OLD.JOBNO, OLD.EMPNO, OLD.STARTDATE, OLD.ENDDATE);
    END IF;
END CHECK_NOT_NULL;

--- ALTERNATIVE ------------------------------------------------------------------------------------

CREATE TABLE CAREER
       (JOBNO NUMBER(4)
             REFERENCES JOB(JOBNO) NOT NULL,
        EMPNO NUMBER(4)
             REFERENCES EMP(EMPNO) NOT NULL,
        DEPTNO NUMBER(4)
             REFERENCES DEPT(DEPTNO),
    STARTDATE DATE
             NOT NULL,
    ENDDATE DATE);

CREATE OR REPLACE  TRIGGER CHECK_NOT_NULL
    BEFORE DELETE ON CAREER
    FOR EACH ROW
BEGIN
    IF OLD.ENDDATE IS NULL
        INSERT INTO CAREER_TMP VALUES (OLD.JOBNO, OLD.EMPNO, OLD.STARTDATE, OLD.ENDDATE);
    END IF;
END CHECK_NOT_NULL;

CREATE OR REPLACE TRIGGER COPY_EMP
    INSTEAD OF INSERT ON CAREER_TMP
    FOR EACH ROW
BEGIN
   INSERT INTO CAREER VALUES (NEW.JOBNO, NEW.EMPNO, NEW.STARTDATE, NEW.ENDDATE);
END
-- 09. Создайте триггер, действующий на добавление или изменение данных в таблице EMP.
--     Если во вставляемой или изменяемой строке поле BIRTHDATE содержит NULL, то после вставки или
--     изменения должно быть выдано сообщение ‘BERTHDATE is NULL’. Если во вставляемой или изменяемой
--     строке поле BIRTHDATE содержит дату ранее ‘01-01-1940’, то должно быть выдано сообщение
--     ‘PENTIONA’. Во вновь вставляемой строке имя служащего должно быть приведено к заглавным букваь.
CREATE OR REPLACE TRIGGER ON_EMP_INSERT_UPDATE
    BEFORE INSERT OR UPDATE ON EMP
    FOR EACH ROW
BEGIN
    IF :NEW.BIRTHDATE IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('BIRTHDATE IS NULL');
    END IF;

    IF :NEW.BIRTHDATE < to_date('01-01-1940', 'dd-mm-yyyy') THEN
        DBMS_OUTPUT.PUT_LINE('PENTIONA');
    END IF;

    :NEW.EMPNAME := UPPER(:NEW.EMPNAME);
END ON_EMP_INSERT_UPDATE;

--10.  Создайте программу изменения типа заданной переменной из символьного типа (VARCHAR2) в
--     числовой тип (NUMBER).
--     Программа должна содержать раздел обработки исключений. Обработка должна заключаться в выдаче
--     сообщения ‘ERROR: argument is not a number’ .  Исключительная ситуация возникает при задании
--     строки в виде числа с запятой, разделяющей дробную и целую части.
DECLARE
    X number;
    FUNCTION str2nr(str in varchar2) return NUMBER  IS
    BEGIN
        RETURN CAST(str AS NUMBER);
        EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('CLASS CAST EXCEPTION ' || str);
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20103, 'SHOULD NOT GET THERE');
        RETURN NULL;
    END;
BEGIN
    x := str2nr( '1234123' );
    DBMS_OUTPUT.PUT_LINE(x);
    x := str2nr( '5.1' );
    DBMS_OUTPUT.PUT_LINE(x);
    x := str2nr( '4,123' );
    DBMS_OUTPUT.PUT_LINE(x);
END;
